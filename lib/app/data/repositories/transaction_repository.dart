import '../models/transaction.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';

class TransactionRepository {
  static const String boxName = 'transactions';
  Box<Transaction>? _transactionBox;
  final RxList<Transaction> transactions = <Transaction>[].obs;

  bool get isInitialized => _transactionBox != null;

  Future<void> init() async {
    if (!isInitialized) {
      _transactionBox = await Hive.openBox<Transaction>(boxName);
      transactions.assignAll(_transactionBox!.values);
      _listenToBoxChanges();
    }
  }

  void _listenToBoxChanges() {
    _transactionBox!.listenable().addListener(() {
      transactions.assignAll(_transactionBox!.values);
    });
  }

  Future<List<Transaction>> getAll() async {
    await _ensureInitialized();
    return _transactionBox!.values.toList();
  }

  Future<void> add(Transaction transaction) async {
    await _ensureInitialized();
    await _transactionBox!.put(transaction.id, transaction);
  }

  Future<void> update(Transaction transaction) async {
    await _ensureInitialized();
    await _transactionBox!.put(transaction.id, transaction);
  }

  Future<void> delete(String id) async {
    await _ensureInitialized();
    await _transactionBox!.delete(id);
  }

  Future<void> refreshData() async {
    await _ensureInitialized();
    // Force reload data from storage
    transactions.assignAll(_transactionBox!.values);
  }

  Future<void> _ensureInitialized() async {
    if (!isInitialized) {
      await init();
    }
  }
}
