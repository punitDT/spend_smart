import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/models/transaction.dart';

class TransactionDetailsDialog extends StatelessWidget {
  final Transaction transaction;
  final String categoryName;

  const TransactionDetailsDialog({
    Key? key,
    required this.transaction,
    required this.categoryName,
  }) : super(key: key);

  void show() {
    Get.dialog(AlertDialog(
      title: const Text('Transaction Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Title: ${transaction.title}'),
          Text(
            'Amount: ${NumberFormat.currency(symbol: '₹').format(transaction.amount)}',
          ),
          Text('Category: $categoryName'),
          Text('Type: ${transaction.type.capitalizeFirst}'),
          Text(
            'Date: ${DateFormat('MMM dd, yyyy').format(transaction.date)}',
          ),
          if (transaction.description != null)
            Text('Description: ${transaction.description}'),
          if (transaction.smsId != null) const Text('Created from SMS'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Close'),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // This widget doesn't render anything
  }
}
