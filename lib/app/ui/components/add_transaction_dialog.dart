import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../data/models/transaction.dart';
import '../../modules/expenses/controllers/expenses_controller.dart';
import 'package:intl/intl.dart';

enum TransactionType { expense, income }

class AddTransactionDialog {
  final Future<bool> Function(Transaction) onAdd;

  const AddTransactionDialog({required this.onAdd});

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

    Get.dialog(
      AlertDialog(
        insetPadding: const EdgeInsets.all(16),
        title: const Text('Add Transaction'),
        content: Obx(() {
          if (controller.categories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CupertinoSlidingSegmentedControl<TransactionType>(
                              groupValue: selectedType.value,
                              children: const {
                                TransactionType.expense: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text('Expense'),
                                ),
                                TransactionType.income: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text('Income'),
                                ),
                              },
                              onValueChanged: (value) {
                                if (value != null) {
                                  selectedType.value = value;
                                }
                              },
                            ),
                          ],
                        ),
                      )),
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
                        .map(
                          (category) => DropdownMenuItem(
                            value: category.id,
                            child: Text(category.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => selectedCategory = value,
                    validator: (value) => value == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  // Date picker field
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: Get.context!,
                        initialDate: selectedDate.value,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        selectedDate.value = picked;
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Obx(() => Text(
                            DateFormat('MMM dd, yyyy')
                                .format(selectedDate.value),
                          )),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final transaction = Transaction(
                  id: DateTime.now().microsecondsSinceEpoch.toString(),
                  title: titleController.text,
                  amount: double.parse(amountController.text),
                  date: selectedDate.value,
                  category: selectedCategory!,
                  type: selectedType.value.name,
                );
                final success = await onAdd(transaction);
                if (success) {
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
