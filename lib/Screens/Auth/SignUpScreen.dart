import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/AppColors.dart';
import '../../utils/AssetManager.dart';
import '../../Providers/AuthProvider.dart';
import '../Farmer/FarmerDashboard.dart';
import '../Owner/OwnerDashboard.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool isFarmer = true; // true = Farmer, false = Owner
  bool _obscurePassword = true;

  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rentController = TextEditingController();
  
  // Dropdown States
  String? _selectedArea;
  String? _selectedEquipmentName; 
  String? _selectedEquipmentType;
  File? _selectedEquipmentImage;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickProfileImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _pickEquipmentImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      setState(() {
        _selectedEquipmentImage = File(image.path);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _rentController.dispose();
    super.dispose();
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedArea == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select Area.')));
      return;
    }

    if (!isFarmer) {
      if (_selectedEquipmentName == null || _selectedEquipmentType == null || _selectedEquipmentImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select equipment details and an image.')));
        return;
      }
    }

    try {
      await context.read<AuthProvider>().register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _nameController.text.trim(),
        role: isFarmer ? 'Farmer' : 'Owner',
        city: _selectedArea!,
        phone: _phoneController.text.trim(),
        context: context,
      );

      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null && _profileImage != null) {
        String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
        Reference storageRef = FirebaseStorage.instance.ref().child('profile_images').child(userId).child(fileName);
        UploadTask uploadTask = storageRef.putFile(_profileImage!);
        TaskSnapshot storageSnapshot = await uploadTask;
        String profileImageUrl = await storageSnapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'profileImageUrl': profileImageUrl,
        });
        if (mounted) {
          await context.read<AuthProvider>().refreshUserData();
        }
      }

      // If Owner, save the initial equipment directly to Firestore collection
      if (!isFarmer && _selectedEquipmentName != null && _selectedEquipmentImage != null) {
        if (userId != null) {
          // Upload image to Firebase Storage
          String fileName = 'equipment_${DateTime.now().millisecondsSinceEpoch}.jpg';
          Reference storageRef = FirebaseStorage.instance.ref().child('equipment_images').child(userId).child(fileName);
          UploadTask uploadTask = storageRef.putFile(_selectedEquipmentImage!);
          TaskSnapshot storageSnapshot = await uploadTask;
          String downloadUrl = await storageSnapshot.ref.getDownloadURL();

          await FirebaseFirestore.instance.collection('equipment').add({
             'ownerId': userId,
             'ownerName': _nameController.text.trim(),
             'name': '${_selectedEquipmentName} ($_selectedEquipmentType)',
             'category': _selectedEquipmentName,
             'city': _selectedArea,
             'assetImageRef': downloadUrl,
             'pricePerDay': _rentController.text.trim(),
             'specs': 'Listed during registration',
             'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
      
      if (!mounted) return;
      
      if (isFarmer) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const FarmerDashboard()), (route) => false);
      } else {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const OwnerDashboard()), (route) => false);
      }
    } catch (e) {
      // Handled in provider
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Create Account', style: TextStyle(color: AppColors.white)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile image placeholder
            GestureDetector(
              onTap: _pickProfileImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.getCardColor(context),
                    backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null
                        ? Icon(Icons.camera_alt, size: 40, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textGrey : AppColors.textLight)
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: AppColors.white, size: 20),
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Toggle Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.getCardColor(context),
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
                              color: isFarmer ? AppColors.white : AppColors.getTextColor(context),
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
                              color: !isFarmer ? AppColors.white : AppColors.getTextColor(context),
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
            const SizedBox(height: 20),

            // Form Fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _nameController, 
                      icon: Icons.person, 
                      hint: 'Full Name',
                      context: context,
                      validator: (value) => (value == null || value.trim().isEmpty) ? 'Full Name is required' : null,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _emailController, 
                      icon: Icons.email, 
                      hint: 'Email',
                      context: context,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Email is required';
                        if (!value.contains('@') || !value.contains('.')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _phoneController, 
                      icon: Icons.phone, 
                      hint: 'Phone Number (11 digits)', 
                      context: context,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Phone number is required';
                        if (value.length != 11) return 'Phone number must be exactly 11 digits';
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    
                    // Common Area Dropdown
                    _buildDropdown(
                      icon: Icons.location_on,
                      hint: 'Select Area',
                      value: _selectedArea,
                      context: context,
                      items: AssetManager.areas,
                      onChanged: (val) => setState(() => _selectedArea = val),
                    ),

                    // Owner specific fields
                    if (!isFarmer) ...[
                      const SizedBox(height: 15),
                      _buildDropdown(
                        icon: Icons.agriculture,
                        hint: 'Equipment Category',
                        value: _selectedEquipmentName,
                        context: context,
                        items: AssetManager.categories,
                        onChanged: (val) {
                          setState(() {
                            _selectedEquipmentName = val;
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      _buildDropdown(
                        icon: Icons.settings,
                        hint: 'Equipment Specs / Type',
                        value: _selectedEquipmentType,
                        context: context,
                        items: AssetManager.equipmentTypes,
                        onChanged: (val) => setState(() => _selectedEquipmentType = val),
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        controller: _rentController, 
                        icon: Icons.monetization_on, 
                        hint: 'Rent per Day (Rs)', 
                        context: context,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Rent per day is required';
                          if (int.tryParse(value) == null || int.parse(value) <= 0) return 'Enter a valid amount over 0';
                          return null;
                        },
                      ),
                      
                      // Dynamic Image Gallery for Owner Equipment
                      const SizedBox(height: 15),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Equipment Image:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.getTextColor(context))),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _pickEquipmentImage,
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.getCardColor(context),
                            border: Border.all(color: AppColors.primary, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: _selectedEquipmentImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(_selectedEquipmentImage!, fit: BoxFit.cover),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, size: 40, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textGrey : AppColors.textLight),
                                    const SizedBox(height: 10),
                                    Text('Tap to upload image', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textGrey : AppColors.textLight)),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],

                    const SizedBox(height: 15),
                    
                    // Password Field
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.getCardColor(context),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        style: TextStyle(color: AppColors.getTextColor(context)),
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textGrey : AppColors.textLight),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Theme.of(context).brightness == Brightness.dark ? AppColors.textGrey : AppColors.textLight,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          hintText: 'Password',
                          hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textGrey : AppColors.textLight),
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
                    
                    const SizedBox(height: 30),
                    
                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: Consumer<AuthProvider>(
                          builder: (context, auth, child) {
                            return auth.isLoading
                                ? const CircularProgressIndicator(color: AppColors.white)
                                : const Text(
                                    'REGISTER',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white),
                                  );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    required BuildContext context,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        style: TextStyle(color: AppColors.getTextColor(context)),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textGrey : AppColors.textLight),
          hintText: hint,
          hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textGrey : AppColors.textLight),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required IconData icon,
    required String hint,
    required String? value,
    required BuildContext context,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(icon, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textGrey : AppColors.textLight),
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                hint: Text(hint, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textGrey : AppColors.textLight)),
                isExpanded: true,
                dropdownColor: AppColors.getCardColor(context),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item, style: TextStyle(color: AppColors.getTextColor(context))),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
