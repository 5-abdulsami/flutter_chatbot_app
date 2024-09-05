import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chatbot_app/api/api_service.dart';
import 'package:flutter_chatbot_app/constants.dart';
import 'package:flutter_chatbot_app/hive/chat_history.dart';
import 'package:flutter_chatbot_app/hive/settings.dart';
import 'package:flutter_chatbot_app/hive/user_model.dart';
import 'package:flutter_chatbot_app/model/message_model.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ChatProvider extends ChangeNotifier {
  List<Message> _inChatMessages = [];

  PageController _pageController = PageController();

  List<XFile>? _imageFilesList = [];

  int _currentIndex = 0;

  String _currentChatId = "";

  GenerativeModel? _gModel;

  GenerativeModel? _textModel;

  GenerativeModel? _visionModel;

  String _modelType = "gemini-pro";

  bool _isLoading = false;

  List<dynamic> get inChatMessages => _inChatMessages;
  PageController get pageController => _pageController;
  List<XFile> get imageFilesList => _imageFilesList!;
  int get currentIndex => _currentIndex;
  String get currentChatId => _currentChatId;
  GenerativeModel get gModel => _gModel!;
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
