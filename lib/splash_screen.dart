import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:momentum/home_screen.dart';
import 'package:momentum/login_screen.dart';

var logger = Logger();

class SplashScreen extends StatefulWidget {
  static const String routeName = '/splash';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    // Wait for the splash screen duration
    await Future.delayed(const Duration(seconds: 2));

    // Ensure the widget is still mounted before attempting navigation
    if (!mounted) return;

    // Check Firebase Auth status
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is logged in, navigate to Home Screen
      logger.i("User is logged in. Navigating to HomeScreen");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // User is not logged in, navigate to Login Screen
      logger.i("User is not logged in. Navigating to LoginScreen");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/app_icon.png', height: 100, width: 100),
            SizedBox(height: 16),
            Text(
              'Momentum',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            Text(
              "Recap your daily photos and videos",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 87, 1, 102),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
