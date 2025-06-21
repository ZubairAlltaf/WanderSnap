import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data firestore/posts_data_fst.dart';
import 'login.dart'; // Adjust path based on your structure

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Small delay to show splash screen (optional, for better UX)
    await Future.delayed(const Duration(seconds: 2));

    // Check if user is logged in
    User? user = FirebaseAuth.instance.currentUser;

    if (mounted) {
      // Navigate based on auth status
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => user != null ? const DisplayDataScreen() : const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple, Colors.deepPurpleAccent, Colors.white],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Optional: Add an icon or logo
              const Icon(
                Icons.post_add,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              const Text(
                "My Posts App",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}