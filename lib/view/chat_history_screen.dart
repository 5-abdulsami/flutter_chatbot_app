import 'package:flutter/material.dart';
import 'package:BotPal/hive/chat_history.dart';
import 'package:BotPal/widgets/chat_history_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:BotPal/provider/chat_provider.dart';

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat History',
          style: GoogleFonts.poppins(),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<ChatHistory>>(
        future: context.read<ChatProvider>().getChatHistories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading chat histories'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No chat histories available'));
          } else {
            final chatHistories = snapshot.data!;
            return ListView.builder(
              itemCount: chatHistories.length,
              itemBuilder: (context, index) {
                return ChatHistoryWidget(chat: chatHistories[index]);
              },
            );
          }
        },
      ),
    );
  }
}
