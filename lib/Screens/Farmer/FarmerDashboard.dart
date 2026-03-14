import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/asset_manager.dart';
import '../Shared/CustomDrawer.dart';
import 'SearchEquipmentScreen.dart';

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({Key? key}) : super(key: key);

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  String? _selectedCity;
  final List<String> _cities = ['Lahore', 'Karachi', 'Islamabad', 'Multan', 'Faisalabad'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Find Equipment'),
        centerTitle: false,
      ),
      drawer: const CustomDrawer(isFarmer: true),
      body: Column(
        children: [
          // Banner / Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Need Equipment?',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Select your city and a category to find machinery near you.',
                  style: TextStyle(color: AppColors.white, fontSize: 14),
                ),
                const SizedBox(height: 15),
                
                // City Dropdown Filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCity,
                      hint: const Text('Select City'),
                      isExpanded: true,
                      icon: const Icon(Icons.location_city, color: AppColors.primary),
                      items: _cities.map((String city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCity = val;
                        });
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Grid View of Categories
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: GridView.builder(
                itemCount: AssetManager.categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  final category = AssetManager.categories[index];
                  // Using icons as fallback if assets aren't loaded yet
                  return GestureDetector(
                    onTap: () {
                      if (_selectedCity == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a city first!')),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SearchEquipmentScreen(
                            category: category,
                            initialCity: _selectedCity!,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Placeholder Icon for Category (Similar to Blood Drop)
                          Icon(
                            _getCategoryIcon(category),
                            color: AppColors.primary,
                            size: 40,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            category,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    if (category.contains('Tractor')) return Icons.agriculture;
    if (category.contains('Pump')) return Icons.water_drop;
    if (category.contains('Sprayer')) return Icons.cleaning_services;
    return Icons.settings;
  }
}
