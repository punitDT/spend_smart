import 'package:get/get.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/category.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/repositories/category_repository.dart';

class ExpensesController extends GetxController {
  final TransactionRepository _transactionRepository = TransactionRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();

  final RxList<Transaction> transactions = <Transaction>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxDouble totalExpenses = 0.0.obs;
  final RxDouble totalIncome = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    await Future.wait([loadTransactions(), loadCategories()]);
    calculateTotals();
  }

  Future<void> loadTransactions() async {
    final allTransactions = await _transactionRepository.getAll();
    transactions.assignAll(allTransactions);
  }

  Future<void> loadCategories() async {
    final allCategories = await _categoryRepository.getAll();
    categories.assignAll(allCategories);
  }

  void calculateTotals() {
    double expenses = 0.0;
    double income = 0.0;

    for (var transaction in transactions) {
      if (transaction.type == 'expense') {
        expenses += transaction.amount;
      } else {
        income += transaction.amount;
      }
    }

    totalExpenses.value = expenses;
    totalIncome.value = income;
  }

  Future<bool> validateExpenseLimit(Transaction transaction) async {
    double currentExpenses = totalExpenses.value;
    double currentIncome = totalIncome.value;

    // If updating, remove the old transaction amount from the totals
    if (transaction.id.isNotEmpty) {
      final oldTransaction =
          transactions.firstWhereOrNull((t) => t.id == transaction.id);
      if (oldTransaction != null) {
        if (oldTransaction.type == 'expense') {
          currentExpenses -= oldTransaction.amount;
        } else {
          currentIncome -= oldTransaction.amount;
        }
      }
    }

    // Add the new transaction amount
    if (transaction.type == 'expense') {
      currentExpenses += transaction.amount;
    } else {
      currentIncome += transaction.amount;
    }

    // Check if expenses would exceed income
    if (currentExpenses > currentIncome) {
      Get.snackbar(
        'Error',
        'Cannot add expense: Total expenses would exceed total income',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    }
    return true;
  }

  Future<bool> addTransaction(Transaction transaction) async {
    if (transaction.type == 'expense' &&
        !await validateExpenseLimit(transaction)) {
      return false;
    }

    await _transactionRepository.add(transaction);
    await loadTransactions();
    calculateTotals();
    return true;
  }

  Future<bool> updateTransaction(Transaction transaction) async {
    if (transaction.type == 'expense' &&
        !await validateExpenseLimit(transaction)) {
      return false;
    }

    await _transactionRepository.update(transaction);
    await loadTransactions();
    calculateTotals();
    return true;
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionRepository.delete(id);
    await loadTransactions();
    calculateTotals();
  }

  String getCategoryName(String categoryId) {
    final category = categories.firstWhereOrNull((c) => c.id == categoryId);
    return category?.name ?? 'Uncategorized';
  }
}
