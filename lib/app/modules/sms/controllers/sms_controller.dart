import 'package:get/get.dart';
import '../../../services/permissions_service.dart';

class SmsController extends GetxController {
  final PermissionsService _permissionsService = Get.put(PermissionsService());

  final RxBool hasSmsPermission = false.obs;
  final RxBool isLoadingSms = false.obs;
  final RxList<Map<String, dynamic>> transactions =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    checkSmsPermission();
  }

  Future<void> checkSmsPermission() async {
    hasSmsPermission.value = await _permissionsService.checkSmsPermission();
  }

  Future<void> requestSmsPermission() async {
    hasSmsPermission.value = await _permissionsService.requestSmsPermission();
  }

  Future<void> fetchSmsTransactions() async {
    if (!hasSmsPermission.value) {
      await requestSmsPermission();
      if (!hasSmsPermission.value) return;
    }

    isLoadingSms.value = true;
    try {
      // Implementation for fetching SMS transactions would go here
      // This is just placeholder logic
      await Future.delayed(const Duration(seconds: 2));

      transactions.value = [
        {
          'date': DateTime.now(),
          'amount': 150.0,
          'type': 'debit',
          'description': 'Sample transaction',
        },
        {
          'date': DateTime.now().subtract(const Duration(days: 1)),
          'amount': 75.0,
          'type': 'debit',
          'description': 'Sample transaction 2',
        },
      ];
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch SMS transactions: ${e.toString()}',
      );
    } finally {
      isLoadingSms.value = false;
    }
  }
}
