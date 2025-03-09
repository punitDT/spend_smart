import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../expenses/views/expenses_view.dart';
import '../../analytics/views/analytics_view.dart';
import '../../sms/views/sms_view.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        switch (controller.currentIndex.value) {
          case 0:
            return const ExpensesView();
          case 1:
            return const AnalyticsView();
          case 2:
            return const SmsView();
          default:
            return const ExpensesView();
        }
      }),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changePage,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: 'Expenses',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.message), label: 'SMS'),
          ],
        ),
      ),
    );
  }
}
