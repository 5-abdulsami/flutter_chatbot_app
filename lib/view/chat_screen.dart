import 'package:flutter/material.dart';
import 'package:flutter_chatbot_app/provider/chat_provider.dart';
import 'package:flutter_chatbot_app/widgets/bottom_chat_field.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Chat with Gemini'),
            centerTitle: true,
            backgroundColor: Colors.grey,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                      child: chatProvider.inChatMessages.isEmpty
                          ? const Center(
                              child: Text('No messages yet'),
                            )
                          : ListView.builder(
                              itemCount: chatProvider.inChatMessages.length,
                              itemBuilder: (context, index) {
                                final message =
                                    chatProvider.inChatMessages[index];
                                return ListTile(
                                  title: Text(message.message.toString()),
                                );
                              })),
                  BottomChatField(
                    chatProvider: chatProvider,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
