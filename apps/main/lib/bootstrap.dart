import 'package:flutter/material.dart';
import 'package:core/core.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = FlutterError.presentError;

  await FirebaseService.init(options: DefaultFirebaseOptions.currentPlatform);
  await CrashlyticsService.init();

  final storage = SecureStorageService();
  await storage.init();

  final database = AppDatabase();

  runApp(App(storage: storage, database: database));
}
