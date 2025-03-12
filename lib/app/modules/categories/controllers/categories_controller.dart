import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/category.dart';
import '../../../data/repositories/category_repository.dart';

class CategoriesController extends GetxController {
  final CategoryRepository _categoryRepository;
  final RxList<Category> categories = <Category>[].obs;
  final RxBool isLoading = false.obs;

  // Form controllers for adding/editing categories
  final TextEditingController nameController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final RxInt selectedIconCode = Icons.category.codePoint.obs;
  final RxInt selectedColor = Colors.blue.value.obs;

  CategoriesController(this._categoryRepository);

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  @override
  void onClose() {
    nameController.dispose();
    typeController.dispose();
    super.onClose();
  }

  Future<void> loadCategories() async {
    isLoading.value = true;
    try {
      final allCategories = await _categoryRepository.getAll();
      categories.assignAll(allCategories);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load categories: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      await _categoryRepository.add(category);
      await loadCategories();
      clearForm();
      Get.back(); // Close dialog or form
      Get.snackbar(
        'Success',
        'Category added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add category: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await _categoryRepository.update(category);
      await loadCategories();
      clearForm();
      Get.back(); // Close dialog or form
      Get.snackbar(
        'Success',
        'Category updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update category: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _categoryRepository.delete(id);
      await loadCategories();
      Get.snackbar(
        'Success',
        'Category deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete category: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void setFormForEdit(Category category) {
    nameController.text = category.name;
    typeController.text = category.type;
    selectedIconCode.value = category.iconCode;
    selectedColor.value = category.color;
  }

  void clearForm() {
    nameController.clear();
    typeController.clear();
    selectedIconCode.value = Icons.category.codePoint;
    selectedColor.value = Colors.blue.value;
  }

  void updateSelectedIcon(int iconCode) {
    selectedIconCode.value = iconCode;
  }

  void updateSelectedColor(int color) {
    selectedColor.value = color;
  }
}
