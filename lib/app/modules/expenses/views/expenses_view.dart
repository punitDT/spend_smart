import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/expenses_controller.dart';
import '../../../data/models/transaction.dart';
import '../../../ui/components/transaction_details_dialog.dart';
import '../../../ui/components/add_transaction_dialog.dart';
import '../../../ui/components/delete_confirmation_dialog.dart';

class ExpensesView extends GetView<ExpensesController> {
  const ExpensesView({Key? key}) : super(key: key);

  /// override
  ExpensesController get controller => Get.put(ExpensesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: controller.isSelectionMode.value
            ? Text('${controller.selectedTransactions.length} selected')
            : const Text('Transactions'),
        leading: controller.isSelectionMode.value
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: controller.toggleSelectionMode,
              )
            : null,
        actions: [
          if (controller.isSelectionMode.value)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: controller.selectedTransactions.isNotEmpty
                  ? () async {
                      final confirmed = await _showDeleteSelectedConfirmation();
                      if (confirmed) {
                        controller.deleteSelectedTransactions();
                      }
                    }
                  : null,
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => controller.loadData(),
            ),
          if (!controller.isSelectionMode.value)
            IconButton(
              icon: const Icon(Icons.checklist),
              onPressed: controller.toggleSelectionMode,
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCard(),
          Expanded(child: _buildTransactionList()),
        ],
      ),
      floatingActionButton: Obx(
        () => controller.isSelectionMode.value
            ? const SizedBox()
            : FloatingActionButton(
                onPressed: () => AddTransactionDialog(
                  onAdd: controller.addTransaction,
                ).show(),
                child: const Icon(Icons.add),
              ),
      ),
    );
  }

  Future<bool> _showDeleteSelectedConfirmation() async {
    final result = await DeleteConfirmationDialog(
      title: 'Delete Selected Transactions',
      message:
          'Are you sure you want to delete ${controller.selectedTransactions.length} transactions?',
      onConfirm: controller.deleteSelectedTransactions,
    ).show();
    return result;
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
    final isExpense = transaction.type == TransactionType.expense;
    final amount = NumberFormat.currency(
      symbol: '₹',
    ).format(transaction.amount);
    final date = DateFormat('MMM dd, yyyy').format(transaction.date);

    Future<void> showDeleteConfirmation() async {
      final confirmed = await DeleteConfirmationDialog(
        onConfirm: () => controller.deleteTransaction(transaction.id),
      ).show();
      if (confirmed) {
        // No need to call delete again since onConfirm already does it
      }
    }

    return Obx(() {
      final isSelected =
          controller.selectedTransactions.contains(transaction.id);

      return Dismissible(
        key: Key(transaction.id),
        direction: controller.isSelectionMode.value
            ? DismissDirection.none
            : DismissDirection.endToStart,
        confirmDismiss: (_) async {
          await showDeleteConfirmation();
          return false;
        },
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        child: Container(
          color: isSelected ? Get.theme.colorScheme.primaryContainer : null,
          child: ListTile(
            leading: controller.isSelectionMode.value
                ? Checkbox(
                    value: isSelected,
                    onChanged: (_) =>
                        controller.toggleTransactionSelection(transaction.id),
                  )
                : CircleAvatar(
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  amount,
                  style: TextStyle(
                    color: isExpense ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!controller.isSelectionMode.value)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => showDeleteConfirmation(),
                  ),
              ],
            ),
            onTap: () {
              if (controller.isSelectionMode.value) {
                controller.toggleTransactionSelection(transaction.id);
              } else {
                TransactionDetailsDialog(
                  transaction: transaction,
                  categoryName:
                      controller.getCategoryName(transaction.category),
                ).show();
              }
            },
            selected: isSelected,
            selectedTileColor: Get.theme.colorScheme.primaryContainer,
          ),
        ),
      );
    });
  }
}
