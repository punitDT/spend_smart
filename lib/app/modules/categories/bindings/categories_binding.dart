import 'package:get/get.dart';
import '../controllers/categories_controller.dart';
import '../../../data/repositories/category_repository.dart';

class CategoriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoriesController>(
      () => CategoriesController(Get.find<CategoryRepository>()),
    );
  }
}
