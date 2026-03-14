import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/asset_manager.dart';
import '../../Providers/AuthProvider.dart';

class AddEquipmentScreen extends StatefulWidget {
  const AddEquipmentScreen({Key? key}) : super(key: key);

  @override
  State<AddEquipmentScreen> createState() => _AddEquipmentScreenState();
}

class _AddEquipmentScreenState extends State<AddEquipmentScreen> {
  String? _selectedCategory;
  String? _selectedEquipmentImageRef;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _specsController = TextEditingController();
  bool _isLoading = false;

  void _saveEquipment() async {
     if (_selectedCategory == null || _nameController.text.isEmpty || _selectedEquipmentImageRef == null) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Please select category, image, and enter a name')),
       );
       return;
     }

     setState(() {
       _isLoading = true;
     });

     try {
       final authProvider = context.read<AuthProvider>();
       // Fetch user doc directly to get city and name for denormalization
       final userId = FirebaseAuth.instance.currentUser!.uid;
       final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
       
       String city = userDoc.exists ? (userDoc.data()?['city'] ?? 'Unknown Location') : 'Unknown';
       String ownerName = authProvider.userName ?? 'Owner';

       await FirebaseFirestore.instance.collection('equipment').add({
         'ownerId': userId,
         'ownerName': ownerName,
         'name': _nameController.text.trim(),
         'category': _selectedCategory,
         'city': city,
         'assetImageRef': _selectedEquipmentImageRef,
         'pricePerDay': _priceController.text.trim(),
         'specs': _specsController.text.trim(),
         'createdAt': FieldValue.serverTimestamp(),
       });

       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Equipment added successfully!')),
       );
       Navigator.pop(context);
     } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Error: $e')),
       );
     } finally {
       if (mounted) {
         setState(() {
           _isLoading = false;
         });
       }
     }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Equipment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
               'Listing Details',
               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            
            // Name Field
            _buildTextField('Equipment Name (e.g. Massey Tractor)', _nameController),
            const SizedBox(height: 15),
            
            // Price Field
            _buildTextField('Rental Price per Day', _priceController, isNumber: true),
            const SizedBox(height: 15),
            
            // Category Dropdown
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: AppColors.textLight.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  hint: const Text('Select Category'),
                  isExpanded: true,
                  items: AssetManager.categories.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCategory = val;
                      _selectedEquipmentImageRef = null; // reset image
                    });
                  },
                ),
              ),
            ),
            
            // Dynamic Image Gallery for Owner Equipment
            if (_selectedCategory != null && AssetManager.getImagesForCategory(_selectedCategory!).isNotEmpty) ...[
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
                  itemCount: AssetManager.getImagesForCategory(_selectedCategory!).length,
                  itemBuilder: (context, index) {
                    String imagePath = AssetManager.getImagesForCategory(_selectedCategory!)[index];
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
            if (_selectedCategory != null && AssetManager.getImagesForCategory(_selectedCategory!).isEmpty) ...[
              const SizedBox(height: 10),
              Text('No images found in assets/images/$_selectedCategory', style: const TextStyle(color: Colors.red)),
            ],
            
            const SizedBox(height: 15),
            
            // Specs Field
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: AppColors.textLight.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextField(
                controller: _specsController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Additional Details (Engine power, capacity etc.)',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(10),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveEquipment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: AppColors.white)
                    : const Text('Save & Publish', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {bool isNumber = false}) {
    return Container(
       decoration: BoxDecoration(
         color: AppColors.white,
         border: Border.all(color: AppColors.textLight.withOpacity(0.5)),
         borderRadius: BorderRadius.circular(5),
       ),
       child: TextField(
         controller: controller,
         keyboardType: isNumber ? TextInputType.number : TextInputType.text,
         decoration: InputDecoration(
           hintText: hint,
           border: InputBorder.none,
           contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
         ),
       ),
    );
  }
}
