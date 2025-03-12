import '../models/transaction.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TransactionRepository {
  static const String boxName = 'transactions';
  Box<Transaction>? _transactionBox;

  bool get isInitialized => _transactionBox != null;

  Future<void> init() async {
    if (!isInitialized) {
      _transactionBox = await Hive.openBox<Transaction>(boxName);
    }
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

  Future<void> _ensureInitialized() async {
    if (!isInitialized) {
      await init();
    }
  }
}
