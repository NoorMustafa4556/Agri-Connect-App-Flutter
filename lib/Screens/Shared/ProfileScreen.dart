import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/AppColors.dart';
import '../../utils/AssetManager.dart';
import '../../Providers/AuthProvider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  void _showEditProfile(BuildContext context) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.white),
            onPressed: () => _showEditProfile(context),
          )
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          if (auth.user == null) {
            return const Center(child: Text("Please login to view profile."));
          }

          final String name = auth.userName ?? 'User';
          final String email = auth.user?.email ?? 'Unknown Email';
          
          return FutureBuilder<Map<String, dynamic>?>(
            future: auth.getUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final userData = snapshot.data ?? {};
              final String phone = userData['phone'] ?? 'Not provided';
              final String city = userData['city'] ?? 'Unknown location';
              final String role = userData['role'] ?? 'Unknown role';

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Banner & Avatar
                    Container(
                      width: double.infinity,
                      color: AppColors.primary,
                      padding: const EdgeInsets.only(bottom: 30, top: 10),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: AppColors.white,
                            child: CircleAvatar(
                              radius: 56,
                              backgroundColor: AppColors.primaryLight,
                              child: const Icon(Icons.person, size: 60, color: AppColors.white),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(email, style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Info Cards
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildInfoTile(Icons.phone, 'Phone', phone),
                            const Divider(height: 1),
                            _buildInfoTile(Icons.location_city, 'City', city),
                            const Divider(height: 1),
                            _buildInfoTile(Icons.agriculture, 'Account Role', role),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 16, color: AppColors.textDark, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String? _selectedCity = 'Lahore';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
         padding: const EdgeInsets.all(20),
         child: Column(
           children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primaryLight,
                    child: const Icon(Icons.person, size: 50, color: AppColors.white),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: AppColors.white, size: 18),
                  )
                ],
              ),
              const SizedBox(height: 30),
              _buildTextField('Full Name', 'Ali Raza'),
              const SizedBox(height: 15),
              _buildTextField('Email', 'aliraza@gmail.com'),
              const SizedBox(height: 15),
              _buildTextField('Phone Number', '03001234568'),
              const SizedBox(height: 15),
              
              // City Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('City', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 5),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border.all(color: AppColors.textLight.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: AssetManager.areas.contains(_selectedCity) ? _selectedCity : null,
                        hint: const Text('Select City'),
                        isExpanded: true,
                        items: AssetManager.areas.map((String city) {
                          return DropdownMenuItem<String>(
                            value: city,
                            child: Text(city),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedCity = val),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                     Navigator.pop(context); // back to profile
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Updated')));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Save Changes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
           ],
         ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.textLight.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            ),
          ),
        ),
      ],
    );
  }
}
