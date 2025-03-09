import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/sms_controller.dart';

class SmsView extends GetView<SmsController> {
  const SmsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmsView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'SmsView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
