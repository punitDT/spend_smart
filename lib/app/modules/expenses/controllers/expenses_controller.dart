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

  Future<void> addTransaction(Transaction transaction) async {
    await _transactionRepository.add(transaction);
    await loadTransactions();
    calculateTotals();
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionRepository.delete(id);
    await loadTransactions();
    calculateTotals();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _transactionRepository.update(transaction);
    await loadTransactions();
    calculateTotals();
  }

  String getCategoryName(String categoryId) {
    final category = categories.firstWhereOrNull((c) => c.id == categoryId);
    return category?.name ?? 'Uncategorized';
  }
}
