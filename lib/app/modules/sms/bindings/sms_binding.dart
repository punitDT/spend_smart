import 'package:get/get.dart';
import '../controllers/sms_controller.dart';
import '../../../services/permissions_service.dart';

class SmsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SmsController>(() => SmsController());
  }
}
