import 'package:spend_smart/app/data/models/sms.dart';
import 'package:spend_smart/app/data/models/transaction.dart';
import 'package:spend_smart/app/utils/logger.dart';

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
  /// use prefix TransactionsTypeAlias to find the amount
  double? get amountFromSms {
    try {
      final smsBody = body;

      // First try to find amount with currency symbols
      final currencyPattern = RegExp(
        r'(?:Rs\.?|INR|₹)\s*(\d+(?:,\d+)*(?:\.\d{0,2})?)',
        caseSensitive: false,
      );

      var match = currencyPattern.firstMatch(smsBody);
      if (match != null) {
        final amountStr = match.group(1)?.replaceAll(',', '') ?? '';
        final amount = double.tryParse(amountStr);
        if (amount != null) return amount;
      }

      // Get all transaction type aliases
      final allAliases = [
        ...TransactionsTypeAlias.incomeAliases,
        ...TransactionsTypeAlias.expenseAliases,
        ...TransactionsTypeAlias.investmentAliases,
      ];

      // Try to find amount near transaction keywords with simpler pattern
      for (final alias in allAliases) {
        if (smsBody.toLowerCase().contains(alias.toLowerCase())) {
          // Find the index of the alias
          final aliasIndex = smsBody.toLowerCase().indexOf(alias.toLowerCase());
          // Get substring before and after alias (within 50 chars)
          final beforeAlias = smsBody.substring(
            (aliasIndex - 50).clamp(0, aliasIndex),
            aliasIndex,
          );
          final afterAlias = smsBody.substring(
            aliasIndex + alias.length,
            (aliasIndex + alias.length + 50).clamp(0, smsBody.length),
          );

          // Look for amount in both segments
          final amountPattern = RegExp(r'\b(\d+(?:,\d+)*(?:\.\d{0,2})?)\b');
          match = amountPattern.firstMatch(beforeAlias) ??
              amountPattern.firstMatch(afterAlias);

          if (match != null) {
            final amountStr = match.group(1)?.replaceAll(',', '') ?? '';
            final amount = double.tryParse(amountStr);
            if (amount != null) return amount;
          }
        }
      }

      return null;
    } catch (e) {
      Logger.e('SMSEXT amount', 'Error extracting amount from SMS: $e');
      return null;
    }
  }

  /// extract transaction type from sms
  /// use TransactionsTypeAlias to find the type
  TransactionType get transactionTypeFromSms {
    final smsBody = body.toLowerCase();
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
    final smsBody = body;
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
    final smsBody = body.toLowerCase();
    return TransactionsTypeAlias.incomeAliases
            .any((alias) => smsBody.contains(alias)) ||
        TransactionsTypeAlias.expenseAliases
            .any((alias) => smsBody.contains(alias));
  }
}
