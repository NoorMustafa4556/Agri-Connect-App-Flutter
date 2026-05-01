import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/AppColors.dart';
import '../../utils/AssetManager.dart';
import '../../Providers/AuthProvider.dart';

class AddEquipmentScreen extends StatefulWidget {
  const AddEquipmentScreen({Key? key}) : super(key: key);

  @override
  State<AddEquipmentScreen> createState() => _AddEquipmentScreenState();
}

class _AddEquipmentScreenState extends State<AddEquipmentScreen> {
  String? _selectedCategory;
  String? _selectedType;
  File? _selectedImage;
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _specsController = TextEditingController();
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _saveEquipment() async {
     if (_selectedCategory == null || _selectedType == null || _selectedImage == null || _priceController.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Please select category, type, image, and enter price')),
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

       // Upload image to Firebase Storage
       String fileName = 'equipment_${DateTime.now().millisecondsSinceEpoch}.jpg';
       Reference storageRef = FirebaseStorage.instance.ref().child('equipment_images').child(userId).child(fileName);
       UploadTask uploadTask = storageRef.putFile(_selectedImage!);
       TaskSnapshot storageSnapshot = await uploadTask;
       String downloadUrl = await storageSnapshot.ref.getDownloadURL();

       await FirebaseFirestore.instance.collection('equipment').add({
         'ownerId': userId,
         'ownerName': ownerName,
         'name': '$_selectedCategory ($_selectedType)',
         'category': _selectedCategory,
         'city': city,
         'assetImageRef': downloadUrl,
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            
            // Category Dropdown
            _buildDropdown(
              hint: 'Equipment Category',
              value: _selectedCategory,
              context: context,
              items: AssetManager.categories,
              onChanged: (val) {
                setState(() {
                  _selectedCategory = val;
                });
              },
            ),
            
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Equipment Image:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.getTextColor(context))),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.getCardColor(context),
                  border: Border.all(color: AppColors.primary, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
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

            // Type Dropdown
            _buildDropdown(
              hint: 'Equipment Specs / Type',
              value: _selectedType,
              context: context,
              items: AssetManager.equipmentTypes,
              onChanged: (val) {
                setState(() {
                  _selectedType = val;
                });
              },
            ),
            const SizedBox(height: 15),
            
            // Price Field
            _buildTextField('Rental Price per Day', _priceController, context, isNumber: true),
            const SizedBox(height: 15),
            
            // Specs Field
            Container(
              height: 100,
              decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                border: Border.all(color: AppColors.textLight.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextField(
                controller: _specsController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Additional Details (Engine power, capacity etc.)',
                  hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textGrey : AppColors.textLight),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(10),
                ),
                style: TextStyle(color: AppColors.getTextColor(context)),
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

  Widget _buildTextField(String hint, TextEditingController controller, BuildContext context, {bool isNumber = false}) {
    return Container(
       decoration: BoxDecoration(
         color: AppColors.getCardColor(context),
         border: Border.all(color: AppColors.textLight.withOpacity(0.5)),
         borderRadius: BorderRadius.circular(5),
       ),
       child: TextField(
         controller: controller,
         keyboardType: isNumber ? TextInputType.number : TextInputType.text,
         style: TextStyle(color: AppColors.getTextColor(context)),
         decoration: InputDecoration(
           hintText: hint,
           hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textGrey : AppColors.textLight),
           border: InputBorder.none,
           contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
         ),
       ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required BuildContext context,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        border: Border.all(color: AppColors.textLight.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
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
    );
  }
}
