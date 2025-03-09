import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/expenses_controller.dart';
import '../../../data/models/transaction.dart';
import 'package:uuid/uuid.dart';

class ExpensesView extends GetView<ExpensesController> {
  const ExpensesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadData(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCard(),
          Expanded(child: _buildTransactionList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'Income',
                controller.totalIncome.value,
                Colors.green,
              ),
              _buildSummaryItem(
                'Expenses',
                controller.totalExpenses.value,
                Colors.red,
              ),
              _buildSummaryItem(
                'Balance',
                controller.totalIncome.value - controller.totalExpenses.value,
                Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        Text(
          NumberFormat.currency(symbol: '₹').format(amount),
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    return Obx(
      () => ListView.builder(
        itemCount: controller.transactions.length,
        itemBuilder: (context, index) {
          final transaction = controller.transactions[index];
          return _buildTransactionItem(transaction);
        },
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isExpense = transaction.type == 'expense';
    final amount = NumberFormat.currency(
      symbol: '₹',
    ).format(transaction.amount);
    final date = DateFormat('MMM dd, yyyy').format(transaction.date);

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => controller.deleteTransaction(transaction.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isExpense ? Colors.red : Colors.green,
          child: Icon(
            isExpense ? Icons.remove : Icons.add,
            color: Colors.white,
          ),
        ),
        title: Text(transaction.title),
        subtitle: Text(
          '${controller.getCategoryName(transaction.category)} • $date',
        ),
        trailing: Text(
          amount,
          style: TextStyle(
            color: isExpense ? Colors.red : Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String selectedType = 'expense';
    String? selectedCategory;

    Get.dialog(
      AlertDialog(
        title: const Text('Add Transaction'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator:
                      (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    if (double.tryParse(value!) == null)
                      return 'Invalid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Obx(
                  () => DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items:
                        controller.categories
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
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Expense'),
                        value: 'expense',
                        groupValue: selectedType,
                        onChanged: (value) => selectedType = value!,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Income'),
                        value: 'income',
                        groupValue: selectedType,
                        onChanged: (value) => selectedType = value!,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final transaction = Transaction(
                  id: const Uuid().v4(),
                  title: titleController.text,
                  amount: double.parse(amountController.text),
                  date: DateTime.now(),
                  category: selectedCategory!,
                  type: selectedType,
                );
                controller.addTransaction(transaction);
                Get.back();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetails(Transaction transaction) {
    Get.dialog(
      AlertDialog(
        title: const Text('Transaction Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${transaction.title}'),
            Text(
              'Amount: ${NumberFormat.currency(symbol: '₹').format(transaction.amount)}',
            ),
            Text(
              'Category: ${controller.getCategoryName(transaction.category)}',
            ),
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
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }
}
