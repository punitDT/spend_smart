import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/category.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/repositories/category_repository.dart';

class AnalyticsController extends GetxController {
  final TransactionRepository _transactionRepository = TransactionRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();

  final RxList<Category> categories = <Category>[].obs;
  final RxMap<String, double> expenseCategoryTotals = <String, double>{}.obs;
  final RxMap<String, double> incomeCategoryTotals = <String, double>{}.obs;
  final RxMap<String, double> monthlyTotals = <String, double>{}.obs;
  final RxMap<String, Map<String, double>> categoryMonthlyTotals =
      <String, Map<String, double>>{}.obs;
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxInt selectedMonth = DateTime.now().month.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _transactionRepository.init();
    await loadCategories();

    // Listen to transaction changes
    ever(_transactionRepository.transactions, (_) {
      calculateCategoryTotals();
      calculateMonthlyTotals();
      calculateCategoryMonthlyTrends();
    });

    // Initial calculations
    calculateCategoryTotals();
    calculateMonthlyTotals();
    calculateCategoryMonthlyTrends();
  }

  Future<void> refreshData() async {
    await _transactionRepository.refreshData();
    calculateCategoryTotals();
    calculateMonthlyTotals();
    calculateCategoryMonthlyTrends();
  }

  Future<void> loadCategories() async {
    final allCategories = await _categoryRepository.getAll();
    categories.assignAll(allCategories);
  }

  void calculateCategoryTotals() {
    final Map<String, double> expenseTotals = {};
    final Map<String, double> incomeTotals = {};

    for (var transaction in _transactionRepository.transactions) {
      if (transaction.date.year == selectedYear.value &&
          transaction.date.month == selectedMonth.value) {
        final map = transaction.type == TransactionType.expense
            ? expenseTotals
            : incomeTotals;
        map[transaction.category] =
            (map[transaction.category] ?? 0.0) + transaction.amount;
      }
    }

    expenseCategoryTotals.assignAll(expenseTotals);
    incomeCategoryTotals.assignAll(incomeTotals);
  }

  void calculateMonthlyTotals() {
    final Map<String, double> totals = {};

    for (var transaction in _transactionRepository.transactions) {
      if (transaction.date.year == selectedYear.value) {
        final monthKey = DateFormat('MMM').format(transaction.date);
        totals[monthKey] = (totals[monthKey] ?? 0.0) +
            (transaction.type == TransactionType.expense
                ? transaction.amount
                : transaction.amount);
      }
    }

    monthlyTotals.assignAll(totals);
  }

  void calculateCategoryMonthlyTrends() {
    final Map<String, Map<String, double>> trends = {};

    for (var transaction in _transactionRepository.transactions) {
      if (transaction.date.year == selectedYear.value) {
        final monthKey = DateFormat('MMM').format(transaction.date);
        final categoryKey = '${transaction.type}_${transaction.category}';

        if (!trends.containsKey(categoryKey)) {
          trends[categoryKey] = {};
        }

        trends[categoryKey]![monthKey] =
            (trends[categoryKey]![monthKey] ?? 0.0) + transaction.amount;
      }
    }

    categoryMonthlyTotals.assignAll(trends);
  }

  void updateSelectedMonth(int month) {
    selectedMonth.value = month;
    calculateCategoryTotals();
  }

  void updateSelectedYear(int year) {
    selectedYear.value = year;
    calculateCategoryTotals();
    calculateMonthlyTotals();
    calculateCategoryMonthlyTrends();
  }

  String getCategoryName(String categoryId) {
    return categories
            .firstWhereOrNull((category) => category.id == categoryId)
            ?.name ??
        'Uncategorized';
  }

  List<MapEntry<String, double>> getSortedExpenseTotals() {
    final entries = expenseCategoryTotals.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  List<MapEntry<String, double>> getSortedIncomeTotals() {
    final entries = incomeCategoryTotals.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  double getTotalExpenses() {
    return expenseCategoryTotals.values
        .fold(0.0, (sum, amount) => sum + amount);
  }

  double getTotalIncome() {
    return incomeCategoryTotals.values.fold(0.0, (sum, amount) => sum + amount);
  }

  double getPercentageForExpenseCategory(String categoryId) {
    final total = getTotalExpenses();
    if (total == 0) return 0;
    return ((expenseCategoryTotals[categoryId] ?? 0) / total * 100);
  }

  double getPercentageForIncomeCategory(String categoryId) {
    final total = getTotalIncome();
    if (total == 0) return 0;
    return ((incomeCategoryTotals[categoryId] ?? 0) / total * 100);
  }
}
