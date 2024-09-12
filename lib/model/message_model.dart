import 'package:flutter_chatbot_app/hive/role.dart';

class Message {
  String messageId;
  String chatId;
  StringBuffer message;
  List<dynamic> imageUrls;
  Role role;
  DateTime timeStamp;

  Message(
      {required this.messageId,
      required this.chatId,
      required this.message,
      required this.imageUrls,
      required this.timeStamp,
      required this.role});

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      "messageId": messageId,
      "message": message.toString(),
      "role": role,
      "timeStamp": timeStamp.toIso8601String(),
      "imageUrls": imageUrls
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
        messageId: map['messageId'],
        chatId: map['chatId'],
        message: StringBuffer(map['message']),
        imageUrls: List<dynamic>.from(map['imageUrls']),
        timeStamp: DateTime.parse(map['timeStamp']),
        role: Role.values[map['role']]);
  }

  Message copyWith({
    String? messageId,
    String? chatId,
    List? imageUrls,
    Role? role,
    DateTime? timeStamp,
    StringBuffer? message,
  }) {
    return Message(
        messageId: messageId ?? this.messageId,
        chatId: chatId ?? this.chatId,
        message: message ?? this.message,
        imageUrls: imageUrls ?? this.imageUrls,
        timeStamp: timeStamp ?? this.timeStamp,
        role: role ?? this.role);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Message && other.messageId == messageId;
  }

  @override
  int get hashCode {
    return messageId.hashCode;
  }
}
