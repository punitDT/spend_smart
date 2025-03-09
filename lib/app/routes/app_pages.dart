import 'package:get/get.dart';

import '../modules/analytics/bindings/analytics_binding.dart';
import '../modules/analytics/views/analytics_view.dart';
import '../modules/expenses/bindings/expenses_binding.dart';
import '../modules/expenses/views/expenses_view.dart';
import '../modules/sms/bindings/sms_binding.dart';
import '../modules/sms/views/sms_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.EXPENSES;

  static final routes = [
    GetPage(
      name: Routes.EXPENSES,
      page: () => const ExpensesView(),
      binding: ExpensesBinding(),
    ),
    GetPage(
      name: Routes.SMS,
      page: () => const SmsView(),
      binding: SmsBinding(),
    ),
    GetPage(
      name: Routes.ANALYTICS,
      page: () => const AnalyticsView(),
      binding: AnalyticsBinding(),
    ),
  ];
}
