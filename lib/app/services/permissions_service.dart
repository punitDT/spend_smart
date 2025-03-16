import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/logger.dart';

class PermissionsService extends GetxService {
  static const String _tag = 'PermissionsService';
  final RxBool hasSmsPermission = false.obs;

  Future<bool> requestSmsPermission() async {
    try {
      Logger.i(_tag, 'Requesting SMS permission');
      final status = await Permission.sms.request();
      Logger.i(_tag, 'SMS permission request result: ${status.name}');
      hasSmsPermission.value = status.isGranted;
      return status.isGranted;
    } catch (e, stackTrace) {
      Logger.e(_tag, 'Error requesting SMS permission', e, stackTrace);
      return false;
    }
  }

  Future<bool> checkSmsPermission() async {
    try {
      Logger.i(_tag, 'Checking SMS permission status');
      final status = await Permission.sms.status;
      Logger.i(_tag, 'SMS permission status: ${status.name}');
      hasSmsPermission.value = status.isGranted;
      return status.isGranted;
    } catch (e, stackTrace) {
      Logger.e(_tag, 'Error checking SMS permission status', e, stackTrace);
      return false;
    }
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
