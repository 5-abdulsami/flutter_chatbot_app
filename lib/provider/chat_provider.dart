import 'dart:core';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chatbot_app/api/api_service.dart';
import 'package:flutter_chatbot_app/constants.dart';
import 'package:flutter_chatbot_app/hive/chat_history.dart';
import 'package:flutter_chatbot_app/hive/settings.dart';
import 'package:flutter_chatbot_app/hive/user_model.dart';
import 'package:flutter_chatbot_app/model/message_model.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  List<Message> _inChatMessages = [];

  PageController _pageController = PageController();

  List<XFile>? _imageFilesList = [];

  int _currentIndex = 0;

  String _currentChatId = "";

  GenerativeModel? _model;

  GenerativeModel? _textModel;

  GenerativeModel? _visionModel;

  String _modelType = "gemini-pro";

  bool _isLoading = false;

  // setters

  // set inChatMessages
  Future<void> setInChatMessages({required String chatId}) async {
    // get messages from Hive db
    final messagesFromDb = await loadMessagesFromDb(chatId: chatId);

    for (var message in messagesFromDb) {
      if (_inChatMessages.contains(message)) {
        print("this message already exists");
        continue;
      }
      _inChatMessages.add(message);
    }
    notifyListeners();
  }

  // load messages from db
  Future<List<Message>> loadMessagesFromDb({required String chatId}) async {
    // open the box of this chatId
    await Hive.openBox("${Constants.chatMessagesBox}$chatId");

    final messageBox = Hive.box("${Constants.chatMessagesBox}$chatId");
    final newData = messageBox.keys.map((key) {
      final message = messageBox.get(key);
      final messageData = Message.fromMap(Map<String, dynamic>.from(message));

      return messageData;
    }).toList();
    notifyListeners();
    return newData;
  }

  // set image files list
  void setImageFilesList({required List<XFile> imagesList}) {
    _imageFilesList = imagesList;
    notifyListeners();
  }

  // set the current model
  String setCurrentModel({required String newModel}) {
    _modelType = newModel;
    notifyListeners();
    return newModel;
  }

  // function to set the model based on the bool : isTextOnly
  Future<void> setModel({required bool isTextOnly}) async {
    if (isTextOnly) {
      _model = _textModel ??
          GenerativeModel(
              model: setCurrentModel(newModel: "gemini-pro"),
              apiKey: ApiService.API_KEY);
    } else {
      _model = _visionModel ??
          GenerativeModel(
              model: setCurrentModel(newModel: "gemini-pro-vision"),
              apiKey: ApiService.API_KEY);
    }
    notifyListeners();
  }

  // set current page index
  void setCurrentIndex({required int newIndex}) {
    _currentIndex = newIndex;
    notifyListeners();
  }

  // set current chatId
  void setCurrentChatid({required String newChatId}) {
    _currentChatId = newChatId;
    notifyListeners();
  }

  // set loading
  void setLoading({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

  List<dynamic> get inChatMessages => _inChatMessages;
  PageController get pageController => _pageController;
  List<XFile> get imageFilesList => _imageFilesList!;
  int get currentIndex => _currentIndex;
  String get currentChatId => _currentChatId;
  GenerativeModel get model => _model!;
  GenerativeModel get textModel => _textModel!;
  GenerativeModel get visionModel => _visionModel!;
  String get modelType => _modelType;
  bool get isLoading => _isLoading;

  // send the message to gemini and get the stream response
  Future<void> sendMessage(
      {required String message, required bool isTextOnly}) async {
    // set the model
    await setModel(isTextOnly: isTextOnly);

    // set loading
    setLoading(value: true);

    // get chatId
    String chatId = getChatId();

    // list of history messages
    List<Content> history = [];

    // get the chat history
    history = await getHistory(chatId: chatId);

    // get the imageUrls
    List<String> imageUrls = getImageUrls(isTextOnly: isTextOnly);

    // user message id
    final userMessageId = const Uuid().v4();

    // user message
    final userMessage = Message(
        messageId: userMessageId,
        chatId: chatId,
        message: StringBuffer(message),
        imageUrls: imageUrls,
        timeStamp: DateTime.now(),
        role: Role.user);

    // add this message to the list of inChatMessages
    _inChatMessages.add(userMessage);
    notifyListeners();

    // sending a new message to the chat
    if (currentChatId.isEmpty) {
      setCurrentChatid(newChatId: chatId);
    }

    // send message to the model and wait for the response
    await sendMessageAndWaitForResponse(
        message: message,
        chatId: chatId,
        isTextOnly: isTextOnly,
        history: history,
        userMessage: userMessage);
  }

  Future<void> sendMessageAndWaitForResponse(
      {required String message,
      required String chatId,
      required bool isTextOnly,
      required Message userMessage,
      required List<Content> history}) async {
    // start the chat session -- only send history if its text only
    final chatSession = _model!.startChat(
      history: history.isEmpty || !isTextOnly ? null : history,
    );

    // get content
    final content = await getContent(message: message, isTextOnly: isTextOnly);

    // assistant message id
    final assistantMessageId = const Uuid().v4();

    // AI assistant message
    final assistantMessage = userMessage.copyWith(
        messageId: assistantMessageId,
        role: Role.assistant,
        timeStamp: DateTime.now(),
        message: StringBuffer());

    // add this message in the list of inChatMessages
    _inChatMessages.add(assistantMessage);
    notifyListeners();

    // wait for stream response
    chatSession.sendMessageStream(content).asyncMap((event) => event).listen(
        (event) {
      _inChatMessages
          .firstWhere((element) =>
              element.messageId == assistantMessage.messageId &&
              element.role == Role.assistant)
          .message
          .write(event.text);
      notifyListeners();
    }, onDone: () {
      // save message to hive db

      // set loading to false
      setLoading(value: false);
    }).onError((error, StackTrace) {
      // set loading to false
      setLoading(value: false);
    });
  }

  // get content
  Future<Content> getContent(
      {required String message, required bool isTextOnly}) async {
    if (isTextOnly) {
      // generate text from text only input
      return Content.text(message);
    } else {
      // generate image from text and image input
      final imageFutures = _imageFilesList!
          .map((imageFile) => imageFile.readAsBytes())
          .toList(growable: false);
      final imageBytes = await Future.wait(imageFutures);

      final prompt = TextPart(message);

      final imageParts = imageBytes
          .map((bytes) => DataPart('image/jpg', Uint8List.fromList(bytes)))
          .toList();

      return Content.model([prompt, ...imageParts]);
    }
  }

  // get the imageUrls method
  List<String> getImageUrls({required bool isTextOnly}) {
    List<String> imageUrls = [];
    if (!isTextOnly && imageFilesList.isNotEmpty) {
      for (var image in imageFilesList) {
        imageUrls.add(image.path);
      }
    }
    return imageUrls;
  }

  // get history method
  Future<List<Content>> getHistory({required String chatId}) async {
    List<Content> history = [];
    // get history only if the chatId is not empty
    if (currentChatId.isNotEmpty) {
      await setInChatMessages(chatId: chatId);

      for (var message in inChatMessages) {
        if (message.role == Role.user) {
          history.add(Content.text(message.message.toString()));
        } else {
          history.add(Content.model({TextPart(message.message.toString())}));
        }
      }
    }
    return history;
  }

  // get chatId method
  String getChatId() {
    if (currentChatId.isEmpty) {
      return const Uuid().v4();
    } else {
      return currentChatId;
    }
  }

  static initHive() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);

    await Hive.initFlutter(Constants.chatbotDB);

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ChatHistoryAdapter());
    }
    await Hive.openBox<ChatHistory>(Constants.chatHistoryBox);

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    await Hive.openBox<UserModel>(Constants.userBox);

    if (!Hive.isAdapterRegistered(2)) {
      await Hive.openBox<Settings>(Constants.settingsBox);
    }
  }
}
