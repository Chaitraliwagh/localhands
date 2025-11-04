import 'package:localhands_app/plumber_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'dart:async';

// Add this loading screen widget
class PlumbingLoadingScreen extends StatefulWidget {
  const PlumbingLoadingScreen({super.key});

  @override
  State<PlumbingLoadingScreen> createState() => _PlumbingLoadingScreenState();
}

class _PlumbingLoadingScreenState extends State<PlumbingLoadingScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to plumbing screen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PlumberScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
          'assets/Tools.json', // Your Lottie file path
          width: 200,
          height: 200,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}