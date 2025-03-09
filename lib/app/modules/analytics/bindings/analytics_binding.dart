import 'package:get/get.dart';
import '../controllers/analytics_controller.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/repositories/category_repository.dart';

class AnalyticsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CategoryRepository());
    Get.lazyPut(() => TransactionRepository());
    Get.lazyPut(
      () => AnalyticsController(
        Get.find<TransactionRepository>(),
        Get.find<CategoryRepository>(),
      ),
    );
  }
}
