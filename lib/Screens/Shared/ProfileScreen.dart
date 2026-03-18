import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              final String email = auth.user!.email ?? 'Unknown Email';
              
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
                          color: Theme.of(context).cardColor,
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
                            _buildInfoTile(context, Icons.phone, 'Phone', phone),
                            const Divider(height: 1),
                            _buildInfoTile(context, Icons.location_city, 'City', city),
                            const Divider(height: 1),
                            _buildInfoTile(context, Icons.agriculture, 'Account Role', role),
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

  Widget _buildInfoTile(BuildContext context, IconData icon, String title, String value) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: TextStyle(fontSize: 12, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textGrey : AppColors.textLight)),
      subtitle: Text(
        value,
        style: TextStyle(fontSize: 16, color: AppColors.getTextColor(context), fontWeight: FontWeight.bold),
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _selectedCity;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userData = await auth.getUserData();
    if (userData != null) {
      _nameController.text = userData['fullName'] ?? '';
      _phoneController.text = userData['phone'] ?? '';
      _selectedCity = userData['city'];
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    if (uid.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fullName': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'city': _selectedCity,
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Updated Successfully')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              _buildTextField('Full Name', 'Enter your name', _nameController),
              const SizedBox(height: 15),
              _buildTextField('Phone Number', 'Enter your phone', _phoneController),
              const SizedBox(height: 15),
              
              // City Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('City', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border.all(color: Colors.grey.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: AssetManager.areas.contains(_selectedCity) ? _selectedCity : null,
                        hint: const Text('Select City'),
                        isExpanded: true,
                        dropdownColor: AppColors.getCardColor(context),
                        items: AssetManager.areas.map((String city) {
                          return DropdownMenuItem<String>(
                            value: city,
                            child: Text(city, style: TextStyle(color: AppColors.getTextColor(context))),
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
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: AppColors.white)
                    : const Text('Save Changes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
           ],
         ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.getTextColor(context))),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(color: Colors.grey.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(color: AppColors.getTextColor(context)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textGrey : AppColors.textLight),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            ),
          ),
        ),
      ],
    );
  }
}
