import '../models/mcp_tool.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorTool extends McpTool {
  @override
  String get name => "calculator";

  @override
  Future<String> execute(String input) async {
    try {
      final expressionStr = input.replaceFirst(RegExp(r'คำนวณ'), '').trim();

      Parser parser = Parser();
      Expression exp = parser.parse(expressionStr);

      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);

      return "ผลลัพธ์คือ ${result.toStringAsFixed(2)}";
    } catch (e) {
      return "คำนวณไม่สำเร็จ: $e";
    }
  }
}
