import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';

class AssistantMessageWidget extends StatelessWidget {
  const AssistantMessageWidget({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.all(15),
          margin: const EdgeInsets.only(bottom: 8),
          child: message.isEmpty
              ? const SizedBox(
                  width: 50,
                  child: SpinKitThreeBounce(
                    color: Colors.blueGrey,
                    size: 20.0,
                  ),
                )
              : GestureDetector(
                  onDoubleTap: () {
                    Clipboard.setData(ClipboardData(text: message));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Response copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: MarkdownBody(
                    selectable: true,
                    data: message,
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w400),
                      h1: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.w900),
                      h2: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w800),
                      h3: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w700),
                      h4: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w600),
                      h5: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w600),
                      h6: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    onTapLink: (text, href, title) {
                      if (href != null) {
                        // Use the url_launcher package to open the link
                        launchUrl(Uri.parse(href));
                      }
                    },
                  ),
                )),
    );
  }
}
