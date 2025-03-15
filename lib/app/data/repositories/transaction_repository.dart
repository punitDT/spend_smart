import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/transaction.dart';

class TransactionRepository {
  static const String _boxName = 'transactions';
  late Box<Transaction> _box;
  final RxList<Transaction> transactions = <Transaction>[].obs;

  Future<void> init() async {
    try {
      if (await Hive.boxExists(_boxName)) {
        // Try to open box without type parameter first
        final box = await Hive.openBox(_boxName);
        // If we succeed, we need to migrate data and recreate the box
        final oldData = box.toMap().map((key, value) {
          final map = Map<String, dynamic>.from(value as Map);
          return MapEntry(key, map);
        });
        await box.deleteFromDisk();

        // Now open with proper type
        _box = await Hive.openBox<Transaction>(_boxName);

        // Migrate old data
        for (var entry in oldData.entries) {
          try {
            final data = entry.value;
            final transaction = Transaction(
              id: data['id'] as String,
              title: data['title'] as String,
              amount: (data['amount'] as num).toDouble(),
              date: DateTime.parse(data['date'] as String),
              category: data['category'] as String,
              type: (data['type'] as String).toLowerCase() == 'expense'
                  ? TransactionType.expense
                  : TransactionType.income,
              description: data['description'] as String?,
              smsId: data['smsId'] as String?,
              transactionId: data['transactionId'] as String?,
            );
            await _box.put(entry.key, transaction);
          } catch (e) {
            print('Failed to migrate transaction: ${e.toString()}');
          }
        }
      } else {
        _box = await Hive.openBox<Transaction>(_boxName);
      }
    } catch (e) {
      // If anything fails, delete the box and create a new one
      if (await Hive.boxExists(_boxName)) {
        await Hive.deleteBoxFromDisk(_boxName);
      }
      _box = await Hive.openBox<Transaction>(_boxName);
    }

    await refreshData();
  }

  Future<void> refreshData() async {
    transactions.assignAll(_box.values);
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
