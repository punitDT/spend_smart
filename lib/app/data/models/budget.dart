import 'package:hive/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 2)
class Budget extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String category;

  @HiveField(2)
  late double amount;

  @HiveField(3)
  late DateTime startDate;

  @HiveField(4)
  late DateTime endDate;

  @HiveField(5)
  late bool isRecurring;

  @HiveField(6)
  late String? recurringPeriod; // monthly, yearly, etc.

  Budget({
    required this.id,
    required this.category,
    required this.amount,
    required this.startDate,
    required this.endDate,
    this.isRecurring = false,
    this.recurringPeriod,
  });
}
