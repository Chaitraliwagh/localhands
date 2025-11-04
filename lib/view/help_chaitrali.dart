import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localhands_app/view/chatscreen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});
  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final Color bgColor = const Color(0xFFF2F6FC); // soft professional background
  final Color primaryColor = const Color(0xFF1D828E);
  final Color secondaryColor = const Color(0xFFFEAC5D);
  final Color textColor = const Color(0xFF140F1F);
  final Color cardColor = Colors.white;
  final List<Map<String, String>> _chatMessages = [];
  final TextEditingController _chatController = TextEditingController();

  final List<Map<String, String>> faqs = const [
    {
      "question": "How to accept a job?",
      "answer": "Go to Home screen and tap 'View Details' for the job.",
    },
    {
      "question": "How to withdraw earnings?",
      "answer": "Go to Withdraw section and enter the amount.",
    },
    {
      "question": "How to change online/offline status?",
      "answer": "Tap the toggle on Home top bar.",
    },
  ];

  Color hexToColor(String hex) {
    hex = hex.replaceAll("#", "");
    if (hex.length == 6) hex = "FF$hex";
    return Color(int.parse("0x$hex"));
  }

  Future<void> _confirmAndCall(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Call"),
        content: const Text("Do you want to call support?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Call"),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final url = Uri.parse("tel:+918262058086");
      if (await canLaunchUrl(url)) await launchUrl(url);
    }
  }

  Future<void> _confirmAndEmail(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Email"),
        content: const Text("Do you want to send an email to support?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Open Mail"),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final url = Uri.parse("mailto:support@company.com");
      if (await canLaunchUrl(url)) await launchUrl(url);
    }
  }

  Future<void> _sendChatMessage() async {
    final message = _chatController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _chatMessages.add({"sender": "user", "message": message});
    });
    _chatController.clear();

    try {
      final apiKey = "AIzaSyBUeqPKSmD59WVIGUC_jhRwVDJXpJEOZno";
      final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey",
      );

      const aiContext = """
You are a helpful AI Support Assistant for a worker-help platform.
You assist workers with:
- Job acceptance, cancellation, or payment issues
- Workplace safety and security problems
- Reporting harassment, unsafe conditions, or unfair treatment
- Communication issues with clients or employers
- Motivation, confidence, and stress management
- How to use the app (finding jobs, contacting support, etc.)

Always reply politely, in simple language.
Do not answer random or unrelated topics — only focus on helping the worker.
If a user asks something unrelated, gently redirect them to worker-related help.
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
            "I'm here to help with worker-related issues. Could you please rephrase that?";
        setState(() {
          _chatMessages.add({"sender": "ai", "message": reply});
        });
      } else {
        debugPrint("AI ERROR: ${response.body}");
        setState(() {
          _chatMessages.add({
            "sender": "ai",
            "message": "⚠️ AI connection failed. (${response.statusCode})",
          });
        });
      }
    } catch (e) {
      debugPrint("AI ERROR: $e");
      setState(() {
        _chatMessages.add({
          "sender": "ai",
          "message":
              "⚠️ AI connection error. Please check internet or API key.",
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          "Support",
          style: GoogleFonts.poppins(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // FAQ Header
            Text(
              "Frequently Asked Questions",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 23),
            // FAQ Cards
            ...faqs.map(
              (faq) => Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ExpansionTile(
                  iconColor: primaryColor,
                  collapsedIconColor: primaryColor,
                  title: Text(
                    faq["question"]!,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      fontSize: 15,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      child: Text(
                        faq["answer"]!,
                        style: GoogleFonts.poppins(
                          color: Colors.grey[700],
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            // Quick Contact Header
            Text(
              "Need more help?",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 19),
            // Quick Contact Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _contactButton(
                  context,
                  Icons.phone,
                  "Call",
                  primaryColor,
                  _confirmAndCall,
                ),
                _contactButton(context, Icons.chat, "Chat", primaryColor, (
                  ctx,
                ) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        currentUserId: "worker_456", // for worker
                        chatId: "user_123_worker_456", // same chatId as above
                      ),
                    ),
                  );
                }),

                _contactButton(
                  context,
                  Icons.email,
                  "Email",
                  primaryColor,
                  _confirmAndEmail,
                ),
              ],
            ),
            const SizedBox(height: 22),
            // Query Input
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Write your query… we’ll respond soon",
                  prefixIcon: Icon(Icons.message, color: primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                maxLines: 4,
              ),
            ),
            const SizedBox(height: 20),
            // Gradient Send Button
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Query submitted successfully!"),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [hexToColor("#1D828E"), hexToColor("#1A237E")],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26.withOpacity(0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    splashColor: Colors.white.withOpacity(0.3),
                    highlightColor: Colors.white.withOpacity(0.1),
                    child: Center(
                      child: Text(
                        'Send',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            // ✅ AI Chatbot Section
            Text(
              "AI Chatbot Assistant",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 250,
                    child: ListView.builder(
                      itemCount: _chatMessages.length,
                      padding: const EdgeInsets.all(12),
                      itemBuilder: (context, index) {
                        final msg = _chatMessages[index];
                        final isUser = msg["sender"] == "user";
                        return Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
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
                              style: GoogleFonts.poppins(
                                color: isUser ? Colors.white : textColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _chatController,
                            decoration: InputDecoration(
                              hintText: "Ask me anything...",
                              hintStyle: GoogleFonts.poppins(fontSize: 14),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send, color: primaryColor),
                          onPressed: _sendChatMessage,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    Function(BuildContext) onTap,
  ) {
    return Column(
      children: [
        Ink(
          decoration: ShapeDecoration(
            color: color.withOpacity(0.15),
            shape: const CircleBorder(),
          ),
          child: IconButton(
            icon: Icon(icon, color: color, size: 28),
            onPressed: () => onTap(context),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
