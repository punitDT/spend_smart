import 'dart:convert';
import 'package:flutter/services.dart';
import '../utils/logger.dart';

class PlatformService {
  static const String _tag = 'PlatformService';
  static const platform = MethodChannel('com.spend_smart/native');

  Future<String> getPlatformVersion() async {
    try {
      Logger.i(_tag, 'Getting platform version');
      final String version = await platform.invokeMethod('getPlatformVersion');
      Logger.i(_tag, 'Platform version: $version');
      return version;
    } on PlatformException catch (e, stackTrace) {
      Logger.e(_tag, 'Platform error getting version', e, stackTrace);
      throw PlatformException(
        code: e.code,
        message: 'Failed to get platform version: ${e.message}',
        details: e.details,
      );
    } catch (e, stackTrace) {
      Logger.e(_tag, 'Error getting platform version', e, stackTrace);
      throw Exception('Failed to get platform version: $e');
    }
  }

  Future<String> readSmsTransactions({
    String? startDate,
    String? endDate,
  }) async {
    try {
      Logger.i(_tag, 'Reading SMS transactions from platform');
      Logger.i(_tag, 'Date range - Start: $startDate, End: $endDate');

      final String result = await platform.invokeMethod(
        'readSmsTransactions',
        {
          'startDate': startDate,
          'endDate': endDate,
        },
      );

      Logger.i(_tag, 'Successfully read SMS transactions from platform');
      return result;
    } on PlatformException catch (e, stackTrace) {
      Logger.e(_tag, 'Platform error reading SMS transactions', e, stackTrace);
      throw PlatformException(
        code: e.code,
        message: 'Failed to read SMS messages: ${e.message}',
        details: e.details,
      );
    } catch (e, stackTrace) {
      Logger.e(_tag, 'Error reading SMS transactions', e, stackTrace);
      throw Exception('Failed to read SMS messages: $e');
    }
  }
}
