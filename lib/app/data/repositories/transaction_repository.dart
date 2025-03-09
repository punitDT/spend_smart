import '../models/transaction.dart';

class TransactionRepository {
  final List<Transaction> _transactions = [];

  Future<List<Transaction>> getAll() async {
    return _transactions;
  }

  Future<void> add(Transaction transaction) async {
    _transactions.add(transaction);
  }

  Future<void> update(Transaction transaction) async {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
    }
  }

  Future<void> delete(String id) async {
    _transactions.removeWhere((t) => t.id == id);
  }
}
