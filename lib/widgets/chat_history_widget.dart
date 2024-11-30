import 'package:flutter/material.dart';
import 'package:BotPal/hive/chat_history.dart';
import 'package:BotPal/provider/chat_provider.dart';
import 'package:BotPal/utility/utilities.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatHistoryWidget extends StatelessWidget {
  const ChatHistoryWidget({
    super.key,
    required this.chat,
  });

  final ChatHistory chat;

  @override
  Widget build(BuildContext context) {
    // Format the date and time
    final String formattedDateTime =
        DateFormat('dd-MM-yyyy – kk:mm').format(chat.timestamp);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 7),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 10.0, right: 10.0),
        leading: const CircleAvatar(
          radius: 30,
          child: Icon(Icons.chat),
        ),
        title: Text(
          chat.prompt,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
          maxLines: 1,
        ),
        subtitle: Column(
          children: [
            Text(
              chat.response,
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
            ),
            const SizedBox(
              height: 6,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                formattedDateTime,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () async {
          // navigate to chat screen
          final chatProvider = context.read<ChatProvider>();
          // prepare chat room
          await chatProvider.prepareChatRoom(
            isNewChat: false,
            chatID: chat.chatId,
          );
          chatProvider.setCurrentIndex(newIndex: 1);
          chatProvider.pageController.jumpToPage(1);
        },
        onLongPress: () {
          // show my animated dialog to delete the chat
          showMyAnimatedDialog(
            context: context,
            title: 'Delete Chat',
            content: 'Are you sure you want to delete this chat?',
            actionText: 'Delete',
            onActionPressed: (value) async {
              if (value) {
                // delete the chat
                await context
                    .read<ChatProvider>()
                    .deletChatMessages(chatId: chat.chatId);

                // delete the chat history
                await chat.delete();
              }
            },
          );
        },
      ),
    );
  }
}
