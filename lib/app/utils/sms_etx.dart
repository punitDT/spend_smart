import 'package:spend_smart/app/data/models/sms.dart';
import 'package:spend_smart/app/data/models/transaction.dart';

class TransactionsTypeAlias {
  static const List<String> incomeAliases = [
    'income',
    'salary',
    'salary credited',
    'credited by',
    'credit',
    'credited',
    'deposited by',
    'deposited',
    'deposit',
  ];

  static const List<String> expenseAliases = [
    'expense',
    'debit',
    'debited by',
    'debited',
    'withdrawn by',
    'withdrawn',
    'withdrawal',
    'spent',
    'paid',
  ];

  static const List<String> investmentAliases = [
    'investment',
    'invested',
    'invested by',
    'invested in',
    'investing',
    'investing in',
  ];
}

extension SmsEtx on SMS {
  /// extract amount from sms body
  /// use regex to find the amount
  /// e.g. "Rs. 1234.56"
  /// e.g. "Rs 1234.56"
  /// e.g. "1234.56"
  /// e.g. "INR 1234.56"
  /// e.g. "INR. 1234.56"
  /// e.g. "INR 1234"
  /// e.g. "INR. 1234"
  /// e.g. "1234"
  double? get amountFromSms {
    final smsBody = body ?? '';
    final regex = RegExp(r'(\b(?:Rs|INR|₹)\.?\s*(\d+(?:\.\d{1,2})?)\b)');
    final match = regex.firstMatch(smsBody);
    if (match != null && match.groupCount == 2) {
      return double.tryParse(match.group(2) ?? '');
    }
    return null;
  }

  /// extract transaction type from sms
  /// use TransactionsTypeAlias to find the type
  TransactionType get transactionTypeFromSms {
    final smsBody = body?.toLowerCase() ?? '';
    if (TransactionsTypeAlias.incomeAliases
        .any((alias) => smsBody.contains(alias))) {
      return TransactionType.income;
    } else if (TransactionsTypeAlias.expenseAliases
        .any((alias) => smsBody.contains(alias))) {
      return TransactionType.expense;
    } else if (TransactionsTypeAlias.investmentAliases
        .any((alias) => smsBody.contains(alias))) {
      return TransactionType.investment;
    }
    return TransactionType.expense; // Default to expense if not found
  }

  /// extract transaction id from sms body
  String? get transactionIdFromSms {
    final smsBody = body ?? '';
    final regex = RegExp(r'(Refno|Transaction ID|Transaction Number)\s*(\d+)');
    final match = regex.firstMatch(smsBody);
    if (match != null && match.groupCount == 2) {
      return match.group(2);
    }
    return null;
  }

  /// is payment sms
  /// check using TransactionsTypeAlias
  bool get isPaymentSms {
    final smsBody = body?.toLowerCase() ?? '';
    return TransactionsTypeAlias.incomeAliases
            .any((alias) => smsBody.contains(alias)) ||
        TransactionsTypeAlias.expenseAliases
            .any((alias) => smsBody.contains(alias));
  }
}
