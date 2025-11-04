import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

Color hexToColor(String hex) {
  hex = hex.replaceAll("#", "");
  if (hex.length == 6) hex = "FF$hex";
  return Color(int.parse(hex, radix: 16));
}

class ChatScreen extends StatefulWidget {
  final String currentUserId; // ✅ from user or worker
  final String chatId; // ✅ common room for both

  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.chatId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  DatabaseReference? _chatRef;
  final TextEditingController _msgController = TextEditingController();
  String? userId;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final prefs = await SharedPreferences.getInstance();

    // ✅ Local user ID (unique for device)
    userId = prefs.getString('userId');
    if (userId == null) {
      userId = const Uuid().v4();
      await prefs.setString('userId', userId!);
    }

    // ✅ Create shared chat reference using chatId
    _chatRef = FirebaseDatabase.instance.ref().child(
      'chats/${widget.chatId}/messages',
    );

    setState(() {});
  }

  void sendMessage() {
    if (_msgController.text.trim().isNotEmpty && userId != null) {
      _chatRef!.push().set({
        'text': _msgController.text.trim(),
        'senderId': widget.currentUserId, // ✅ from parameter
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      _msgController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_chatRef == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final gradientColors = [hexToColor("#1D828E"), hexToColor("#1A237E")];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Realtime Messenger'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [hexToColor("#E0F7FA"), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: _chatRef!.orderByChild('timestamp').onValue,
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data is DatabaseEvent &&
                      (snapshot.data! as DatabaseEvent).snapshot.value !=
                          null) {
                    final data = Map<dynamic, dynamic>.from(
                      (snapshot.data! as DatabaseEvent).snapshot.value as Map,
                    );
                    final messages = data.entries.toList()
                      ..sort(
                        (a, b) => a.value['timestamp'].compareTo(
                          b.value['timestamp'],
                        ),
                      );

                    return ListView(
                      padding: const EdgeInsets.all(8),
                      children: messages.map((msg) {
                        final bool isMe =
                            msg.value['senderId'] == widget.currentUserId;

                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: isMe
                                  ? LinearGradient(
                                      colors: [
                                        hexToColor("#1D828E").withOpacity(0.8),
                                        hexToColor("#1A237E").withOpacity(0.9),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : const LinearGradient(
                                      colors: [Colors.white, Colors.white70],
                                    ),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(12),
                                topRight: const Radius.circular(12),
                                bottomLeft: isMe
                                    ? const Radius.circular(12)
                                    : const Radius.circular(0),
                                bottomRight: isMe
                                    ? const Radius.circular(0)
                                    : const Radius.circular(12),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              msg.value['text'] ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                color: isMe ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  } else {
                    return const Center(child: Text('No messages yet...'));
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: hexToColor("#1A237E")),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: hexToColor("#1D828E"),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: sendMessage,
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
}