import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/AppColors.dart';
import '../../utils/AssetManager.dart';
import 'EquipmentDetailsScreen.dart';

class SearchEquipmentScreen extends StatefulWidget {
  final String category;
  final String initialCity;
  const SearchEquipmentScreen({Key? key, required this.category, required this.initialCity}) : super(key: key);

  @override
  State<SearchEquipmentScreen> createState() => _SearchEquipmentScreenState();
}

class _SearchEquipmentScreenState extends State<SearchEquipmentScreen> {
  late final TextEditingController _cityController;
  String _currentCity = '';

  @override
  void initState() {
    super.initState();
    _currentCity = widget.initialCity;
    _cityController = TextEditingController(text: _currentCity);
    
    _cityController.addListener(() {
      setState(() {
        _currentCity = _cityController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${widget.initialCity} - ${widget.category}s'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // City Search Bar
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Change City / Area',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border.all(color: AppColors.primary, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: AssetManager.areas.contains(_currentCity) ? _currentCity : null,
                      hint: const Text('Select Area'),
                      isExpanded: true,
                      icon: const Icon(Icons.location_city, color: AppColors.primary),
                      items: AssetManager.areas.map((String city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _currentCity = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Live List of Equipments
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('equipment')
                  .where('category', isEqualTo: widget.category)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading equipment.'));
                }
                
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No ${widget.category}s found in database.'));
                }
                
                // Client-side filtering for city (since Firestore doesn't support case-insensitive contains natively well)
                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final city = (data['city'] ?? '').toString().toLowerCase();
                  return city.contains(_currentCity.toLowerCase());
                }).toList();
                
                if (docs.isEmpty) {
                  return Center(child: Text('No ${widget.category}s found matching "$_currentCity".'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    
                    final String ownerName = data['ownerName'] ?? 'Unknown Owner';
                    final String location = data['city'] ?? 'Unknown location';
                    final String name = data['name'] ?? widget.category;
                    final String? assetRef = data['assetImageRef'];
                    
                    // In a real app we'd check bookings collection to see if currently pending. For now available.
                    bool isPending = false; 
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(15),
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
                      child: Row(
                        children: [
                          // Owner/Equipment Image
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: assetRef != null && assetRef.isNotEmpty 
                                  ? Image.asset(assetRef, fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, st) => const Icon(Icons.agriculture, color: AppColors.primary))
                                  : const Icon(Icons.agriculture, color: AppColors.primary, size: 40),
                            ),
                          ),
                          const SizedBox(width: 15),
                          
                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'By $ownerName',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$location • ${data['pricePerDay'] != null ? 'Rs ${data['pricePerDay']}/day' : 'Price TBA'}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textLight,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                
                                // Buttons row
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          data['equipmentId'] = docs[index].id; // Add doc ID
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => EquipmentDetailsScreen(
                                                equipmentData: data,
                                              ),
                                            ),
                                          );
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.primary,
                                          side: const BorderSide(color: AppColors.primary),
                                          padding: const EdgeInsets.symmetric(vertical: 5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text('Details', style: TextStyle(fontSize: 12)),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: isPending ? null : () {
                                          data['equipmentId'] = docs[index].id;
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return BookingRequestDialog(equipmentData: data);
                                            },
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isPending ? Colors.grey[300] : AppColors.primary,
                                          foregroundColor: isPending ? AppColors.textDark : AppColors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: Text(isPending ? 'Pending' : 'Request', style: const TextStyle(fontSize: 12)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
