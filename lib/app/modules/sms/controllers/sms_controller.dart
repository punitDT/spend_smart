import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:spend_smart/app/data/models/transaction.dart';
import 'package:spend_smart/app/services/platform_service.dart';
import '../../../services/permissions_service.dart';

class SmsController extends GetxController {
  static const platform = MethodChannel('com.spend_smart/native');
  final PermissionsService _permissionsService = Get.put(PermissionsService());

  final RxBool hasSmsPermission = false.obs;
  final RxBool isLoadingSms = false.obs;
  final RxList<dynamic> smsList = <dynamic>[].obs;

  final Rx<DateTime?> selectedStartDate = Rx<DateTime?>(DateTime.now());
  final Rx<DateTime?> selectedEndDate = Rx<DateTime?>(DateTime.now());

  @override
  void onInit() {
    super.onInit();
    checkSmsPermission();
  }

  Future<void> checkSmsPermission() async {
    hasSmsPermission.value = await _permissionsService.checkSmsPermission();
    if (hasSmsPermission.value) {
      await fetchSmsTransactions();
    }
  }

  Future<void> requestSmsPermission() async {
    hasSmsPermission.value = await _permissionsService.requestSmsPermission();
    if (hasSmsPermission.value) {
      await fetchSmsTransactions();
    }
  }

  Future<void> setDateRange(DateTime? start, DateTime? end) async {
    if (start != null) {
      selectedStartDate.value = DateTime(start.year, start.month, start.day);
    }
    if (end != null) {
      selectedEndDate.value = DateTime(end.year, end.month, end.day);
    }
    await fetchSmsTransactions();
  }

  Future<void> fetchSmsTransactions() async {
    if (!hasSmsPermission.value) {
      return;
    }

    isLoadingSms.value = true;
    try {
      // Set start date to beginning of the day
      String? startDate = selectedStartDate.value
          ?.copyWith(hour: 0, minute: 0, second: 0, millisecond: 0)
          .toIso8601String();

      // Set end date to end of the day (23:59:59.999)
      String? endDate = selectedEndDate.value
          ?.copyWith(hour: 23, minute: 59, second: 59, millisecond: 999)
          .toIso8601String();

      print('DEBUG: Fetching SMS with date range:');
      print('DEBUG: Start date: $startDate');
      print('DEBUG: End date: $endDate');

      final result = await PlatformService().readSmsTransactions(
        startDate: startDate,
        endDate: endDate,
      );

      print('DEBUG: Raw result from platform: $result');

      List<dynamic> parsedResult = jsonDecode(result);

      print('parsedResult type: ${parsedResult.runtimeType}');

      /// remove sms from list which are not transactions SMS
      /// which does not contain any amount
      /// which does not contain any credit or debit keyword
      parsedResult = parsedResult.where((sms) {
        final String message = sms['body'] ?? '';
        return (message.contains('credited') ||
            message.contains('debited') ||
            message.contains('withdrawn') ||
            message.contains('transferred') ||
            message.contains('received') ||
            message.contains('paid'));
      }).toList();

      smsList.clear();
      smsList(parsedResult);
    } catch (e, stackTrace) {
      print('DEBUG: Error in fetchSmsTransactions: $e');
      print('DEBUG: Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to fetch SMS messages: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingSms.value = false;
    }
  }

  Future<bool> addTransaction(Transaction p1) async {
    return true;
  }
}
