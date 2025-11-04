import 'dart:async';
import 'package:flutter/material.dart';
import 'package:localhands_app/view/info_chaitrali.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _scaleAnimation;
  late AnimationController _textController;
  late Animation<double> _fadeAnimation;
  late Timer _timer;

  final List<Color> gradientColors = [
    const Color(0xFF1D828E),
    const Color(0xFFFEAC5D),
    const Color.fromARGB(255, 50, 189, 117),
  ];

  @override
  void initState() {
    super.initState();

    // Logo bounce animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );

    // Text fade animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    );

    _logoController.forward();
    _textController.forward();

    _timer = Timer(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BasicInfoScreen()),
      );
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(seconds: 3),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1D828E),
              Color.fromARGB(255, 50, 189, 117).withOpacity(0.9),
              const Color(0xFFFEAC5D).withOpacity(0.6),
            ],

            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Floating background circles for depth
            Positioned(
              top: 80,
              left: -40,
              child: _buildFloatingCircle(90, Colors.white.withOpacity(0.1)),
            ),
            Positioned(
              bottom: 100,
              right: -30,
              child: _buildFloatingCircle(120, Colors.white.withOpacity(0.07)),
            ),
            Positioned(
              top: 200,
              right: 50,
              child: _buildFloatingCircle(40, Colors.white.withOpacity(0.15)),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      height: 110,
                      width: 110,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.handyman,
                        size: 65,
                        color: Color(0xFF1D828E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: const [
                        Text(
                          "ServicePro",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Your trusted service partner",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white70,
                            letterSpacing: 0.5,
                          ),
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

  Widget _buildFloatingCircle(double size, Color color) {
    return AnimatedContainer(
      duration: const Duration(seconds: 3),
      curve: Curves.easeInOut,
      height: size,
      width: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
