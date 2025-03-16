import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:spend_smart/app/data/models/sms.dart';
import 'package:spend_smart/app/data/models/transaction.dart';
import 'package:spend_smart/app/services/platform_service.dart';
import 'package:spend_smart/app/utils/sms_etx.dart';
import '../../../services/permissions_service.dart';
import '../../../utils/logger.dart';

class SmsController extends GetxController {
  static const String _tag = 'SmsController';
  static const platform = MethodChannel('com.spend_smart/native');
  final PermissionsService _permissionsService = Get.put(PermissionsService());

  final RxBool hasSmsPermission = false.obs;
  final RxBool isLoadingSms = false.obs;
  final RxList<SMS> smsList = <SMS>[].obs;

  final Rx<DateTime?> selectedStartDate = Rx<DateTime?>(DateTime.now());
  final Rx<DateTime?> selectedEndDate = Rx<DateTime?>(DateTime.now());

  @override
  void onInit() {
    Logger.i(_tag, 'Initializing SmsController');
    super.onInit();
    checkSmsPermission();
  }

  Future<void> checkSmsPermission() async {
    try {
      Logger.i(_tag, 'Checking SMS permission');
      hasSmsPermission.value = await _permissionsService.checkSmsPermission();
      Logger.i(_tag, 'SMS permission status: ${hasSmsPermission.value}');
      if (hasSmsPermission.value) {
        await fetchSmsTransactions();
      }
    } catch (e, stackTrace) {
      Logger.e(_tag, 'Error checking SMS permission', e, stackTrace);
      hasSmsPermission.value = false;
    }
  }

  Future<void> requestSmsPermission() async {
    try {
      Logger.i(_tag, 'Requesting SMS permission');
      hasSmsPermission.value = await _permissionsService.requestSmsPermission();
      Logger.i(
          _tag, 'SMS permission request result: ${hasSmsPermission.value}');
      if (hasSmsPermission.value) {
        await fetchSmsTransactions();
      } else {
        Logger.w(_tag, 'SMS permission denied by user');
      }
    } catch (e, stackTrace) {
      Logger.e(_tag, 'Error requesting SMS permission', e, stackTrace);
      hasSmsPermission.value = false;
    }
  }

  Future<void> setDateRange(DateTime? start, DateTime? end) async {
    try {
      Logger.i(_tag, 'Setting date range - Start: $start, End: $end');
      if (start != null) {
        selectedStartDate.value = DateTime(start.year, start.month, start.day);
      }
      if (end != null) {
        selectedEndDate.value = DateTime(end.year, end.month, end.day);
      }
      if (hasSmsPermission.value) {
        await fetchSmsTransactions();
      }
    } catch (e, stackTrace) {
      Logger.e(_tag, 'Error setting date range', e, stackTrace);
    }
  }

  Future<void> fetchSmsTransactions() async {
    if (!hasSmsPermission.value) {
      Logger.w(_tag, 'Attempted to fetch SMS without permission');
      return;
    }

    isLoadingSms.value = true;
    try {
      Logger.i(_tag, 'Fetching SMS transactions');
      // Set start date to beginning of the day
      String? startDate = selectedStartDate.value
          ?.copyWith(hour: 0, minute: 0, second: 0, millisecond: 0)
          .toIso8601String();

      // Set end date to end of the day (23:59:59.999)
      String? endDate = selectedEndDate.value
          ?.copyWith(hour: 23, minute: 59, second: 59, millisecond: 999)
          .toIso8601String();

      Logger.i(_tag,
          'Fetching SMS with date range: Start date: $startDate, End date: $endDate');

      final result = await PlatformService().readSmsTransactions(
        startDate: startDate,
        endDate: endDate,
      );

      Logger.i(_tag, 'Raw result from platform: $result');

      List<SMS> parsedResult = List<SMS>.from(
        jsonDecode(result).map((sms) => SMS.fromJson(sms)),
      );

      Logger.i(_tag, 'Parsed result type: ${parsedResult.runtimeType}');

      /// remove sms from list which are not transactions SMS
      /// which does not contain any amount
      /// which does not contain any credit or debit keyword
      /// isPaymentSms is true
      parsedResult =
          parsedResult.where((sms) => sms?.isPaymentSms ?? false).toList();

      smsList.clear();
      smsList(parsedResult);
      Logger.i(_tag, 'Successfully fetched ${smsList.length} SMS messages');
    } on PlatformException catch (e, stackTrace) {
      Logger.e(_tag, 'Platform error while fetching SMS', e, stackTrace);
      Get.snackbar(
        'Error',
        'Failed to fetch SMS messages: ${e.message}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, stackTrace) {
      Logger.e(_tag, 'Error fetching SMS transactions', e, stackTrace);
      Get.snackbar(
        'Error',
        'Failed to fetch SMS messages: $e',
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
