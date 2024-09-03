import 'package:flutter_chatbot_app/constants.dart';
import 'package:flutter_chatbot_app/hive/chat_history.dart';
import 'package:flutter_chatbot_app/hive/settings.dart';
import 'package:flutter_chatbot_app/hive/user_model.dart';
import 'package:hive/hive.dart';

class Boxes {
  static Box<ChatHistory> getChatHistory() =>
      Hive.box<ChatHistory>(Constants.chatHistoryBox);

  static Box<UserModel> getUser() => Hive.box<UserModel>(Constants.userBox);

  static Box<Settings> getSettings() =>
      Hive.box<Settings>(Constants.settingsBox);
}
