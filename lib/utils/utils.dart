// animated dialog
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showAnimatedDialog(
    {required BuildContext context,
    required String title,
    required String content,
    required String actionText,
    required Function(bool) onActionPressed}) async {
  showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "",
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secodaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              title: Text(
                title,
                textAlign: TextAlign.center,
              ),
              content: Text(content),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () {
                      onActionPressed(true);
                      Navigator.of(context).pop();
                    },
                    child: Text(actionText)),
              ],
            ),
          ),
        );
      });
}
