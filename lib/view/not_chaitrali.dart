import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  final Color bgColor = const Color(0xFFFCFAF8);
  final Color primaryColor = const Color(0xFF1D828E);
  final Color textColor = const Color(0xFF140F1F);

  final List<Map<String, String>> notifications = const [
    {
      "title": "New Job Available",
      "desc": "AC Repair job at MG Road, Pune.",
      "time": "10 mins ago",
      "icon": "work",
      "typeColor": "0xFF1D828E", // primary color
    },
    {
      "title": "Payment Credited",
      "desc": "₹450 credited to your wallet.",
      "time": "1 hour ago",
      "icon": "wallet",
      "typeColor": "0xFF4CAF50", // green
    },
    {
      "title": "Job Completed",
      "desc": "Washing Machine Fix completed successfully.",
      "time": "Yesterday",
      "icon": "check_circle",
      "typeColor": "0xFFFF9800", // orange
    },
  ];

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
            onSelected: (value) {},
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'clear', child: Text('Clear all')),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Text('Settings'),
                  ),
                ],
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          final Color cardColor = Color(
            int.parse(notif["typeColor"]!),
          ).withOpacity(0.1);
          final Color iconColor = Color(int.parse(notif["typeColor"]!));
          return OpenContainer(
            closedElevation: 0,
            openElevation: 6,
            closedColor: Colors.transparent,
            openColor: Colors.white,
            transitionDuration: const Duration(milliseconds: 400),
            closedBuilder:
                (context, _) => Padding(
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
                          getIcon(notif["icon"] ?? ""),
                          color: iconColor,
                          size: 22,
                        ),
                      ),
                      title: Text(
                        notif["title"]!,
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
                            notif["desc"]!,
                            style: GoogleFonts.poppins(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            notif["time"]!,
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
                          color: index == 0 ? iconColor : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
            openBuilder:
                (context, _) => Scaffold(
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
                      notif["title"]!,
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
                                getIcon(notif["icon"] ?? ""),
                                color: iconColor,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                notif["desc"]!,
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
                          "Time: ${notif["time"]}",
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
      ),
    );
  }
}
