import 'package:flutter/material.dart';
import '../models/tool_call.dart';

class ToolCallWidget extends StatelessWidget {
  final ToolCall toolCall;

  const ToolCallWidget({super.key, required this.toolCall});

  IconData _getToolIcon(String toolName) {
    switch (toolName) {
      case "calculator":
        return Icons.calculate;
      case "note_manager":
        return Icons.note;
      case "random_generator":
        return Icons.casino;
      case "time_helper":
        return Icons.access_time;
      default:
        return Icons.extension; // default icon
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _getToolIcon(toolCall.toolName),
              color: Colors.blueAccent,
              size: 28,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "🔧 ใช้เครื่องมือ: ${toolCall.toolName}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Input: ${toolCall.input}",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  if (toolCall.result != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      "Result: ${toolCall.result}",
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}