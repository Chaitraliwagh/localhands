import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

import 'package:localhands_app/view/docs_chaitrali.dart';
import 'package:localhands_app/view/login.dart';

class BasicInfoScreen extends StatefulWidget {
  const BasicInfoScreen({super.key});

  @override
  State<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends State<BasicInfoScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String? _selectedWorkField;
  late LinearGradient _buttonGradient;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  late AnimationController _fadeController;

  final List<String> workFields = [
    "Electrician",
    "Plumber",
    "Carpenter",
    "Cleaner",
    "Beautician",
    "Technician",
  ];

  @override
  void initState() {
    super.initState();

    // Initialize button gradient
    _buttonGradient = LinearGradient(
      colors: [
        hexToColor("#1D828E"), // teal
        hexToColor("#1A237E"), // dark blue
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    // Background floating animation (keeps repeating)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    // Fade animation (runs once when screen opens)
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _fadeController.forward(); // Only fade in once
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fadeController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    _animationController.stop();
    super.deactivate();
  }

  @override
  void activate() {
    super.activate();
    _animationController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ------------------ Animated Background Shapes ------------------
          Positioned.fill(
            child: RepaintBoundary(
              // prevents unnecessary full rebuilds
              child: CustomPaint(
                painter: _BackgroundPainter(animation: _animationController),
              ),
            ),
          ),

          // ------------------ Main Form Content ------------------
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.black87,
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AuthScreen(),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 10),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: hexToColor("#1A237E"),
                            child: const Text(
                              "1",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Basic Info",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Let’s Get Started 👋",
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          foreground:
                              Paint()
                                ..shader = LinearGradient(
                                  colors: [
                                    hexToColor("#1D828E"),
                                    hexToColor("#1A237E"),
                                  ],
                                ).createShader(
                                  const Rect.fromLTWH(0, 0, 200, 70),
                                ),
                          shadows: [
                            const Shadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Please fill in your basic details",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 40),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        child: _buildInputCard(
                          child: TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: "Full Name",
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              prefixIcon: CircleAvatar(
                                radius: 14,
                                backgroundColor: hexToColor(
                                  "#1A237E",
                                ).withOpacity(0.15),
                                child: Icon(
                                  Icons.person,
                                  color: hexToColor("#1A237E"),
                                ),
                              ),
                              border: InputBorder.none,
                            ),
                            validator:
                                (value) =>
                                    value!.isEmpty
                                        ? "Please enter your name"
                                        : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        child: _buildInputCard(
                          child: DropdownButtonFormField<String>(
                            value: _selectedWorkField,
                            decoration: InputDecoration(
                              labelText: "Work Field",
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              prefixIcon: CircleAvatar(
                                radius: 14,
                                backgroundColor: hexToColor(
                                  "#1D828E",
                                ).withOpacity(0.15),
                                child: Icon(
                                  Icons.work,
                                  color: hexToColor("#1A237E"),
                                ),
                              ),
                              border: InputBorder.none,
                            ),
                            items:
                                workFields.map((field) {
                                  return DropdownMenuItem(
                                    value: field,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.arrow_right,
                                          size: 18,
                                          color: hexToColor("#1A237E"),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(field),
                                      ],
                                    ),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedWorkField = value;
                              });
                            },
                            validator:
                                (value) =>
                                    value == null
                                        ? "Please select your work field"
                                        : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        child: _buildInputCard(
                          child: TextFormField(
                            controller: _addressController,
                            decoration: InputDecoration(
                              labelText: "Address",
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              prefixIcon: CircleAvatar(
                                radius: 14,
                                backgroundColor: hexToColor(
                                  "#1D828E",
                                ).withOpacity(0.15),
                                child: Icon(
                                  Icons.home,
                                  color: hexToColor("#1A237E"),
                                ),
                              ),
                              border: InputBorder.none,
                            ),
                            validator:
                                (value) =>
                                    value!.isEmpty
                                        ? "Please enter your address"
                                        : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTapDown: (_) => setState(() {}),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: _buttonGradient,

                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                splashColor: Colors.white.withOpacity(0.3),
                                highlightColor: Colors.white.withOpacity(0.1),
                                onTap: () {
                                  if (_formKey.currentState!.validate()) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const DocumentationScreen(),
                                      ),
                                    );
                                  }
                                },
                                child: Center(
                                  child: Text(
                                    "Continue",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// Background painter for floating shapes
class _BackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  _BackgroundPainter({required this.animation}) : super(repaint: animation);

  final Random _rand = Random();
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    final double t = animation.value * 2 * pi;
    for (int i = 0; i < 8; i++) {
      final double phase = t + i;
      final double x = (size.width / 8) * i + 50 * sin(phase);
      final double y = 50 * cos(phase) + size.height / 4;
      paint.color = Colors.white.withOpacity(0.08 + i * 0.01);
      canvas.drawCircle(Offset(x, y), 40 + i * 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Utility function
Color hexToColor(String code) {
  return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}
