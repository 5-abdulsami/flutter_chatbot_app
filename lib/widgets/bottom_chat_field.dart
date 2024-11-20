import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:BotPal/provider/chat_provider.dart';
import 'package:BotPal/utility/utilities.dart';
import 'package:BotPal/widgets/preview_images_widet.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class BottomChatField extends StatefulWidget {
  const BottomChatField({
    super.key,
    required this.chatProvider,
  });

  final ChatProvider chatProvider;

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  // controller for the input field
  final TextEditingController textController = TextEditingController();

  // focus node for the input field
  final FocusNode textFieldFocus = FocusNode();

  // initialize image picker
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    textController.dispose();
    textFieldFocus.dispose();
    super.dispose();
  }

  Future<void> sendChatMessage({
    required String message,
    required ChatProvider chatProvider,
    required bool isTextOnly,
  }) async {
    try {
      await chatProvider.sendMessage(
        message: message,
        isTextOnly: isTextOnly,
      );
    } catch (e) {
      log('error : $e');
    } finally {
      textController.clear();
      widget.chatProvider.setImagesFileList(listValue: []);
      textFieldFocus.unfocus();
    }
  }

  // pick an image
  void pickGalleryImage() async {
    try {
      final pickedImages = await _picker.pickMultiImage(
        maxHeight: 800,
        maxWidth: 800,
        imageQuality: 95,
      );
      widget.chatProvider.setImagesFileList(listValue: pickedImages);
    } catch (e) {
      log('error : $e');
    }
  }

  void pickCameraImage() async {
    try {
      final pickedImage = await _picker.pickImage(
          source: ImageSource.camera,
          maxHeight: 800,
          maxWidth: 800,
          imageQuality: 95);
      widget.chatProvider.setImagesFileList(listValue: [pickedImage!]);
    } catch (e) {
      log('error : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasImages = widget.chatProvider.imagesFileList != null &&
        widget.chatProvider.imagesFileList!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Theme.of(context).textTheme.titleLarge!.color!,
        ),
      ),
      child: Column(
        children: [
          if (hasImages) const PreviewImagesWidget(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  if (hasImages) {
                    // show the delete dialog
                    showMyAnimatedDialog(
                        context: context,
                        title: 'Delete Images',
                        content: 'Are you sure you want to delete the images?',
                        actionText: 'Delete',
                        onActionPressed: (value) {
                          if (value) {
                            widget.chatProvider
                                .setImagesFileList(listValue: []);
                          }
                        });
                  } else {
                    pickCameraImage();
                  }
                },
                icon: Icon(hasImages ? Icons.delete_forever : Icons.camera),
              ),
              hasImages
                  ? Container()
                  : IconButton(
                      onPressed: () {
                        if (hasImages) {
                          // show the delete dialog
                          showMyAnimatedDialog(
                              context: context,
                              title: 'Delete Images',
                              content:
                                  'Are you sure you want to delete the images?',
                              actionText: 'Delete',
                              onActionPressed: (value) {
                                if (value) {
                                  widget.chatProvider
                                      .setImagesFileList(listValue: []);
                                }
                              });
                        } else {
                          pickGalleryImage();
                        }
                      },
                      icon: const Icon(Icons.image),
                    ),
              Expanded(
                child: TextField(
                  focusNode: textFieldFocus,
                  controller: textController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: widget.chatProvider.isLoading
                      ? null
                      : (String value) {
                          if (value.isNotEmpty) {
                            // send the message
                            sendChatMessage(
                              message: textController.text,
                              chatProvider: widget.chatProvider,
                              isTextOnly: hasImages ? false : true,
                            );
                          }
                        },
                  decoration: InputDecoration.collapsed(
                      hintText: 'Ask me anything...',
                      hintStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(30),
                      )),
                ),
              ),
              GestureDetector(
                onTap: widget.chatProvider.isLoading
                    ? null
                    : () {
                        if (textController.text.isNotEmpty) {
                          // send the message
                          sendChatMessage(
                            message: textController.text,
                            chatProvider: widget.chatProvider,
                            isTextOnly: hasImages ? false : true,
                          );
                        }
                      },
                child: Container(
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.all(5.0),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.arrow_upward, color: Colors.white),
                    )),
              )
            ],
          ),
        ],
      ),
    );
  }
}
