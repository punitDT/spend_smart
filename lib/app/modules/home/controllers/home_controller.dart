import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/category.dart';
import '../../../utils/logger.dart';

class HomeController extends GetxController {
  static const String _tag = 'HomeController';
  final _transactionRepository = TransactionRepository.to;
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
    Logger.i(_tag, 'Initializing HomeController');
    super.onInit();
    _initializeRepositories();
  }

  Future<void> _initializeRepositories() async {
    try {
      Logger.i(_tag, 'Initializing repositories');
      // TransactionRepository is already initialized in main()
      await getPlatformVersion();
      await loadDashboardData();
      Logger.i(_tag, 'Repositories initialized successfully');
    } catch (e, stackTrace) {
      Logger.e(_tag, 'Failed to initialize repositories', e, stackTrace);
      Get.snackbar(
        'Error',
        'Failed to initialize app data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> getPlatformVersion() async {
    try {
      Logger.i(_tag, 'Getting platform version');
      if (Platform.isAndroid) {
        final version =
            await platform.invokeMethod<String>('getPlatformVersion');
        platformVersion.value = version ?? 'Unknown';
        Logger.i(_tag, 'Platform version: ${platformVersion.value}');
      } else {
        platformVersion.value = Platform.operatingSystemVersion;
        Logger.i(_tag, 'Platform version: ${platformVersion.value}');
      }
    } on PlatformException catch (e, stackTrace) {
      Logger.e(_tag, 'Failed to get platform version', e, stackTrace);
      platformVersion.value = 'Failed to get platform version: ${e.message}';
    } on MissingPluginException catch (e, stackTrace) {
      Logger.e(
          _tag, 'Missing plugin while getting platform version', e, stackTrace);
      platformVersion.value = Platform.operatingSystemVersion;
    } catch (e, stackTrace) {
      Logger.e(_tag, 'Error getting platform version', e, stackTrace);
      platformVersion.value = 'Error getting platform version: $e';
    }
  }

  Future<void> loadDashboardData() async {
    Logger.i(_tag, 'Loading dashboard data');
    isLoading.value = true;
    try {
      await Future.wait([loadTransactions(), loadCategories()]);
      calculateTotals();
      Logger.i(_tag, 'Dashboard data loaded successfully');
    } catch (e, stackTrace) {
      Logger.e(_tag, 'Failed to load dashboard data', e, stackTrace);
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
    try {
      Logger.i(_tag, 'Loading transactions');
      final allTransactions = await _transactionRepository.getAll();
      allTransactions.sort((a, b) => b.date.compareTo(a.date));
      recentTransactions.assignAll(allTransactions.take(5).toList());
      Logger.i(_tag,
          'Loaded ${allTransactions.length} transactions, showing recent ${recentTransactions.length}');
    } catch (e, stackTrace) {
      Logger.e(_tag, 'Failed to load transactions', e, stackTrace);
      throw e;
    }
  }

  Future<void> loadCategories() async {
    try {
      Logger.i(_tag, 'Loading categories');
      final allCategories = await _categoryRepository.getAll();
      categories.assignAll(allCategories);
      Logger.i(_tag, 'Loaded ${categories.length} categories');
    } catch (e, stackTrace) {
      Logger.e(_tag, 'Failed to load categories', e, stackTrace);
      throw e;
    }
  }

  void calculateTotals() {
    try {
      Logger.i(_tag, 'Calculating transaction totals');
      double expenses = 0.0;
      double income = 0.0;

      for (var transaction in recentTransactions) {
        if (transaction.type == TransactionType.expense) {
          expenses += transaction.amount;
        } else {
          income += transaction.amount;
        }
      }

      totalExpenses.value = expenses;
      totalIncome.value = income;
      Logger.i(
          _tag, 'Totals calculated - Income: $income, Expenses: $expenses');
    } catch (e, stackTrace) {
      Logger.e(_tag, 'Error calculating totals', e, stackTrace);
    }
  }

  void changePage(int index) {
    Logger.i(_tag, 'Changing page to index: $index');
    currentIndex.value = index;
  }

  String getCategoryName(String categoryId) {
    try {
      final category = categories.firstWhereOrNull((c) => c.id == categoryId);
      final name = category?.name ?? 'Uncategorized';
      Logger.i(_tag, 'Getting category name for ID: $categoryId -> $name');
      return name;
    } catch (e, stackTrace) {
      Logger.e(_tag, 'Error getting category name for ID: $categoryId', e,
          stackTrace);
      return 'Uncategorized';
    }
  }

  int getCategoryIconCode(String categoryId) {
    try {
      final category = categories.firstWhereOrNull((c) => c.id == categoryId);
      final iconCode = category?.iconCode ?? 0;
      Logger.i(
          _tag, 'Getting category icon code for ID: $categoryId -> $iconCode');
      return iconCode;
    } catch (e, stackTrace) {
      Logger.e(_tag, 'Error getting category icon code for ID: $categoryId', e,
          stackTrace);
      return 0;
    }
  }

  int getCategoryColor(String categoryId) {
    try {
      final category = categories.firstWhereOrNull((c) => c.id == categoryId);
      final color = category?.color ?? 0xFF000000;
      Logger.i(_tag, 'Getting category color for ID: $categoryId -> $color');
      return color;
    } catch (e, stackTrace) {
      Logger.e(_tag, 'Error getting category color for ID: $categoryId', e,
          stackTrace);
      return 0xFF000000;
    }
  }
}
