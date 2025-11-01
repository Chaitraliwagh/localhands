import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localhands_app/view/help_chaitrali.dart';
import 'package:localhands_app/view/history_chaitrali.dart';
import 'package:localhands_app/home/login.dart';
import 'package:localhands_app/view/profile_chaitrali.dart';
import 'package:localhands_app/view/settings_chaitrali.dart';
import 'package:localhands_app/view/withdraw_chaitrali.dart';

class PartnerSidebar extends StatefulWidget {
  const PartnerSidebar({super.key});

  @override
  State<PartnerSidebar> createState() => _PartnerSidebarState();
}

class _PartnerSidebarState extends State<PartnerSidebar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ... rest of your existing build() and widgets (no change)

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.4),
        body: Stack(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: GestureDetector(
                    onTap: () {},
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.78,
                        height: double.infinity,
                        margin: const EdgeInsets.only(
                          right: 6,
                          top: 6,
                          bottom: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(28),
                            bottomLeft: Radius.circular(28),
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.25),
                              Colors.white.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: hexToColor("#1D6F84").withOpacity(0.35),
                              blurRadius: 30,
                              spreadRadius: 1,
                              offset: const Offset(-8, 0),
                            ),
                            BoxShadow(
                              color: hexToColor("#1A237E").withOpacity(0.25),
                              blurRadius: 45,
                              spreadRadius: 2,
                              offset: const Offset(-10, 0),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(28),
                            bottomLeft: Radius.circular(28),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 35,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildHeader(),
                                  const SizedBox(height: 30),
                                  _buildMenuItem(
                                    Icons.person_outline,
                                    "Profile",
                                  ),
                                  _buildMenuItem(Icons.history, "History"),

                                  _buildMenuItem(
                                    Icons.support_agent_outlined,
                                    "Support",
                                  ),
                                  _buildMenuItem(
                                    Icons.account_balance_wallet_outlined,
                                    "Withdraw",
                                  ),
                                  _buildMenuItem(
                                    Icons.settings_outlined,
                                    "Settings",
                                  ),
                                  _buildMenuItem(
                                    Icons.logout_rounded,
                                    "Logout",
                                  ),
                                  const Spacer(),
                                  _buildPremiumCard(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [hexToColor("#1D828E"), hexToColor("#1A237E")],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const CircleAvatar(
            radius: 36,
            backgroundImage: AssetImage('assets/images/explore.jpeg'),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Chaitrali Wagh",
                style: GoogleFonts.urbanist(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              Text(
                "Software Partner",
                style: GoogleFonts.urbanist(
                  fontSize: 13.5,
                  color: const Color.fromARGB(255, 136, 135, 135),
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(25),
          child: const Icon(
            Icons.close_rounded,
            color: Colors.black87,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          // Navigation logic based on title
          switch (title) {
            case "Profile":
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
              break;
            case "History":
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
              break;
            case "Support":
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SupportScreen()),
              );
              break;
            case "Withdraw":
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WithdrawScreen()),
              );
              break;
            case "Settings":
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
              break;
            case "Logout":
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              );

              break;
          }
        },

        borderRadius: BorderRadius.circular(16),
        splashColor: hexToColor("#1D6F84").withOpacity(0.15),
        highlightColor: hexToColor("#1A237E").withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.4),
            //border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [hexToColor("#1D828E"), hexToColor("#1A237E")],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color hexToColor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  Widget _buildPremiumCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [hexToColor("#1D828E"), hexToColor("#1A237E")],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.workspace_premium_rounded,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Unlock premium features and boost your visibility!",
              style: GoogleFonts.urbanist(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
