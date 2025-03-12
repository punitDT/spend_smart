import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/category.dart';

class HomeController extends GetxController {
  final TransactionRepository _transactionRepository = TransactionRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();

  var currentIndex = 0.obs;
  var platformVersion = 'Unknown'.obs;

  // Summary data
  final RxDouble totalExpenses = 0.0.obs;
  final RxDouble totalIncome = 0.0.obs;
  final RxList<Transaction> recentTransactions = <Transaction>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isScanning = false.obs; // Add scanning state

  // Update the channel name to match what's defined in MainActivity.kt
  static const platform = MethodChannel('com.spend_smart/native');

  @override
  void onInit() {
    super.onInit();
    getPlatformVersion();
    loadDashboardData();
  }

  Future<void> getPlatformVersion() async {
    try {
      if (Platform.isAndroid) {
        final version =
            await platform.invokeMethod<String>('getPlatformVersion');
        platformVersion.value = version ?? 'Unknown';
      } else {
        platformVersion.value = Platform.operatingSystemVersion;
      }
    } on PlatformException catch (e) {
      platformVersion.value = 'Failed to get platform version: ${e.message}';
    } on MissingPluginException {
      platformVersion.value = Platform.operatingSystemVersion;
    } catch (e) {
      platformVersion.value = 'Error getting platform version: $e';
    }
  }

  Future<void> loadDashboardData() async {
    isLoading.value = true;
    try {
      await Future.wait([loadTransactions(), loadCategories()]);
      calculateTotals();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load dashboard data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadTransactions() async {
    final allTransactions = await _transactionRepository.getAll();
    // Sort by date (newest first) and take only the most recent 5
    allTransactions.sort((a, b) => b.date.compareTo(a.date));
    recentTransactions.assignAll(allTransactions.take(5).toList());
  }

  Future<void> loadCategories() async {
    final allCategories = await _categoryRepository.getAll();
    categories.assignAll(allCategories);
  }

  void calculateTotals() {
    double expenses = 0.0;
    double income = 0.0;

    // We'll calculate for all transactions, not just recent ones
    // In a real app, you might want to filter by current month/week
    for (var transaction in recentTransactions) {
      if (transaction.type == 'expense') {
        expenses += transaction.amount;
      } else {
        income += transaction.amount;
      }
    }

    totalExpenses.value = expenses;
    totalIncome.value = income;
  }

  void changePage(int index) {
    currentIndex.value = index;
  }

  String getCategoryName(String categoryId) {
    final category = categories.firstWhereOrNull((c) => c.id == categoryId);
    return category?.name ?? 'Uncategorized';
  }

  int getCategoryIconCode(String categoryId) {
    final category = categories.firstWhereOrNull((c) => c.id == categoryId);
    return category?.iconCode ?? 0;
  }

  int getCategoryColor(String categoryId) {
    final category = categories.firstWhereOrNull((c) => c.id == categoryId);
    return category?.color ?? 0xFF000000;
  }
}
