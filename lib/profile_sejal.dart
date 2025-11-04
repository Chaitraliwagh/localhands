import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:localhands_app/home/login.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF003C6E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),

      body: Stack(
        children: [
          // 🌊 Ocean Wavy Header
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              height: 220,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF003C6E), Color(0xFF007C91)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // 🧍 Profile Details
          Column(
            children: [
              const SizedBox(height: 60),
              const CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 44,
                  backgroundImage: AssetImage('assets/profilepic.jpg'),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Sejal Patil",
                style: TextStyle(
                  color: Color.fromARGB(255, 8, 8, 8),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Jalgaon, Maharashtra",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 40),

              // Sections
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildSectionHeader("Orders"),
                    _buildTile(Icons.check_circle, "Completed Services"),
                    _buildTile(Icons.cancel, "Cancelled Services"),
                    _buildTile(Icons.timer, "Upcoming Services"),
                    _divider(),

                    _buildSectionHeader("Payments"),
                    _buildTile(Icons.credit_card, "Payment Methods"),
                    _buildTile(
                      Icons.account_balance_wallet,
                      "Wallet & Transactions",
                    ),
                    _buildTile(Icons.receipt_long, "Receipts"),
                    _divider(),

                    _buildSectionHeader("System"),
                    _buildTile(Icons.notifications, "Notifications"),
                    _buildTile(Icons.settings, "Settings"),
                    _buildTile(Icons.help_outline, "Help & Support"),
                    _buildTile(
                      Icons.logout,
                      "Logout",
                      color: Colors.redAccent,
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AuthScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      const Divider(thickness: 1, height: 28, color: Colors.black12);

  Widget _buildSectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      title,
      style: const TextStyle(
        color: Colors.black54,
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
    ),
  );

  Widget _buildTile(
    IconData icon,
    String title, {
    Color? color,
    VoidCallback? onTap,
  }) => ListTile(
    leading: Icon(icon, color: color ?? Colors.teal[700]),
    title: Text(
      title,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
    ),
    onTap: onTap ?? () {},
  );
}

// 🌊 Wave Clipper
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);

    final firstControlPoint = Offset(size.width / 4, size.height);
    final firstEndPoint = Offset(size.width / 2, size.height - 30);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    final secondControlPoint = Offset(size.width * 3 / 4, size.height - 90);
    final secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
