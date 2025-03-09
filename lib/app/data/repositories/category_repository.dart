import '../models/category.dart';

class CategoryRepository {
  final List<Category> _categories = [];

  Future<List<Category>> getAll() async {
    return _categories;
  }

  Future<void> add(Category category) async {
    _categories.add(category);
  }

  Future<void> update(Category category) async {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
    }
  }

  Future<void> delete(String id) async {
    _categories.removeWhere((c) => c.id == id);
  }
}
