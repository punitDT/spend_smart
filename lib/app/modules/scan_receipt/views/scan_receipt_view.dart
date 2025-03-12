import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/scan_receipt_controller.dart';

class ScanReceiptView extends GetView<ScanReceiptController> {
  const ScanReceiptView({Key? key}) : super(key: key);

  @override
  ScanReceiptController get controller => Get.put(ScanReceiptController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Receipt'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isScanning.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: controller.scanReceipt,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Scan Receipt'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 24),
              if (controller.extractedAmount.isNotEmpty) ...[
                _buildInfoCard(
                  'Amount',
                  '₹${controller.extractedAmount.value}',
                  Icons.currency_rupee,
                ),
                const SizedBox(height: 16),
              ],
              if (controller.extractedDate.isNotEmpty) ...[
                _buildInfoCard(
                  'Date',
                  controller.extractedDate.value,
                  Icons.calendar_today,
                ),
                const SizedBox(height: 16),
              ],
              if (controller.scannedText.isNotEmpty) ...[
                const Text(
                  'Scanned Text:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Card(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Text(controller.scannedText.value),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
