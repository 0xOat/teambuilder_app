import 'dart:math';
import '../models/mcp_tool.dart';

class RandomTool extends McpTool {
  @override
  String get name => "random_generator";

  @override
  Future<String> execute(String input) async {
    final rand = Random();

    if (input.contains("-")) {
      final parts = input.split("-");
      if (parts.length >= 2) {
        int min = int.tryParse(parts[0].trim()) ?? 0;
        int max = int.tryParse(parts[1].trim()) ?? 100;
        if (max > min) {
          return "ได้เลข ${min + rand.nextInt(max - min + 1)}";
        }
      }
    }

    final texts = ["สวัสดี", "Flutter", "AI"];
    if (texts.isNotEmpty) {
      return "สุ่มข้อความ: ${texts[rand.nextInt(texts.length)]}";
    } else {
      return "ไม่มีข้อความให้สุ่ม";
    }
  }
}
