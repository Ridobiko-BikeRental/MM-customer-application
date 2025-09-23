import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../API/auth_api.dart'; // Adjust path

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);

  // Wait a moment to ensure token is loaded in AuthProvider constructor
  await Future.delayed(const Duration(seconds: 2));

  // If token exists and user is considered logged in
  if (authProvider.isLoggedIn) {
    // If user profile not yet loaded, fetch user data
    if (authProvider.userId == null) {
      await authProvider.getUserData();
    }
    // Navigate to Home Screen
    Navigator.of(context).pushReplacementNamed('/home_screen');
  } else {
    // No valid token or not logged in, navigate to Login screen
    Navigator.of(context).pushReplacementNamed('/login');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // or your brand color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            // Your splash logo or animation
            FlutterLogo(size: 90),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
