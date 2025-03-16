import 'package:get/get.dart';
import 'package:spend_smart/app/data/models/sms.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/category.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../utils/logger.dart';
import '../../../ui/components/common_snackbar.dart';

class ExpensesController extends GetxController {
  static const String _tag = 'ExpensesController';
  final _transactionRepository = TransactionRepository.to;
  final CategoryRepository _categoryRepository = CategoryRepository();
  final RxList<Transaction> transactions = <Transaction>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxDouble totalExpenses = 0.0.obs;
  final RxDouble totalIncome = 0.0.obs;

  // Selection state
  final RxBool isSelectionMode = false.obs;
  final RxSet<String> selectedTransactions = <String>{}.obs;

  @override
  void onInit() {
    Logger.i(_tag, 'Initializing ExpensesController');
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      Logger.i(_tag, 'Loading data');
      await Future.wait([loadTransactions(), loadCategories()]);
      calculateTotals();
    } catch (e, stackTrace) {
      Logger.e(_tag, 'Error loading data', e, stackTrace);
      CommonSnackbar.showError(
        'Error',
        'Failed to load data: ${e.toString()}',
      );
    }
  }

  Future<void> loadTransactions() async {
    try {
      Logger.i(_tag, 'Loading transactions');
      final List<Transaction> loadedTransactions =
          await _transactionRepository.getAll();
      transactions(loadedTransactions);
      Logger.i(_tag, 'Loaded ${transactions.length} transactions');
    } catch (e, stackTrace) {
      Logger.e(_tag, 'Error loading transactions', e, stackTrace);
      CommonSnackbar.showError(
        'Error',
        'Failed to load transactions: ${e.toString()}',
      );
    }
  }

  Future<void> loadCategories() async {
    try {
      Logger.i(_tag, 'Loading categories');
      final List<Category> loadedCategories =
          await _categoryRepository.getAll();
      categories(loadedCategories);
      Logger.i(_tag, 'Loaded ${categories.length} categories');
    } catch (e, stackTrace) {
      Logger.e(_tag, 'Error loading categories', e, stackTrace);
      CommonSnackbar.showError(
        'Error',
        'Failed to load categories: ${e.toString()}',
      );
    }
  }

  void calculateTotals() {
    try {
      double expenses = 0;
      double income = 0;

      for (final transaction in transactions) {
        if (transaction.type == TransactionType.expense) {
          expenses += transaction.amount;
        } else if (transaction.type == TransactionType.income) {
          income += transaction.amount;
        }
      }

      totalExpenses.value = expenses;
      totalIncome.value = income;
      Logger.i(
          _tag, 'Calculated totals - Expenses: $expenses, Income: $income');
    } catch (e, stackTrace) {
      Logger.e(_tag, 'Error calculating totals', e, stackTrace);
      CommonSnackbar.showError(
        'Error',
        'Failed to calculate totals: ${e.toString()}',
      );
    }
  }

  Future<bool> validateExpenseLimit(Transaction transaction) async {
    // Check if this expense would exceed the monthly limit
    // Add your validation logic here
    // For now, just return true
    return true;
  }

  bool hasTransactionForSms(SMS sms) {
    return transactions.any((transaction) =>
        transaction.smsDate?.millisecondsSinceEpoch ==
        sms.date.millisecondsSinceEpoch);
  }

  Future<bool> addTransaction(Transaction transaction) async {
    try {
      if (transaction.type == TransactionType.expense &&
          !await validateExpenseLimit(transaction)) {
        CommonSnackbar.showError(
          'Error',
          'This expense would exceed your monthly limit',
        );
        return false;
      }

      await _transactionRepository.addTransaction(transaction);
      await loadTransactions();
      calculateTotals();
      return true;
    } catch (e, stackTrace) {
      Logger.e(_tag, 'Error adding transaction', e, stackTrace);
      CommonSnackbar.showError(
        'Error',
        'Failed to add transaction: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> updateTransaction(Transaction transaction) async {
    try {
      if (transaction.type == TransactionType.expense &&
          !await validateExpenseLimit(transaction)) {
        CommonSnackbar.showError(
          'Error',
          'This expense would exceed your monthly limit',
        );
        return false;
      }

      await _transactionRepository.updateTransaction(transaction);
      await loadTransactions();
      calculateTotals();
      return true;
    } catch (e, stackTrace) {
      Logger.e(_tag, 'Error updating transaction', e, stackTrace);
      CommonSnackbar.showError(
        'Error',
        'Failed to update transaction: ${e.toString()}',
      );
      return false;
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _transactionRepository.deleteTransaction(id);
      await loadTransactions();
      calculateTotals();
      CommonSnackbar.showSuccess(
        'Success',
        'Transaction deleted successfully',
      );
    } catch (e, stackTrace) {
      Logger.e(_tag, 'Error deleting transaction', e, stackTrace);
      CommonSnackbar.showError(
        'Error',
        'Failed to delete transaction: ${e.toString()}',
      );
    }
  }

  Future<void> deleteSelectedTransactions() async {
    try {
      Logger.i(_tag, 'Deleting ${selectedTransactions.length} transactions');
      for (final id in selectedTransactions) {
        await _transactionRepository.deleteTransaction(id);
      }
      await loadTransactions();
      calculateTotals();
      isSelectionMode.value = false;
      selectedTransactions.clear();
      CommonSnackbar.showSuccess(
        'Success',
        'Selected transactions deleted successfully',
      );
    } catch (e, stackTrace) {
      Logger.e(_tag, 'Error deleting transactions', e, stackTrace);
      CommonSnackbar.showError(
        'Error',
        'Failed to delete transactions: ${e.toString()}',
      );
    }
  }

  void toggleSelectionMode() {
    isSelectionMode.value = !isSelectionMode.value;
    if (!isSelectionMode.value) {
      selectedTransactions.clear();
    }
  }

  void toggleTransactionSelection(String transactionId) {
    if (selectedTransactions.contains(transactionId)) {
      selectedTransactions.remove(transactionId);
      if (selectedTransactions.isEmpty) {
        isSelectionMode.value = false;
      }
    } else {
      selectedTransactions.add(transactionId);
    }
  }

  String getCategoryName(String categoryId) {
    final category = categories.firstWhere(
      (category) => category.id == categoryId,
      orElse: () => Category(
        id: '',
        name: 'Unknown',
        type: 'expense',
        iconCode: 0,
        color: 0xFF000000,
      ),
    );
    return category.name;
  }
}
