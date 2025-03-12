import 'package:flutter/material.dart';

class BudgetProgressCard extends StatelessWidget {
  final String title;
  final double currentAmount;
  final double budgetLimit;
  final Color progressColor;

  const BudgetProgressCard({
    Key? key,
    required this.title,
    required this.currentAmount,
    required this.budgetLimit,
    this.progressColor = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double progress =
        budgetLimit > 0 ? (currentAmount / budgetLimit).clamp(0.0, 1.0) : 0.0;
    final bool isOverBudget = currentAmount > budgetLimit;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${currentAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isOverBudget ? Colors.red : Colors.black,
                  ),
                ),
                Text(
                  'of \$${budgetLimit.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? Colors.red : progressColor,
              ),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              isOverBudget
                  ? 'Over budget by \$${(currentAmount - budgetLimit).toStringAsFixed(2)}'
                  : 'Remaining: \$${(budgetLimit - currentAmount).toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14,
                color: isOverBudget ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
