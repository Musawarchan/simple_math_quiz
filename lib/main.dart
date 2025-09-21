import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get API key from SharedPreferences or use default
  final prefs = await SharedPreferences.getInstance();
  const String defaultApiKey = 'AIzaSyBjxxkFDEviYxYih8y_5cMBvgCMJTjSEgY';
  final String apiKey = prefs.getString('gemini_api_key') ?? defaultApiKey;

  // Initialize Gemini with API key
  Gemini.init(apiKey: apiKey);

  runApp(const MathDrillApp());
}
