import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sms_controller.dart';
import '../local_widgets/transaction_item_widget.dart';

class SmsView extends GetView<SmsController> {
  const SmsView({Key? key}) : super(key: key);

  /// override get.put() sms controller

  SmsController get controller => Get.put(SmsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SMS Transactions'), centerTitle: true),
      body: Obx(() {
        if (!controller.hasSmsPermission.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'SMS permission is required to track transactions',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: controller.requestSmsPermission,
                  child: const Text('Grant SMS Permission'),
                ),
              ],
            ),
          );
        }

        if (controller.isLoadingSms.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No SMS transactions found'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: controller.fetchSmsTransactions,
                  child: const Text('Refresh SMS Transactions'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: controller.fetchSmsTransactions,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.transactions.length,
                itemBuilder: (context, index) {
                  final transaction = controller.transactions[index];
                  return TransactionItemWidget(transaction: transaction);
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
