import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/AppColors.dart';
import '../../Providers/AuthProvider.dart';
import 'SignUpScreen.dart';
import '../Farmer/FarmerDashboard.dart';
import '../Owner/OwnerDashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isFarmer = false; // true = Farmer, false = Owner (Recipient / Donor logic)
  bool _obscurePassword = true;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await context.read<AuthProvider>().login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        context,
      );
      
      if (!mounted) return;
      
      if (isFarmer) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const FarmerDashboard()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const OwnerDashboard()));
      }
    } catch (e) {
      // Error is handled in the provider
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 80),
            // Logo / Icon
            const Icon(
              Icons.agriculture,
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome Back,',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 5),
            const Text(
              'Sign in to continue',
              style: TextStyle(fontSize: 16, color: AppColors.textLight),
            ),
            const SizedBox(height: 30),

            // Toggle Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isFarmer = true),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isFarmer ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Farmer',
                            style: TextStyle(
                              color: isFarmer ? AppColors.white : AppColors.textDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isFarmer = false),
                        child: Container(
                          decoration: BoxDecoration(
                            color: !isFarmer ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Equipment Owner',
                            style: TextStyle(
                              color: !isFarmer ? AppColors.white : AppColors.textDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Form Fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Email Field
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.email, color: AppColors.textLight),
                          hintText: 'Email',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Email is required';
                          if (!value.contains('@') || !value.contains('.')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Password Field
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock, color: AppColors.textLight),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: AppColors.textLight,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          hintText: 'Password',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Password is required';
                          if (value.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Forgot Password
                    const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Consumer<AuthProvider>(
                          builder: (context, auth, child) {
                            return auth.isLoading
                                ? const CircularProgressIndicator(color: AppColors.white)
                                : const Text(
                                    'Login',
                                    style: TextStyle(fontSize: 18, color: AppColors.white),
                                  );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Create Account Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'New User? ',
                          style: TextStyle(color: AppColors.textDark),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SignUpScreen()),
                            );
                          },
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
