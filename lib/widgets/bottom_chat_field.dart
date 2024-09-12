import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_chatbot_app/provider/chat_provider.dart';
import 'package:flutter_chatbot_app/utils/utils.dart';
import 'package:flutter_chatbot_app/widgets/preview_images_widet.dart';
import 'package:image_picker/image_picker.dart';

class BottomChatField extends StatefulWidget {
  const BottomChatField({super.key, required this.chatProvider});
  final ChatProvider chatProvider;

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  final textController = TextEditingController();
  final textFocusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  Future<void> sendChatMessage(
      {required String message,
      required ChatProvider chatProvider,
      required bool isTextOnly}) async {
    try {
      await chatProvider.sendMessage(message: message, isTextOnly: isTextOnly);
    } catch (e) {
      log("error : $e");
    } finally {
      textController.clear();
      chatProvider.setImageFilesList(imagesList: []);
      textFocusNode.unfocus();
    }
  }

  // method to pick image
  void pickImage() async {
    try {
      final pickedImages = await _picker.pickMultiImage(
          maxHeight: 800, maxWidth: 800, imageQuality: 95);

      widget.chatProvider.setImageFilesList(imagesList: pickedImages);
    } catch (e) {
      log("error : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasImages = widget.chatProvider.imageFilesList.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Column(
        children: [
          if (hasImages) const PreviewImagesWidet(),
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    if (hasImages) {
                      // show delete dialog
                      showAnimatedDialog(
                          context: context,
                          title: 'Delete Images',
                          content: 'Are you sure you want to delete images?',
                          actionText: 'Delete',
                          onActionPressed: (value) {
                            if (value) {
                              widget.chatProvider
                                  .setImageFilesList(imagesList: []);
                            }
                          });
                    } else {
                      // pick image
                      pickImage();
                    }
                  },
                  icon: Icon(hasImages ? Icons.delete : Icons.image)),
              Expanded(
                  child: TextField(
                focusNode: textFocusNode,
                controller: textController,
                textInputAction: TextInputAction.send,
                onSubmitted: widget.chatProvider.isLoading
                    ? null
                    : (value) {
                        if (value.isNotEmpty) {
                          sendChatMessage(
                              message: textController.text,
                              chatProvider: widget.chatProvider,
                              isTextOnly: hasImages ? false : true);
                        }
                      },
                decoration: InputDecoration.collapsed(
                    hintText: "Enter your prompt...",
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(30),
                    )),
              )),
              GestureDetector(
                onTap: widget.chatProvider.isLoading
                    ? null
                    : () {
                        //send message
                        if (textController.text.isNotEmpty) {
                          sendChatMessage(
                              message: textController.text,
                              chatProvider: widget.chatProvider,
                              isTextOnly: true);
                        }
                      },
                child: Container(
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.arrow_upward,
                        color: Colors.white,
                      ),
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
