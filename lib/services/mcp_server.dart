 import '../models/mcp_tool.dart';
import '../tools/calculator_tool.dart';
import '../tools/note_tool.dart';
import '../tools/random_tool.dart';
import '../tools/time_tool.dart';

class McpServer {
  final Map<String, McpTool> _tools = {
    "calculator": CalculatorTool(),
    "note_manager": NoteTool(),
    "random_generator": RandomTool(),
    "time_helper": TimeTool(),
  };

  Future<String?> tryHandle(String input) async {
    if (input.contains("คำนวณ")) {
      return _tools["calculator"]?.execute(input);
    } else if (input.contains("บันทึกโน้ต") || input.contains("โน้ต")) {
      return _tools["note_manager"]?.execute(input);
    } else if (input.contains("สุ่ม")) {
      return _tools["random_generator"]?.execute(input);
    } else if (input.contains("เวลา") || input.contains("วันที่")) {
      return _tools["time_helper"]?.execute(input);
    }
    return null;
  }
}
