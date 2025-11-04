import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AIChatBotScreen extends StatefulWidget {
  const AIChatBotScreen({super.key});

  @override
  State<AIChatBotScreen> createState() => _AIChatBotScreenState();
}

class _AIChatBotScreenState extends State<AIChatBotScreen> {
  final List<Map<String, String>> _chatMessages = [];
  final TextEditingController _chatController = TextEditingController();
  final FocusNode _chatFocusNode = FocusNode(); // 🆕 ADD THIS LINE

  @override
  void initState() {
    super.initState();
    // 🆕 REMOVE ANY AUTOFOCUS LOGIC OR LEAVE EMPTY
  }

  @override
  void dispose() {
    _chatController.dispose();
    _chatFocusNode.dispose(); // 🆕 ADD THIS LINE
    super.dispose();
  }

  Future<void> _sendChatMessage() async {
    final message = _chatController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _chatMessages.add({"sender": "user", "message": message});
    });
    _chatController.clear();

    try {
      final apiKey = "YOUR_GEMINI_API_KEY";
      final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey",
      );

      const aiContext = """
You are a helpful AI assistant for LocalHands users.
Assist users with:
- Booking issues
- Payment, refund, or reschedule
- Worker communication
- App features or usage guidance
Avoid unrelated chat.
""";

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": "$aiContext\nUser: $message"},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply =
            data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"] ??
                "I'm here to help you with your bookings or app support!";
        setState(() {
          _chatMessages.add({"sender": "ai", "message": reply});
        });
      } else {
        setState(() {
          _chatMessages.add({
            "sender": "ai",
            "message": "⚠️ Failed to connect. Try again later.",
          });
        });
      }
    } catch (e) {
      setState(() {
        _chatMessages.add({
          "sender": "ai",
          "message": "⚠️ Error connecting to AI. Please check internet.",
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1D828E);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("AI Chat Assistant"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final msg = _chatMessages[index];
                final isUser = msg["sender"] == "user";
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? primaryColor.withOpacity(0.9)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      msg["message"]!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    focusNode: _chatFocusNode, // 🆕 ADD THIS LINE
                    autofocus: false, // 🆕 ADD THIS LINE - THIS IS THE KEY FIX
                    decoration: const InputDecoration(
                      hintText: "Ask your question...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: primaryColor),
                  onPressed: _sendChatMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}