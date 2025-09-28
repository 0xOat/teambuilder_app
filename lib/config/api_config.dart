import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get openaiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static String get openaiUrl => "https://api.openai.com/v1/chat/completions";
  static String get geminiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static String get geminiUrl =>
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";
}