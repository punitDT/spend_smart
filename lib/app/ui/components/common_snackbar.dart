import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonSnackbar {
  static void show({
    required String title,
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: isError
            ? Get.theme.colorScheme.error
            : Get.theme.colorScheme.primary,
        colorText: isError
            ? Get.theme.colorScheme.onError
            : Get.theme.colorScheme.onPrimary,
        duration: duration,
      );
    });
  }

  static void showError(String title, String message) {
    show(
      title: title,
      message: message,
      isError: true,
    );
  }

  static void showSuccess(String title, String message) {
    show(
      title: title,
      message: message,
      isError: false,
    );
  }
}
