import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/budget_controller.dart';

class BudgetView extends GetView<BudgetController> {
  const BudgetView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BudgetView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'BudgetView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
