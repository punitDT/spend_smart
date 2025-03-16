import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/transaction.dart';
import '../../utils/logger.dart';

class TransactionRepository extends GetxService {
  static TransactionRepository get to => Get.find<TransactionRepository>();

  static const String _tag = 'TransactionRepository';
  static const String _boxName = 'transactions';
  late Box<Transaction> _box;
  final RxList<Transaction> transactions = <Transaction>[].obs;
  final _isInitialized = false.obs;

  Future<TransactionRepository> init() async {
    if (_isInitialized.value) {
      Logger.i(_tag, 'Repository already initialized');
      return this;
    }

    try {
      Logger.i(_tag, 'Initializing TransactionRepository');
      if (Hive.isBoxOpen(_boxName)) {
        _box = Hive.box<Transaction>(_boxName);
        Logger.i(_tag, 'Using existing box');
      } else if (await Hive.boxExists(_boxName)) {
        try {
          _box = await Hive.openBox<Transaction>(_boxName);
          Logger.i(_tag, 'Opened existing box');
        } catch (e, stackTrace) {
          Logger.e(
              _tag, 'Error opening existing box, will recreate', e, stackTrace);
          if (Hive.isBoxOpen(_boxName)) {
            await Hive.box(_boxName).close();
          }
          await Hive.deleteBoxFromDisk(_boxName);
          _box = await Hive.openBox<Transaction>(_boxName);
        }
      } else {
        Logger.i(_tag, 'Box does not exist, creating new');
        _box = await Hive.openBox<Transaction>(_boxName);
      }

      await refreshData();
      _isInitialized.value = true;
      Logger.i(_tag, 'TransactionRepository initialized successfully');
      return this;
    } catch (e, stackTrace) {
      Logger.e(
          _tag, 'Failed to initialize TransactionRepository', e, stackTrace);
      rethrow;
    }
  }

  Future<void> refreshData() async {
    transactions.assignAll(_box.values);
    Logger.i(_tag, 'Refreshed ${transactions.length} transactions');
  }

  Future<List<Transaction>> getAll() async {
    return _box.values.toList();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _box.put(transaction.id, transaction);
    await refreshData();
  }

  Future<void> deleteTransaction(String id) async {
    await _box.delete(id);
    await refreshData();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _box.put(transaction.id, transaction);
    await refreshData();
  }

  Future<Transaction?> getTransaction(String id) async {
    return _box.get(id);
  }
}
