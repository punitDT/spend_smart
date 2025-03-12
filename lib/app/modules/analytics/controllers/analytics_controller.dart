import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/category.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/repositories/category_repository.dart';

class AnalyticsController extends GetxController {
  final TransactionRepository _transactionRepository = TransactionRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();

  final RxList<Transaction> transactions = <Transaction>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxMap<String, double> categoryTotals = <String, double>{}.obs;
  final RxMap<String, double> monthlyTotals = <String, double>{}.obs;
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxInt selectedMonth = DateTime.now().month.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    await Future.wait([loadTransactions(), loadCategories()]);
    calculateCategoryTotals();
    calculateMonthlyTotals();
  }

  Future<void> loadTransactions() async {
    final allTransactions = await _transactionRepository.getAll();
    transactions.assignAll(allTransactions);
  }

  Future<void> loadCategories() async {
    final allCategories = await _categoryRepository.getAll();
    categories.assignAll(allCategories);
  }

  void calculateCategoryTotals() {
    final Map<String, double> totals = {};

    for (var transaction in transactions) {
      if (transaction.date.year == selectedYear.value &&
          transaction.date.month == selectedMonth.value) {
        totals[transaction.category] =
            (totals[transaction.category] ?? 0.0) +
            (transaction.type == 'expense' ? transaction.amount : 0.0);
      }
    }

    categoryTotals.assignAll(totals);
  }

  void calculateMonthlyTotals() {
    final Map<String, double> totals = {};

    for (var transaction in transactions) {
      if (transaction.date.year == selectedYear.value &&
          transaction.type == 'expense') {
        final monthKey = DateFormat('MMM').format(transaction.date);
        totals[monthKey] = (totals[monthKey] ?? 0.0) + transaction.amount;
      }
    }

    monthlyTotals.assignAll(totals);
  }

  void updateSelectedMonth(int month) {
    selectedMonth.value = month;
    calculateCategoryTotals();
  }

  void updateSelectedYear(int year) {
    selectedYear.value = year;
    calculateCategoryTotals();
    calculateMonthlyTotals();
  }

  String getCategoryName(String categoryId) {
    return categories
            .firstWhereOrNull((category) => category.id == categoryId)
            ?.name ??
        'Uncategorized';
  }

  List<MapEntry<String, double>> getSortedCategoryTotals() {
    final entries = categoryTotals.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  double getTotalExpenses() {
    return categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);
  }

  double getPercentageForCategory(String categoryId) {
    final total = getTotalExpenses();
    if (total == 0) return 0;
    return (categoryTotals[categoryId] ?? 0) / total * 100;
  }
}
