import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/transaction.dart';
import '../../../data/models/category.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/repositories/category_repository.dart';

class BudgetController extends GetxController {
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;

  final RxList<Transaction> transactions = <Transaction>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxBool isLoading = false.obs;
  final RxMap<String, double> budgetUsage = <String, double>{}.obs;
  final RxMap<String, double> budgetLimits = <String, double>{}.obs;

  // Form controllers for setting budget limits
  final TextEditingController amountController = TextEditingController();
  final RxString selectedCategoryId = ''.obs;

  BudgetController(this._transactionRepository, this._categoryRepository);

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      await Future.wait([loadTransactions(), loadCategories()]);
      calculateBudgetUsage();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load budget data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadTransactions() async {
    final allTransactions = await _transactionRepository.getAll();
    transactions.assignAll(allTransactions);
  }

  Future<void> loadCategories() async {
    final allCategories = await _categoryRepository.getAll();
    categories.assignAll(allCategories);

    // Initialize budget limits if not loaded from database
    // In a real app, these would come from a Budget repository
    for (var category in allCategories) {
      if (!budgetLimits.containsKey(category.id)) {
        budgetLimits[category.id] = 0.0;
      }
    }
  }

  void calculateBudgetUsage() {
    // Reset usage
    final Map<String, double> usage = {};

    // We'll calculate usage for the current month only
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    for (var transaction in transactions) {
      // Only consider expenses for this month
      if (transaction.type == 'expense' &&
          transaction.date.month == currentMonth &&
          transaction.date.year == currentYear) {
        usage[transaction.category] =
            (usage[transaction.category] ?? 0.0) + transaction.amount;
      }
    }

    budgetUsage.assignAll(usage);
  }

  void setSelectedCategory(String categoryId) {
    selectedCategoryId.value = categoryId;

    // Pre-fill the amount if there's an existing budget
    if (budgetLimits.containsKey(categoryId)) {
      amountController.text = budgetLimits[categoryId]!.toString();
    } else {
      amountController.clear();
    }
  }

  void setBudgetLimit() {
    if (selectedCategoryId.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a category',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final double? amount = double.tryParse(amountController.text);
    if (amount == null || amount < 0) {
      Get.snackbar(
        'Error',
        'Please enter a valid amount',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Save the budget limit
    budgetLimits[selectedCategoryId.value] = amount;

    // Clear form
    amountController.clear();
    selectedCategoryId.value = '';

    Get.snackbar(
      'Success',
      'Budget limit updated',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    update(); // Notify listeners to rebuild UI
  }

  String getCategoryName(String categoryId) {
    return categories
            .firstWhereOrNull((category) => category.id == categoryId)
            ?.name ??
        'Unknown';
  }

  double getBudgetPercentage(String categoryId) {
    final limit = budgetLimits[categoryId] ?? 0.0;
    final used = budgetUsage[categoryId] ?? 0.0;

    if (limit <= 0) return 0.0;
    return (used / limit).clamp(0.0, 1.0);
  }

  bool isOverBudget(String categoryId) {
    final limit = budgetLimits[categoryId] ?? 0.0;
    final used = budgetUsage[categoryId] ?? 0.0;

    return limit > 0 && used > limit;
  }

  double getTotalBudget() {
    return budgetLimits.values.fold(0.0, (sum, limit) => sum + limit);
  }

  double getTotalSpent() {
    return budgetUsage.values.fold(0.0, (sum, spent) => sum + spent);
  }

  List<String> getCategoriesWithBudget() {
    return budgetLimits.entries
        .where((entry) => entry.value > 0)
        .map((entry) => entry.key)
        .toList();
  }
}
