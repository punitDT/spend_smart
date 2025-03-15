import 'dart:convert';
import 'package:flutter/services.dart';

class PlatformService {
  static const platform = MethodChannel('com.spend_smart/native');

  Future<String> getPlatformVersion() async {
    try {
      final String version = await platform.invokeMethod('getPlatformVersion');
      return version;
    } on PlatformException catch (e) {
      return 'Failed to get platform version: ${e.message}';
    }
  }

  Future<String> readSmsTransactions({
    String? startDate,
    String? endDate,
  }) async {
    try {
      // Send the full ISO8601 string to preserve time information
      print('Start Date: $startDate');
      print('End Date: $endDate');

      final String result = await platform.invokeMethod(
        'readSmsTransactions',
        {
          'startDate': startDate,
          'endDate': endDate,
        },
      );

      return result;
    } on PlatformException catch (e) {
      throw Exception('Failed to read SMS: ${e.message}');
    }
  }
}
