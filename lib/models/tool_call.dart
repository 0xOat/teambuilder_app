class ToolCall {
  final String toolName;
  final String input;
  final String? result;

  ToolCall({required this.toolName, required this.input, this.result});
}