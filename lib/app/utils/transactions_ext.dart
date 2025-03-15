import 'package:spend_smart/app/data/models/transaction.dart';

//// extension on Transaction model

extension TransactionExt on Transaction {
  /// extract transaction id from sms body
  /// its prefixed with refno, transaction id, trans no, etc
  /// e.g. "Refno 1234567890"
  /// e.g. "Transaction ID 1234567890"
  /// e.g. "Transaction Number 1234567890"
  String? get transactionIdFromSms {
    final smsBody = description ?? '';
    final regex = RegExp(r'(Refno|Transaction ID|Transaction Number)\s*(\d+)');
    final match = regex.firstMatch(smsBody);
    if (match != null && match.groupCount == 2) {
      return match.group(2);
    }
    return null;
  }

  /// extract amount from sms body
  /// use regex to find the amount
  /// e.g. "Rs. 1234.56"
  /// e.g. "Rs 1234.56"
  /// e.g. "1234.56"
  /// debited by
  /// credited by
  String? get amountFromSms {
    final smsBody = description ?? '';
    final regex = RegExp(r'(\d+(\.\d{1,2})?)');
    final match = regex.firstMatch(smsBody);
    if (match != null && match.groupCount == 1) {
      return match.group(1);
    }
    return null;
  }

  String get formattedDate => '${date.day}/${date.month}/${date.year}';
  String get formattedAmount => '₹${amount.toStringAsFixed(2)}';
  String get typeLabel => type == 'income' ? 'Income' : 'Expense';
}
