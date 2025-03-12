import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../services/permissions_service.dart';

class SmsController extends GetxController {
  static const platform = MethodChannel('com.spend_smart/native');
  final PermissionsService _permissionsService = Get.put(PermissionsService());

  final RxBool hasSmsPermission = false.obs;
  final RxBool isLoadingSms = false.obs;
  final RxList<Map<String, dynamic>> transactions =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    checkSmsPermission();
  }

  Future<void> checkSmsPermission() async {
    hasSmsPermission.value = await _permissionsService.checkSmsPermission();
  }

  Future<void> requestSmsPermission() async {
    hasSmsPermission.value = await _permissionsService.requestSmsPermission();
  }

  Future<void> fetchSmsTransactions() async {
    if (!hasSmsPermission.value) {
      await requestSmsPermission();
      if (!hasSmsPermission.value) return;
    }

    isLoadingSms.value = true;
    try {
      final String result = await platform.invokeMethod('readSmsTransactions');
      final List<dynamic> smsData = json.decode(result);

      transactions.value = smsData.map<Map<String, dynamic>>((transaction) {
        return {
          'date': DateTime.parse(transaction['date']),
          'amount': transaction['amount'],
          'type': transaction['type'],
          'description': transaction['body'],
          'sender': transaction['sender'],
        };
      }).toList();

      if (transactions.isEmpty) {
        Get.snackbar(
          'Info',
          'No SMS transactions found',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch SMS transactions: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingSms.value = false;
    }
  }
}
