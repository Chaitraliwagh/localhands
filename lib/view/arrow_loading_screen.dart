// arrow_loading_screen.dart
import 'package:flutter/material.dart';
import 'package:localhands_app/view/workerProfile.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

class ArrowLoadingScreen extends StatefulWidget {
  final Map<String, dynamic> worker;
  final String category;
  
  const ArrowLoadingScreen({
    super.key, 
    required this.worker,
    required this.category
  });

  @override
  State<ArrowLoadingScreen> createState() => _ArrowLoadingScreenState();
}

class _ArrowLoadingScreenState extends State<ArrowLoadingScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to worker profile after 2 seconds
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => WorkerProfilePage(
            profile: widget.worker, 
            category: widget.category
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
          'assets/Sandy_Loading.json', // Your arrow Lottie file path
          width: 200,
          height: 200,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}