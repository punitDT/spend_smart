import 'package:get/get.dart';
import '../controllers/expenses_controller.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/repositories/category_repository.dart';

class ExpensesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ExpensesController());
  }
}
