// profile_loading_screen.dart
import 'package:flutter/material.dart';

import 'package:localhands_app/view/booking_new.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

class ProfileLoadingScreen extends StatefulWidget {
  final Map<String, dynamic> professional;
  final String serviceType;
  
  const ProfileLoadingScreen({
    super.key, 
    required this.professional,
    required this.serviceType
  });

  @override
  State<ProfileLoadingScreen> createState() => _ProfileLoadingScreenState();
}

class _ProfileLoadingScreenState extends State<ProfileLoadingScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to profile page after 2 seconds
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ProfessionalProfilePage(
            professional: widget.professional,
            serviceType: widget.serviceType,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/Sandy_Loading.json', // Your profile Lottie file path
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            const Text(
              'Loading Profile...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}