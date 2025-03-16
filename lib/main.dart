import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/data/models/transaction.dart';
import 'app/data/repositories/transaction_repository.dart';
import 'app/routes/app_pages.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();

    // Register the TransactionType enum adapter
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TransactionTypeAdapter());
    }

    // Register the Transaction class adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TransactionAdapter());
    }

    // Initialize repositories
    await Get.putAsync(() => TransactionRepository().init());

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
  } catch (e, stackTrace) {
    debugPrint('Error initializing app: $e\n$stackTrace');
    rethrow;
  }
}
