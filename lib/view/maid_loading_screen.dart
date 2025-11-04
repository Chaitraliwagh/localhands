// maid_loading_screen.dart

import 'package:localhands_app/view/maid.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class MaidLoadingScreen extends StatefulWidget {
  const MaidLoadingScreen({super.key});

  @override
  State<MaidLoadingScreen> createState() => _MaidLoadingScreenState();
}

class _MaidLoadingScreenState extends State<MaidLoadingScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to maid screen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MaidScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
          'assets/chef.json', // Your Lottie file path
          width: 200,
          height: 200,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}