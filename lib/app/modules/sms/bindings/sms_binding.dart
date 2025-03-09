import 'package:get/get.dart';
import '../controllers/sms_controller.dart';
import '../../../services/sms_service.dart';
import '../../../services/permissions_service.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/transaction_repository.dart';

class SmsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PermissionsService());
    Get.lazyPut(() => CategoryRepository());
    Get.lazyPut(() => TransactionRepository());
    Get.lazyPut(() => SmsService());
    Get.lazyPut(
      () => SmsController(
        Get.find<SmsService>(),
        Get.find<PermissionsService>(),
        Get.find<TransactionRepository>(),
      ),
    );
  }
}
