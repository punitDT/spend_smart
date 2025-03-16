import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeleteConfirmationDialog {
  final VoidCallback onConfirm;
  final String title;
  final String message;

  const DeleteConfirmationDialog({
    required this.onConfirm,
    this.title = 'Delete Transaction',
    this.message = 'Are you sure you want to delete this transaction?',
  });

  Future<bool> show() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onConfirm();
              Get.back(result: true);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
