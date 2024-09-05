import 'dart:core';
import 'dart:nativewrappers/_internal/vm/lib/developer.dart';

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
        log("this message already exists");
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
  void setChatid({required String newChatId}) {
    _currentChatId = newChatId;
    notifyListeners();
  }

  // set loading
  void setLoading({required bool newLoading}) {
    _isLoading = newLoading;
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
