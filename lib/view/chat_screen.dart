import 'package:flutter/material.dart';
import 'package:flutter_chatbot_app/provider/chat_provider.dart';
import 'package:flutter_chatbot_app/utility/asset_manager.dart';
import 'package:flutter_chatbot_app/utility/utilities.dart';
import 'package:flutter_chatbot_app/widgets/bottom_chat_field.dart';
import 'package:flutter_chatbot_app/widgets/chat_messages.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // scroll controller
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0.0) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
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

        // auto scroll to bottom on new message
        chatProvider.addListener(() {
          if (chatProvider.inChatMessages.isNotEmpty) {
            _scrollToBottom();
          }
        });

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            centerTitle: true,
            title: Text(
              'Chat with Gemini',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              if (chatProvider.inChatMessages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    child: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        // show my animated dialog to start new chat
                        showMyAnimatedDialog(
                          context: context,
                          title: 'Start New Chat',
                          content: 'Are you sure you want to start a new chat?',
                          actionText: 'Yes',
                          onActionPressed: (value) async {
                            if (value) {
                              // prepare chat room
                              await chatProvider.prepareChatRoom(
                                  isNewChat: true, chatID: '');
                            }
                          },
                        );
                      },
                    ),
                  ),
                )
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: chatProvider.inChatMessages.isEmpty
                        ? Center(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Opacity(
                                    opacity: 0.5,
                                    child: Image(
                                      image: const AssetImage(
                                          AssetsManager.appIcon),
                                      width: MediaQuery.of(context).size.width *
                                          0.55,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.55,
                                    ),
                                  ),
                                  Text(
                                    'Start a chat...',
                                    style: GoogleFonts.poppins(
                                        fontSize: 20, color: Colors.grey),
                                  ),
                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).size.width * 0.1,
                                  )
                                ],
                              ),
                            ),
                          )
                        : ChatMessages(
                            scrollController: _scrollController,
                            chatProvider: chatProvider,
                          ),
                  ),

                  // input field
                  BottomChatField(
                    chatProvider: chatProvider,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
