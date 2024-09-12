import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatbot_app/hive/chat_history.dart';
import 'package:flutter_chatbot_app/utils/utils.dart';

class ChatHistoryWidget extends StatelessWidget {
  const ChatHistoryWidget({
    super.key,
    required this.chat,
  });

  final ChatHistory chat;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: EdgeInsets.only(left: 10, right: 10),
        leading: CircleAvatar(radius: 30, child: Icon(Icons.chat)),
        title: Text(
          chat.prompt,
          maxLines: 1,
        ),
        subtitle: Text(
          chat.response,
          maxLines: 2,
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // navigate to chat screen
        },
        onLongPress: () {
          // show animated dialog to delete chat
          showAnimatedDialog(
              context: context,
              title: "Delete Chat",
              content: "Are you sure you want to delete this chat?",
              actionText: "Delete",
              onActionPressed: (value) {
                if (value) {
                  showSnackBar(context, "Chat Deleted");
                }
              });
        },
      ),
    );
  }
}
