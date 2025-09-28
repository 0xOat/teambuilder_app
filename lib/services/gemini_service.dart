import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'mcp_server.dart';

class GeminiService {
  final McpServer _mcp = McpServer();

  Future<String> sendMessage(String userMessage) async {
    final toolResult = await _mcp.tryHandle(userMessage);
    if (toolResult != null) return toolResult;

    final response = await http.post(
      Uri.parse("${ApiConfig.geminiUrl}?key=${ApiConfig.geminiKey}"),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": userMessage}
            ]
          }
        ]
      }),
    );

    final data = jsonDecode(response.body);

    if (data["candidates"] != null &&
        data["candidates"].isNotEmpty &&
        data["candidates"][0]["content"] != null &&
        data["candidates"][0]["content"]["parts"] != null &&
        data["candidates"][0]["content"]["parts"].isNotEmpty) {
      return data["candidates"][0]["content"]["parts"][0]["text"] ?? "No content";
    }

    if (data["error"] != null) {
      return "API Error: ${data["error"]["message"]}";
    }

    return "Unexpected response: ${response.body}";
  }
}
