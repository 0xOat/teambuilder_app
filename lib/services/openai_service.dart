import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'mcp_server.dart';

class OpenAIService {
  final McpServer _mcp = McpServer();

  Future<String> sendMessage(String userMessage) async {
    final toolResult = await _mcp.tryHandle(userMessage);
    if (toolResult != null) return toolResult;

    final response = await http.post(
      Uri.parse(ApiConfig.openaiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiConfig.openaiKey}',
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "messages": [
          {"role": "user", "content": userMessage}
        ]
      }),
    );

    final data = jsonDecode(response.body);

    if (data["choices"] != null && data["choices"].isNotEmpty) {
      return data["choices"][0]["message"]["content"] ?? "No content returned";
    } else if (data["error"] != null) {
      return "API Error: ${data["error"]["message"]}";
    } else {
      return "Unexpected response: ${response.body}";
    }
  }
}
