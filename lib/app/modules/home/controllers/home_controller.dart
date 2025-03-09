import 'package:get/get.dart';

class HomeController extends GetxController {
  final count = 0.obs;
  final RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;

  void changePage(int index) {
    currentIndex.value = index;
  }
}
