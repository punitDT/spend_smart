import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:spend_smart/app/data/models/sms.dart';
import 'package:spend_smart/app/utils/logger.dart';
import 'package:spend_smart/app/utils/sms_etx.dart';
import '../../data/models/transaction.dart';
import '../../modules/expenses/controllers/expenses_controller.dart';
import 'package:intl/intl.dart';
import './common_snackbar.dart';

class AddTransactionDialog {
  final Future<bool> Function(Transaction) onAdd;

  /// Constructor for AddTransactionDialog
  final SMS? sms;

  const AddTransactionDialog({required this.onAdd, this.sms});

  Future<bool?> show() async {
    Logger.i('AddTransactionDialog', 'Showing dialog');

    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final transactionIdController = TextEditingController();
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
      await controller.loadCategories();
      if (controller.categories.isNotEmpty) {
        selectedCategory = controller.categories.first.id;
      }
    }

    /// Check if SMS data is provided
    if (sms != null) {
      final smsAmount = sms?.amountFromSms;
      final smsTransId = sms?.transactionIdFromSms;
      final smsTransType = sms?.transactionTypeFromSms;

      Logger.i('AddTransactionDialog',
          'SMS Data: Amount=$smsAmount, TransId=$smsTransId, Type=$smsTransType');

      // Set a default title based on transaction type and sender
      titleController.text =
          '${smsTransType?.toString().split('.').last ?? 'Transaction'} from ${sms?.sender ?? 'Unknown'}';

      if (smsAmount != null) {
        amountController.text = smsAmount.toString();
      }
      if (smsTransId != null) {
        transactionIdController.text = smsTransId;
      }
      if (smsTransType != null) {
        selectedType.value = smsTransType;
      }

      /// format date
      final smsDate = DateTime.parse((sms?.date ?? DateTime.now()).toString());
      selectedDate(smsDate);
    }

    final result = await Get.dialog<bool>(
      barrierDismissible: false,
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
                  controller: transactionIdController,
                  decoration: const InputDecoration(
                    labelText: 'Transaction ID',
                    hintText: 'Optional reference number',
                  ),
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
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                try {
                  if (selectedCategory == null) {
                    CommonSnackbar.showError(
                      'Error',
                      'Please select a category',
                    );
                    return;
                  }

                  final transaction = Transaction(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text,
                    amount: double.parse(amountController.text),
                    date: selectedDate.value,
                    category: selectedCategory!,
                    type: selectedType.value,
                    transactionId: transactionIdController.text.isEmpty
                        ? null
                        : transactionIdController.text,
                    smsId: sms?.id,
                    smsDate: sms?.date,
                  );

                  if (await onAdd(transaction)) {
                    Logger.i('AddTransactionDialog',
                        'Transaction added: $transaction');
                    Get.back(result: true);
                  }

                  Logger.i('after back AddTransactionDialog',
                      'Transaction added: $transaction');
                } catch (e, stack) {
                  Logger.e('AddTransactionDialog', 'Failed to add transaction',
                      e, stack);
                  CommonSnackbar.showError(
                    'Error',
                    'Failed to add transaction: ${e.toString()}',
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    return result;
  }
}
