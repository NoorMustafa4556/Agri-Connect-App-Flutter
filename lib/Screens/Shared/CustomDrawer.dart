import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/AppColors.dart';
import '../../Providers/AuthProvider.dart';
import '../Auth/LoginScreen.dart';
import '../Farmer/FarmerDashboard.dart';
import '../Owner/OwnerDashboard.dart';
import 'ProfileScreen.dart';
import 'ChangePasswordScreen.dart';
import '../Farmer/FarmerHistoryScreen.dart';
import '../Owner/OwnerHistoryScreen.dart';
import '../../Providers/ThemeProvider.dart';

class CustomDrawer extends StatelessWidget {
  final bool isFarmer;

  const CustomDrawer({Key? key, required this.isFarmer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Consumer<AuthProvider>(
            builder: (context, auth, child) {
              final String name = auth.userName ?? (isFarmer ? 'Farmer' : 'Owner');
              final String email = auth.user?.email ?? 'Loading...';
              
              return UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: AppColors.primary),
                accountName: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                accountEmail: Text(email),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: AppColors.white,
                  child: Icon(Icons.person, color: AppColors.primary, size: 40),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.home, color: AppColors.getTextColor(context)),
            title: Text('Home', style: TextStyle(color: AppColors.getTextColor(context))),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => isFarmer ? const FarmerDashboard() : const OwnerDashboard(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.person_outline, color: AppColors.getTextColor(context)),
            title: Text('My Profile', style: TextStyle(color: AppColors.getTextColor(context))),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.history, color: AppColors.getTextColor(context)),
            title: Text('Request History', style: TextStyle(color: AppColors.getTextColor(context))),
            onTap: () {
               Navigator.pop(context);
               Navigator.push(
                 context, 
                 MaterialPageRoute(
                   builder: (_) => isFarmer ? const FarmerHistoryScreen() : const OwnerHistoryScreen()
                 )
               );
            },
          ),
          ListTile(
            leading: Icon(Icons.lock_outline, color: AppColors.getTextColor(context)),
            title: Text('Change Password', style: TextStyle(color: AppColors.getTextColor(context))),
            onTap: () {
               Navigator.pop(context);
               Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()));
            },
          ),
          const Divider(),
          Consumer<ThemeProvider>(
            builder: (context, theme, child) {
              return ListTile(
                leading: Icon(
                  theme.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: AppColors.getTextColor(context),
                ),
                title: Text('Dark Mode', style: TextStyle(color: AppColors.getTextColor(context))),
                trailing: Switch(
                  value: theme.isDarkMode,
                  onChanged: (val) => theme.toggleTheme(),
                  activeColor: AppColors.primary,
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Logout', style: TextStyle(color: AppColors.error)),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
