import 'package:flutter/material.dart';
import 'package:flutter_chatbot_app/model/message_model.dart';
import 'package:flutter_chatbot_app/provider/chat_provider.dart';
import 'package:flutter_chatbot_app/widgets/assistant_message_widget.dart';
import 'package:flutter_chatbot_app/widgets/bottom_chat_field.dart';
import 'package:flutter_chatbot_app/widgets/my_message_widget.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0.0) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.inChatMessages.isNotEmpty) {
          _scrollToBottom();
        }

        // auto scroll to bottom on a new message
        chatProvider.addListener(() {
          if (chatProvider.inChatMessages.isNotEmpty) {
            _scrollToBottom();
          }
        });
        return Scaffold(
          appBar: AppBar(
            title: const Text('Chat with Gemini'),
            centerTitle: true,
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
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
                              controller: _scrollController,
                              itemCount: chatProvider.inChatMessages.length,
                              itemBuilder: (context, index) {
                                final message =
                                    chatProvider.inChatMessages[index];
                                return message.role == Role.user
                                    ? MyMessageWidget(message: message)
                                    : AssistantMessageWidget(
                                        message: message.message.toString());
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
