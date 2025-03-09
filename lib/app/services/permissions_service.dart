import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsService extends GetxService {
  final RxBool hasSmsPermission = false.obs;

  Future<bool> requestSmsPermission() async {
    final status = await Permission.sms.request();
    hasSmsPermission.value = status.isGranted;
    return status.isGranted;
  }

  Future<bool> checkSmsPermission() async {
    final status = await Permission.sms.status;
    hasSmsPermission.value = status.isGranted;
    return status.isGranted;
  }

  void showPermissionDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('SMS Permission Required'),
        content: const Text(
          'This app needs SMS permission to process your bank messages.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
