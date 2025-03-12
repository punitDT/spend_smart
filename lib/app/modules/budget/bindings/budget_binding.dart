import 'package:get/get.dart';
import '../controllers/budget_controller.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/repositories/category_repository.dart';

class BudgetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CategoryRepository());
    Get.lazyPut(() => TransactionRepository());
    Get.lazyPut<BudgetController>(
      () => BudgetController(
        Get.find<TransactionRepository>(),
        Get.find<CategoryRepository>(),
      ),
    );
  }
}
