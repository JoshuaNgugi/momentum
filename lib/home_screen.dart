// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:momentum/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Momentum Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              // StreamBuilder in main.dart will automatically navigate to LoginScreen
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Momentum!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('You are logged in.', style: TextStyle(fontSize: 18)),
            // TODO: Add media upload and display features here later
          ],
        ),
      ),
    );
  }
}
