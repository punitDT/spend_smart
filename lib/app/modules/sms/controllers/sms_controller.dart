import 'package:get/get.dart';
import '../../../data/models/transaction.dart';
import '../../../services/sms_service.dart';
import '../../../services/permissions_service.dart';
import '../../../data/repositories/transaction_repository.dart';

class SmsController extends GetxController {
  final SmsService _smsService;
  final PermissionsService _permissionsService;
  final TransactionRepository _transactionRepository;

  final RxBool isProcessing = false.obs;
  final RxList<Transaction> transactions = <Transaction>[].obs;
  final RxBool hasPermission = false.obs;

  SmsController(
    this._smsService,
    this._permissionsService,
    this._transactionRepository,
  );

  @override
  void onInit() {
    super.onInit();
    checkPermission();
  }

  Future<void> checkPermission() async {
    hasPermission.value = await _permissionsService.checkSmsPermission();
  }

  Future<void> requestPermission() async {
    final granted = await _permissionsService.requestSmsPermission();
    if (!granted) {
      _permissionsService.showPermissionDialog();
    }
    hasPermission.value = granted;
  }

  Future<void> processMessages() async {
    if (!hasPermission.value) {
      await requestPermission();
      return;
    }

    isProcessing.value = true;
    try {
      final newTransactions = await _smsService.processNewTransactions();
      for (var transaction in newTransactions) {
        await _transactionRepository.add(transaction);
      }
      transactions.assignAll(newTransactions);
    } finally {
      isProcessing.value = false;
    }
  }
}
