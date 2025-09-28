import 'package:intl/intl.dart';
import '../models/mcp_tool.dart';

class TimeTool extends McpTool {
  @override
  String get name => "time_helper";

  @override
  Future<String> execute(String input) async {
    final now = DateTime.now();
    return "ตอนนี้คือ ${DateFormat('yyyy-MM-dd HH:mm:ss').format(now)}";
  }
}
