import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatbot_app/provider/chat_provider.dart';

class BottomChatField extends StatefulWidget {
  const BottomChatField({super.key, required this.chatProvider});
  final ChatProvider chatProvider;

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  final textController = TextEditingController();
  final textFocusNode = FocusNode();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Row(
        children: [
          IconButton(
              onPressed: () {
                // pick image
              },
              icon: const Icon(Icons.image)),
          Expanded(
              child: TextField(
            focusNode: textFocusNode,
            controller: textController,
            textInputAction: TextInputAction.send,
            onSubmitted: (value) {},
            decoration: InputDecoration.collapsed(
                hintText: "Enter your prompt...",
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(30),
                )),
          )),
          GestureDetector(
            onTap: () {
              //send message
            },
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.arrow_upward,
                    color: Colors.white,
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
