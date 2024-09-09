import 'package:flutter/material.dart';
import 'package:flutter_chatbot_app/model/message_model.dart';
import 'package:flutter_chatbot_app/widgets/preview_images_widet.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MyMessageWidget extends StatelessWidget {
  const MyMessageWidget({super.key, required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (message.imageUrls.isNotEmpty)
              PreviewImagesWidet(
                message: message,
              ),
            MarkdownBody(
              data: message.message.toString(),
              selectable: true,
            ),
          ],
        ),
      ),
    );
  }
}
