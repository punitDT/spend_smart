import 'package:flutter/material.dart';

class ExpenseItemWidget extends StatelessWidget {
  final Map<String, dynamic> expense;
  final Function()? onTap;

  const ExpenseItemWidget({Key? key, required this.expense, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                      expense['categoryColor'] ?? Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  IconData(
                    expense['categoryIcon'] ?? Icons.receipt.codePoint,
                    fontFamily: 'MaterialIcons',
                  ),
                  color: expense['categoryColor'] ?? Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense['title'] ?? 'Unnamed Expense',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      expense['date'] != null
                          ? expense['date'].toString().substring(0, 10)
                          : 'No date',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${expense['amount']?.toStringAsFixed(2) ?? '0.00'}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
