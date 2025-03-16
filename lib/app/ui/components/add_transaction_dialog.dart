import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:spend_smart/app/data/models/sms.dart';
import 'package:spend_smart/app/utils/sms_etx.dart';
import '../../data/models/transaction.dart';
import '../../modules/expenses/controllers/expenses_controller.dart';
import 'package:intl/intl.dart';

class AddTransactionDialog {
  final Future<bool> Function(Transaction) onAdd;

  /// Constructor for AddTransactionDialog
  final SMS? sms;

  const AddTransactionDialog({required this.onAdd, this.sms});

  Future<void> show() async {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final selectedType = TransactionType.expense.obs;
    final selectedDate = DateTime.now().obs;
    String? selectedCategory;
    final controller = Get.find<ExpensesController>();

    // Initialize selectedCategory if categories exist
    if (controller.categories.isNotEmpty) {
      selectedCategory = controller.categories.first.id;
    }

    // Check if categories are loaded
    if (controller.categories.isEmpty) {
      controller.loadCategories().then((_) {
        if (controller.categories.isNotEmpty) {
          selectedCategory = controller.categories.first.id;
        }
      });
    }

    /// Check if SMS data is provided
    if (sms != null) {
      final smsAmount = sms?.amountFromSms;
      final smsTransId = sms?.transactionIdFromSms;
      final smsTransType = sms?.transactionTypeFromSms;

      if (smsAmount != null) {
        amountController.text = smsAmount.toString();
      }
      if (smsTransId != null) {
        titleController.text = smsTransId.toString();
      }
      selectedType(smsTransType);
      selectedDate(sms?.date ?? DateTime.now());
    }

    await Get.dialog(
      AlertDialog(
        title: const Text('Add Transaction'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Get.theme.colorScheme.primary,
                        width: 1,
                      ),
                    ),
                    child: Obx(
                      () => CupertinoSlidingSegmentedControl<TransactionType>(
                        groupValue: selectedType.value,
                        children: const {
                          TransactionType.expense: Text('Expense'),
                          TransactionType.income: Text('Income'),
                          TransactionType.investment: Text('Investment'),
                        },
                        onValueChanged: (value) {
                          if (value != null) {
                            selectedType.value = value;
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  textInputAction: TextInputAction.next,
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  textInputAction: TextInputAction.next,
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    if (double.tryParse(value!) == null) {
                      return 'Invalid amount';
                    }
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
                  validator: (value) =>
                      value == null ? 'Please select a category' : null,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: Get.context!,
                      initialDate: selectedDate.value,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (pickedDate != null) {
                      selectedDate.value = pickedDate;
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Obx(
                      () => Text(
                        DateFormat('MMM dd, yyyy').format(selectedDate.value),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
                final transaction = Transaction(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  amount: double.parse(amountController.text),
                  date: selectedDate.value,
                  category: selectedCategory!,
                  type: selectedType.value,
                );

                if (await onAdd(transaction)) {
                  Get.back();
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
