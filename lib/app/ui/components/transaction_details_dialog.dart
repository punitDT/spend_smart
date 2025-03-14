import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/transaction.dart';
import '../../modules/expenses/controllers/expenses_controller.dart';

class TransactionDetailsDialog {
  final Transaction transaction;
  final String categoryName;

  const TransactionDetailsDialog({
    required this.transaction,
    required this.categoryName,
  });

  Future<void> show() async {
    final titleController = TextEditingController(text: transaction.title);
    final amountController =
        TextEditingController(text: transaction.amount.toString());
    final formKey = GlobalKey<FormState>();
    final controller = Get.find<ExpensesController>();
    String? selectedCategory = transaction.category;

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Transaction'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  if (double.tryParse(value!) == null) return 'Invalid amount';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: controller.categories
                    .map((category) => DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        ))
                    .toList(),
                onChanged: (value) => selectedCategory = value,
                validator: (value) => value == null ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final updatedTransaction = Transaction(
                  id: transaction.id,
                  title: titleController.text,
                  amount: double.parse(amountController.text),
                  date: transaction.date,
                  category: selectedCategory!,
                  type: transaction.type,
                );
                final success =
                    await controller.updateTransaction(updatedTransaction);
                if (success) {
                  Get.back();
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
