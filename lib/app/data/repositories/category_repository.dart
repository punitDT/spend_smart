import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryRepository {
  final List<Category> _categories = [
    // Income Categories
    Category(
      id: 'salary',
      name: 'Salary',
      type: 'income',
      iconCode: Icons.account_balance_wallet.codePoint,
      color: Colors.green.value,
    ),
    Category(
      id: 'freelance',
      name: 'Freelance',
      type: 'income',
      iconCode: Icons.work.codePoint,
      color: Colors.blue.value,
    ),
    Category(
      id: 'investments',
      name: 'Investments',
      type: 'income',
      iconCode: Icons.trending_up.codePoint,
      color: Colors.purple.value,
    ),
    Category(
      id: 'bonus',
      name: 'Bonus',
      type: 'income',
      iconCode: Icons.stars.codePoint,
      color: Colors.amber.value,
    ),
    Category(
      id: 'rental',
      name: 'Rental Income',
      type: 'income',
      iconCode: Icons.home.codePoint,
      color: Colors.indigo.value,
    ),
    Category(
      id: 'business',
      name: 'Business Income',
      type: 'income',
      iconCode: Icons.business.codePoint,
      color: Colors.deepPurple.value,
    ),
    Category(
      id: 'interest',
      name: 'Interest',
      type: 'income',
      iconCode: Icons.savings.codePoint,
      color: Colors.lightGreen.value,
    ),

    // Expense Categories
    Category(
      id: 'food',
      name: 'Food & Dining',
      type: 'expense',
      iconCode: Icons.restaurant.codePoint,
      color: Colors.orange.value,
    ),
    Category(
      id: 'transport',
      name: 'Transportation',
      type: 'expense',
      iconCode: Icons.directions_car.codePoint,
      color: Colors.blue.value,
    ),
    Category(
      id: 'shopping',
      name: 'Shopping',
      type: 'expense',
      iconCode: Icons.shopping_bag.codePoint,
      color: Colors.pink.value,
    ),
    Category(
      id: 'bills',
      name: 'Bills & Utilities',
      type: 'expense',
      iconCode: Icons.receipt_long.codePoint,
      color: Colors.red.value,
    ),
    Category(
      id: 'health',
      name: 'Healthcare',
      type: 'expense',
      iconCode: Icons.local_hospital.codePoint,
      color: Colors.teal.value,
    ),
    Category(
      id: 'entertainment',
      name: 'Entertainment',
      type: 'expense',
      iconCode: Icons.movie.codePoint,
      color: Colors.deepOrange.value,
    ),
    Category(
      id: 'rent',
      name: 'Rent/Mortgage',
      type: 'expense',
      iconCode: Icons.house.codePoint,
      color: Colors.brown.value,
    ),
    Category(
      id: 'education',
      name: 'Education',
      type: 'expense',
      iconCode: Icons.school.codePoint,
      color: Colors.cyan.value,
    ),
    Category(
      id: 'travel',
      name: 'Travel',
      type: 'expense',
      iconCode: Icons.flight.codePoint,
      color: Colors.lightBlue.value,
    ),
    Category(
      id: 'fitness',
      name: 'Fitness',
      type: 'expense',
      iconCode: Icons.fitness_center.codePoint,
      color: Colors.deepPurple.value,
    ),
    Category(
      id: 'clothing',
      name: 'Clothing',
      type: 'expense',
      iconCode: Icons.checkroom.codePoint,
      color: const Color(0xFFEC407A).value, // Using pink shade 300 as int
    ),
    Category(
      id: 'insurance',
      name: 'Insurance',
      type: 'expense',
      iconCode: Icons.security.codePoint,
      color: Colors.blueGrey.value,
    ),
    Category(
      id: 'gifts',
      name: 'Gifts & Donations',
      type: 'expense',
      iconCode: Icons.card_giftcard.codePoint,
      color: Colors.redAccent.value,
    ),
    Category(
      id: 'pets',
      name: 'Pets',
      type: 'expense',
      iconCode: Icons.pets.codePoint,
      color: const Color(0xFFA1887F).value, // Using brown shade 300 as int
    ),

    // Additional Income Categories
    Category(
      id: 'dividends',
      name: 'Dividends',
      type: 'income',
      iconCode: Icons.insert_chart.codePoint,
      color: Colors.teal.value,
    ),
    Category(
      id: 'commission',
      name: 'Commission',
      type: 'income',
      iconCode: Icons.monetization_on.codePoint,
      color: Colors.orange.value,
    ),
    Category(
      id: 'pension',
      name: 'Pension',
      type: 'income',
      iconCode: Icons.account_balance.codePoint,
      color: Colors.blueGrey.value,
    ),

    // More Income Categories
    Category(
      id: 'royalties',
      name: 'Royalties',
      type: 'income',
      iconCode: Icons.copyright.codePoint,
      color: Colors.deepPurple.value,
    ),
    Category(
      id: 'consulting',
      name: 'Consulting',
      type: 'income',
      iconCode: Icons.people.codePoint,
      color: Colors.lightGreen.value,
    ),
    Category(
      id: 'stock_trading',
      name: 'Stock Trading',
      type: 'income',
      iconCode: Icons.candlestick_chart.codePoint,
      color: Colors.amber.value,
    ),
    Category(
      id: 'cryptocurrency',
      name: 'Cryptocurrency',
      type: 'income',
      iconCode: Icons.currency_bitcoin.codePoint,
      color: Colors.orange.value,
    ),
    Category(
      id: 'online_sales',
      name: 'Online Sales',
      type: 'income',
      iconCode: Icons.shopping_basket.codePoint,
      color: Colors.cyan.value,
    ),
    Category(
      id: 'teaching',
      name: 'Teaching Income',
      type: 'income',
      iconCode: Icons.cast_for_education.codePoint,
      color: Colors.teal.value,
    ),

    // Additional Expense Categories
    Category(
      id: 'groceries',
      name: 'Groceries',
      type: 'expense',
      iconCode: Icons.shopping_cart.codePoint,
      color: Colors.green.value,
    ),
    Category(
      id: 'internet',
      name: 'Internet & Phone',
      type: 'expense',
      iconCode: Icons.wifi.codePoint,
      color: Colors.lightBlue.value,
    ),
    Category(
      id: 'maintenance',
      name: 'Home Maintenance',
      type: 'expense',
      iconCode: Icons.home_repair_service.codePoint,
      color: Colors.brown.value,
    ),
    Category(
      id: 'hobbies',
      name: 'Hobbies',
      type: 'expense',
      iconCode: Icons.palette.codePoint,
      color: Colors.purple.value,
    ),
    Category(
      id: 'beauty',
      name: 'Beauty & Care',
      type: 'expense',
      iconCode: Icons.spa.codePoint,
      color: Colors.pink.value,
    ),
    Category(
      id: 'books',
      name: 'Books & Media',
      type: 'expense',
      iconCode: Icons.menu_book.codePoint,
      color: Colors.deepOrange.value,
    ),
    Category(
      id: 'electronics',
      name: 'Electronics',
      type: 'expense',
      iconCode: Icons.devices.codePoint,
      color: Colors.grey.value,
    ),
    Category(
      id: 'subscriptions',
      name: 'Subscriptions',
      type: 'expense',
      iconCode: Icons.subscriptions.codePoint,
      color: Colors.indigo.value,
    ),
    Category(
      id: 'car',
      name: 'Car Maintenance',
      type: 'expense',
      iconCode: Icons.car_repair.codePoint,
      color: Colors.blue.value,
    ),

    // More Expense Categories
    Category(
      id: 'office_supplies',
      name: 'Office Supplies',
      type: 'expense',
      iconCode: Icons.edit.codePoint,
      color: Colors.grey.value,
    ),
    Category(
      id: 'gaming',
      name: 'Gaming',
      type: 'expense',
      iconCode: Icons.sports_esports.codePoint,
      color: Colors.deepPurple.value,
    ),
    Category(
      id: 'charity',
      name: 'Charity',
      type: 'expense',
      iconCode: Icons.volunteer_activism.codePoint,
      color: Colors.pink.value,
    ),
    Category(
      id: 'childcare',
      name: 'Childcare',
      type: 'expense',
      iconCode: Icons.child_care.codePoint,
      color: Colors.amber.value,
    ),
    Category(
      id: 'parking',
      name: 'Parking',
      type: 'expense',
      iconCode: Icons.local_parking.codePoint,
      color: Colors.blue.value,
    ),
    Category(
      id: 'taxes',
      name: 'Taxes',
      type: 'expense',
      iconCode: Icons.account_balance.codePoint,
      color: Colors.red.value,
    ),
    Category(
      id: 'music',
      name: 'Music & Audio',
      type: 'expense',
      iconCode: Icons.headphones.codePoint,
      color: Colors.purple.value,
    ),
    Category(
      id: 'legal',
      name: 'Legal Services',
      type: 'expense',
      iconCode: Icons.gavel.codePoint,
      color: Colors.brown.value,
    ),
    Category(
      id: 'pharmacy',
      name: 'Pharmacy',
      type: 'expense',
      iconCode: Icons.medical_services.codePoint,
      color: Colors.green.value,
    ),
    Category(
      id: 'home_decor',
      name: 'Home Decor',
      type: 'expense',
      iconCode: Icons.chair.codePoint,
      color: Colors.orange.value,
    ),
  ];

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
