import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'data/api/gemini_service.dart';
import 'app.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  GeminiService().init();
  runApp(const MediMateApp());
}
