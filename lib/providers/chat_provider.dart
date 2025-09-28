import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../services/gemini_service.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  final GeminiService _aiService = GeminiService();

  List<ChatMessage> get messages => _messages;

  Future<void> sendMessage(String text) async {
    final userMessage = ChatMessage(text: text, sender: MessageSender.user);
    _messages.add(userMessage);
    notifyListeners();

    final aiResponse = await _aiService.sendMessage(text);
    _messages.add(ChatMessage(text: aiResponse, sender: MessageSender.ai));
    notifyListeners();

    print(aiResponse);
  }
}
