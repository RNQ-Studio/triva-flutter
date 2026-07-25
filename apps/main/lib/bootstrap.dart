import 'package:flutter/material.dart';
import 'package:core/core.dart';

import 'app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = FlutterError.presentError;

  final storage = SecureStorageService();
  await storage.init();

  final database = AppDatabase();

  runApp(App(storage: storage, database: database));
}
