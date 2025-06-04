import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BackButtonHandler {
  static Future<bool> onWillPop(BuildContext context, {String? message}) async {
    if (message != null) {
      final shouldPop = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Are you sure?'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes'),
            ),
          ],
        ),
      );
      return shouldPop ?? false;
    }
    return true;
  }

  static void handleBackButton(BuildContext context, {String? message}) {
    SystemNavigator.pop();
  }
} 