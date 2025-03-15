import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/data/models/transaction.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register the TransactionType enum adapter
  Hive.registerAdapter(TransactionTypeAdapter());

  // Register the Transaction class adapter
  Hive.registerAdapter(TransactionAdapter());

  runApp(
    GetMaterialApp(
      title: "SpendSmart",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    ),
  );
}
