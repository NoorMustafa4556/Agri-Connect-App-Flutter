import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/asset_manager.dart';
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

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Dropdown States
  String? _selectedArea;
  String? _selectedEquipmentName; // Extracted as category in AssetManager
  String? _selectedEquipmentType;
  String? _selectedEquipmentImageRef;

  final List<String> _areas = ['Lahore', 'Karachi', 'Islamabad', 'Multan', 'Faisalabad'];

  void _register() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty || _selectedArea == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all mandatory fields')));
      return;
    }

    if (!isFarmer) {
      if (_selectedEquipmentName == null || _selectedEquipmentType == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select equipment details')));
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
        context: context,
      );

      // Note: We might also want to save the equipment info immediately to the `equipment` collection here for owners,
      // but for now the user can add equipment later via AddEquipmentScreen. 
      // The requirement was just that they can see & select the pictures.
      
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
              child: Column(
                children: [
                  _buildTextField(_nameController, Icons.person, 'Full Name'),
                  const SizedBox(height: 15),
                  _buildTextField(_emailController, Icons.email, 'Email'),
                  const SizedBox(height: 15),
                  
                  // Common Area Dropdown
                  _buildDropdown(
                    icon: Icons.location_on,
                    hint: 'Select Area',
                    value: _selectedArea,
                    items: _areas,
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
                      items: ['Diesel', 'Petrol', 'Electric', 'Manual'],
                      onChanged: (val) => setState(() => _selectedEquipmentType = val),
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
                    child: TextField(
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
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, IconData icon, String hint) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textLight.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextField(
        controller: controller,
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
