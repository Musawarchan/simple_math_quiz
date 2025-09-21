import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Get API key from environment variables or SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final String? envApiKey = dotenv.env['GEMINI_API_KEY'];
  final String? storedApiKey = prefs.getString('gemini_api_key');

  // Use environment variable first, then stored key, then empty string
  final String apiKey = envApiKey ?? storedApiKey ?? '';

  // Initialize Gemini with API key if available
  if (apiKey.isNotEmpty) {
    Gemini.init(apiKey: apiKey);
  }

  runApp(const MathDrillApp());
}
