import 'package:flutter/material.dart';
import 'package:flutter_chatbot_app/hive/boxes.dart';
import 'package:flutter_chatbot_app/hive/chat_history.dart';
import 'package:flutter_chatbot_app/widgets/chat_history_widget.dart';
import 'package:flutter_chatbot_app/widgets/empty_history_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Chat History"),
        ),
        body: ValueListenableBuilder<Box<ChatHistory>>(
            valueListenable: Boxes.getChatHistory().listenable(),
            builder: (context, box, _) {
              final chatHistory = box.values.toList().cast<ChatHistory>();
              return chatHistory.isEmpty
                  ? const EmptyHistoryWidget()
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(itemBuilder: (context, index) {
                        final chat = chatHistory[index];
                        return ChatHistoryWidget(chat: chat);
                      }),
                    );
            }));
  }
}
