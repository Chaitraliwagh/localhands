import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';

class NotificationItem {
  final String title;
  final String desc;
  final String time;
  final String icon;
  final String typeColor;
  bool isRead;

  NotificationItem({
    required this.title,
    required this.desc,
    required this.time,
    required this.icon,
    required this.typeColor,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'desc': desc,
    'time': time,
    'icon': icon,
    'typeColor': typeColor,
    'isRead': isRead,
  };

  static NotificationItem fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        title: json['title'],
        desc: json['desc'],
        time: json['time'],
        icon: json['icon'],
        typeColor: json['typeColor'],
        isRead: json['isRead'],
      );
}

class NotificationService {
  static const String _key = "notifications";
  static final ValueNotifier<List<NotificationItem>> notifier =
      ValueNotifier<List<NotificationItem>>([]);

  static Future<void> init() async {
    notifier.value = await loadNotifications();
  }

  static Future<List<NotificationItem>> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    final list = data
        .map((e) => NotificationItem.fromJson(json.decode(e)))
        .toList();
    notifier.value = list;
    return list;
  }

  static Future<void> saveNotifications(List<NotificationItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final data = items.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList(_key, data);
    notifier.value = List.from(items);
  }

  static Future<void> addNotification(NotificationItem item) async {
    final current = await loadNotifications();
    current.insert(0, item);
    await saveNotifications(current);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    notifier.value = [];
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final Color bgColor = const Color(0xFFFCFAF8);
  final Color primaryColor = const Color(0xFF1D828E);
  final Color textColor = const Color(0xFF140F1F);

  @override
  void initState() {
    super.initState();
    NotificationService.init();
  }

  IconData getIcon(String name) {
    switch (name) {
      case "work":
        return Icons.build_rounded;
      case "wallet":
        return Icons.account_balance_wallet_rounded;
      case "check_circle":
        return Icons.check_circle_rounded;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: SizedBox(
          height: 40,
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search notifications",
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white.withOpacity(0.9),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onSelected: (value) {
              if (value == 'clear') NotificationService.clearAll();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'clear', child: Text('Clear all')),
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
            ],
          ),
        ],
      ),
      body: ValueListenableBuilder<List<NotificationItem>>(
        valueListenable: NotificationService.notifier,
        builder: (context, notifications, _) {
          if (notifications.isEmpty) {
            return Center(
              child: Text(
                "No notifications yet!",
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final Color cardColor = Color(
                int.parse(notif.typeColor),
              ).withOpacity(0.1);
              final Color iconColor = Color(int.parse(notif.typeColor));

              return OpenContainer(
                closedElevation: 0,
                openElevation: 6,
                closedColor: Colors.transparent,
                openColor: Colors.white,
                transitionDuration: const Duration(milliseconds: 400),
                closedBuilder: (context, _) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.white.withOpacity(0.95)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: iconColor.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundColor: cardColor,
                        child: Icon(
                          getIcon(notif.icon),
                          color: iconColor,
                          size: 22,
                        ),
                      ),
                      title: Text(
                        notif.title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          fontSize: 15.5,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            notif.desc,
                            style: GoogleFonts.poppins(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            notif.time,
                            style: GoogleFonts.poppins(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      trailing: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: notif.isRead ? Colors.transparent : iconColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
                openBuilder: (context, _) => Scaffold(
                  appBar: AppBar(
                    backgroundColor: bgColor,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.black87,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: Text(
                      notif.title,
                      style: GoogleFonts.poppins(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: cardColor,
                              child: Icon(
                                getIcon(notif.icon),
                                color: iconColor,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                notif.desc,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Time: ${notif.time}",
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
