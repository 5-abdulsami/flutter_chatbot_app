import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_chatbot_app/model/message_model.dart';
import 'package:flutter_chatbot_app/provider/chat_provider.dart';
import 'package:provider/provider.dart';

class PreviewImagesWidet extends StatelessWidget {
  const PreviewImagesWidet({super.key, this.message});
  final Message? message;

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(builder: (context, chatProvider, child) {
      final messageToShow =
          message != null ? message!.imageUrls : chatProvider.imageFilesList;
      final padding = message != null
          ? EdgeInsets.zero
          : const EdgeInsets.only(left: 8, right: 8);
      return Padding(
        padding: padding,
        child: SizedBox(
          height: 80,
          child: ListView.builder(
              itemCount: messageToShow.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.fromLTRB(4, 8, 4, 0),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        File(
                          message != null
                              ? message!.imageUrls[index]
                              : chatProvider.imageFilesList[index].path,
                        ),
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      )),
                );
              }),
        ),
      );
    });
  }
}
