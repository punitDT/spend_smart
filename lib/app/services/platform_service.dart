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
}
