import 'package:hive/hive.dart';

part 'chat_history.g.dart';

@HiveType(typeId: 0)
class ChatHistory extends HiveObject {
  @HiveField(0)
  final String chatId;

  @HiveField(1)
  final String prompt;

  @HiveField(2)
  final String response;

  @HiveField(3)
  final List<dynamic> imageUrls;

  @HiveField(4)
  final DateTime timeStamp;

  ChatHistory(
      {required this.chatId,
      required this.prompt,
      required this.response,
      required this.timeStamp,
      required this.imageUrls});
}
