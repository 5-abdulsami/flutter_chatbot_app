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
  final String userId;

  @HiveField(4)
  final DateTime timeStamp;

  @HiveField(5)
  final String imageUrls;

  ChatHistory(this.chatId, this.prompt, this.response, this.userId,
      this.timeStamp, this.imageUrls);
}
