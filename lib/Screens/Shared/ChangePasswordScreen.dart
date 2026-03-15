import 'package:flutter/material.dart';
import '../../utils/AppColors.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
             _buildPasswordField('Old Password'),
             const SizedBox(height: 15),
             _buildPasswordField('New Password'),
             const SizedBox(height: 15),
             _buildPasswordField('Confirm New Password'),
             const SizedBox(height: 30),
             SizedBox(
               width: double.infinity,
               height: 50,
               child: ElevatedButton(
                 onPressed: () {
                   Navigator.pop(context);
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password Updated')));
                 },
                 style: ElevatedButton.styleFrom(
                   backgroundColor: AppColors.primary,
                   foregroundColor: AppColors.white,
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                 ),
                 child: const Text('Update Password', style: TextStyle(fontSize: 16)),
               ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(String hint) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.textLight.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextField(
        obscureText: true,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        ),
      ),
    );
  }
}
