import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_colors.dart';
import 'LoginScreen.dart';
import '../Farmer/FarmerDashboard.dart';
import '../Owner/OwnerDashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    // Show splash for at least 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is logged in, fetch their role
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          String? role = doc.get('role');
          if (role == 'Farmer') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const FarmerDashboard()));
            return;
          } else if (role == 'Owner') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OwnerDashboard()));
            return;
          }
        }
      } catch (e) {
        print('Error fetching role during splash: $e');
      }
    }
    
    // Default fallback if not logged in or error
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.agriculture, // Placeholder for actual logo
              size: 100,
              color: AppColors.white,
            ),
            const SizedBox(height: 20),
            const Text(
              'AgriConnect',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Rent Farming Equipment Easily',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
            )
          ],
        ),
      ),
    );
  }
}
