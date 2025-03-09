import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import '../data/models/transaction.dart';

class SmsService {
  final SmsQuery _query = SmsQuery();

  Future<List<Transaction>> processNewTransactions() async {
    final messages = await _query.querySms(
      kinds: [SmsQueryKind.inbox],
      count: 100, // Limit to latest 100 messages
    );
    final List<Transaction> transactions = [];

    for (var message in messages) {
      final transaction = _parseTransaction(message);
      if (transaction != null) {
        transactions.add(transaction);
      }
    }

    return transactions;
  }

  Transaction? _parseTransaction(SmsMessage message) {
    // TODO: Implement SMS parsing logic based on bank message formats
    return null;
  }
}
