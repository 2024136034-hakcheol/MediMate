import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'data/api/gemini_service.dart';
import 'data/local/notification_service.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  GeminiService().init();
  await NotificationService().init();
  runApp(const MediMateApp());
}
