import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeleteConfirmationDialog {
  final String title;
  final String message;
  final VoidCallback onConfirm;

  DeleteConfirmationDialog({
    this.title = 'Delete Transaction',
    this.message = 'Are you sure you want to delete this transaction?',
    required this.onConfirm,
  });

  Future<void> show() async {
    return Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () {
              onConfirm();
              Get.back();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
