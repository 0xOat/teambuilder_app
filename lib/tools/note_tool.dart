import '../models/mcp_tool.dart';

class NoteTool extends McpTool {
  final List<String> _notes = [];

  @override
  String get name => "note_manager";

  @override
  Future<String> execute(String input) async {
    if (input.startsWith("list")) {
      return _notes.isEmpty ? "ไม่มีโน้ต" : _notes.join("\n");
    }
    _notes.add(input);
    return "บันทึกโน้ตแล้ว";
  }
}