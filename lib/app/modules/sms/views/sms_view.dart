import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spend_smart/app/data/models/sms.dart';
import 'package:spend_smart/app/ui/components/add_transaction_dialog.dart';
import 'package:spend_smart/app/modules/expenses/controllers/expenses_controller.dart';
import '../controllers/sms_controller.dart';

class SmsView extends GetView<SmsController> {
  const SmsView({Key? key}) : super(key: key);

  /// override get.put() sms controller
  SmsController get controller => Get.put(SmsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SMS Messages'), centerTitle: true),
      body: Obx(() {
        if (!controller.hasSmsPermission.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'SMS permission is required to view messages',
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

        return Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: controller.selectedStartDate.value ??
                              DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          controller.setDateRange(
                              picked, controller.selectedEndDate.value);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12.0),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Theme.of(context).dividerColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('From', style: TextStyle(fontSize: 12)),
                            Obx(() => Text(
                                  controller.selectedStartDate.value != null
                                      ? '${controller.selectedStartDate.value!.day}/${controller.selectedStartDate.value!.month}/${controller.selectedStartDate.value!.year}'
                                      : 'Select',
                                  style: const TextStyle(fontSize: 14),
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: controller.selectedEndDate.value ??
                              DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          controller.setDateRange(
                              controller.selectedStartDate.value, picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12.0),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Theme.of(context).dividerColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('To', style: TextStyle(fontSize: 12)),
                            Obx(() => Text(
                                  controller.selectedEndDate.value != null
                                      ? '${controller.selectedEndDate.value!.day}/${controller.selectedEndDate.value!.month}/${controller.selectedEndDate.value!.year}'
                                      : 'Select',
                                  style: const TextStyle(fontSize: 14),
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ElevatedButton.icon(
                onPressed: controller.fetchSmsTransactions,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                ),
              ),
            ),
            Expanded(
              child: controller.smsList.isEmpty
                  ? const Center(child: Text('No SMS messages found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.smsList.length,
                      itemBuilder: (context, index) {
                        final SMS sms = controller.smsList[index];
                        final expensesController =
                            Get.find<ExpensesController>();
                        final bool alreadyAdded =
                            expensesController.hasTransactionForSms(sms);

                        return Card(
                          child: Column(
                            children: [
                              ListTile(
                                title: SelectableText(sms.body),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'From: ${sms.sender}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      'Date: ${sms.date}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    if (alreadyAdded)
                                      Text(
                                        'Transaction already added',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Get.theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                              if (!alreadyAdded)
                                IconButton(
                                  onPressed: () async {
                                    await AddTransactionDialog(
                                      onAdd: controller.addTransaction,
                                      sms: sms,
                                    ).show();

                                    controller.smsList.refresh();
                                  },
                                  icon: const Icon(Icons.add),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }
}
