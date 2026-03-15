import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
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
  String? _selectedEquipmentName; // Extracted as category in AssetManager
  String? _selectedEquipmentType;
  String? _selectedEquipmentImageRef;

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
      if (_selectedEquipmentName == null || _selectedEquipmentType == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select equipment details.')));
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

      // If Owner, save the initial equipment directly to Firestore collection
      if (!isFarmer && _selectedEquipmentName != null) {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          await FirebaseFirestore.instance.collection('equipment').add({
             'ownerId': userId,
             'ownerName': _nameController.text.trim(),
             'name': '${_selectedEquipmentName} ($_selectedEquipmentType)',
             'category': _selectedEquipmentName,
             'city': _selectedArea,
             'assetImageRef': _selectedEquipmentImageRef ?? AssetManager.getEquipmentImage(_selectedEquipmentName!),
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
      backgroundColor: AppColors.white,
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
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.background,
                  child: const Icon(Icons.camera_alt, size: 40, color: AppColors.textLight),
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
                      validator: (value) => (value == null || value.trim().isEmpty) ? 'Full Name is required' : null,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _emailController, 
                      icon: Icons.email, 
                      hint: 'Email',
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
                        items: AssetManager.categories,
                        onChanged: (val) {
                          setState(() {
                            _selectedEquipmentName = val;
                            _selectedEquipmentImageRef = null; // Reset image when category changes
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      _buildDropdown(
                        icon: Icons.settings,
                        hint: 'Equipment Specs / Type',
                        value: _selectedEquipmentType,
                        items: AssetManager.equipmentTypes,
                        onChanged: (val) => setState(() => _selectedEquipmentType = val),
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        controller: _rentController, 
                        icon: Icons.monetization_on, 
                        hint: 'Rent per Day (Rs)', 
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Rent per day is required';
                          if (int.tryParse(value) == null || int.parse(value) <= 0) return 'Enter a valid amount over 0';
                          return null;
                        },
                      ),
                      
                      // Dynamic Image Gallery for Owner Equipment
                      if (_selectedEquipmentName != null && AssetManager.getImagesForCategory(_selectedEquipmentName!).isNotEmpty) ...[
                        const SizedBox(height: 15),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Select Equipment Image:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: AssetManager.getImagesForCategory(_selectedEquipmentName!).length,
                            itemBuilder: (context, index) {
                              String imagePath = AssetManager.getImagesForCategory(_selectedEquipmentName!)[index];
                              bool isSelected = _selectedEquipmentImageRef == imagePath;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedEquipmentImageRef = imagePath;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : Colors.transparent,
                                      width: 3,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(7),
                                    child: Image.asset(
                                      imagePath,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        width: 100,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.image_not_supported),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                      if (_selectedEquipmentName != null && AssetManager.getImagesForCategory(_selectedEquipmentName!).isEmpty) ...[
                        const SizedBox(height: 10),
                        Text('No images found in assets/images/$_selectedEquipmentName', style: const TextStyle(color: Colors.red)),
                      ]
                    ],

                    const SizedBox(height: 15),
                    
                    // Password Field
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.textLight.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(5),
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
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textLight.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.textLight),
          hintText: hint,
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
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textLight.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(icon, color: AppColors.textLight),
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                hint: Text(hint),
                isExpanded: true,
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
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
