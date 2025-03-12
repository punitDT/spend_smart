import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 1)
class Category extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String type;

  @HiveField(3)
  int iconCode;

  @HiveField(4)
  int color;

  Category({
    required this.id,
    required this.name,
    required this.type,
    required this.iconCode,
    required this.color,
  });
}
