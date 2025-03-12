import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/expenses_controller.dart';
import '../../../data/models/transaction.dart';
import '../../../ui/components/transaction_details_dialog.dart';
import '../../../ui/components/add_transaction_dialog.dart';

class ExpensesView extends GetView<ExpensesController> {
  const ExpensesView({Key? key}) : super(key: key);

  /// override
  ExpensesController get controller => Get.put(ExpensesController());

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
        onPressed: () => AddTransactionDialog(
          onAdd: controller.addTransaction,
        ).show(),
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
        onTap: () => TransactionDetailsDialog(
          transaction: transaction,
          categoryName: controller.getCategoryName(transaction.category),
        ).show(),
      ),
    );
  }
}
