import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../Shared/CustomDrawer.dart';
import 'AddEquipmentScreen.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({Key? key}) : super(key: key);

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  bool isOnline = true;
  
  // Dummy incoming requests
  List<Map<String, dynamic>> requests = [
    {
      'id': '1',
      'farmerName': 'Ali Raza',
      'location': 'Lahore Farm 1',
      'duration': '1 Day',
      'equipment': 'Tractor',
      'message': 'Need this urgently tomorrow morning.',
    }
  ];

  void _acceptRequest(int index) {
    setState(() {
      requests.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request Accepted! System will notify farmer.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Owner Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Equipment',
            onPressed: () {
               Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEquipmentScreen()));
            },
          )
        ],
      ),
      drawer: const CustomDrawer(isFarmer: false),
      body: Column(
        children: [
          // Availability Status Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Availability Status',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      isOnline ? 'You are Online' : 'You are Offline',
                      style: TextStyle(
                        color: isOnline ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: isOnline,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() => isOnline = val);
                  },
                ),
              ],
            ),
          ),
          
          // Header
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Equipment Requests',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          
          // Incoming Requests List
          Expanded(
            child: requests.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final req = requests[index];
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${req['equipment']} Request', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(10)),
                                  child: const Text('Pending', style: TextStyle(color: AppColors.white, fontSize: 12)),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Text('Farmer: ${req['farmerName']}'),
                            const SizedBox(height: 5),
                            Text('Location: ${req['location']}'),
                            const SizedBox(height: 5),
                            Text('Duration: ${req['duration']}'),
                            const SizedBox(height: 5),
                            Text('Message: "${req['message']}"', style: const TextStyle(fontStyle: FontStyle.italic)),
                            const SizedBox(height: 15),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _acceptRequest(index),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('Accept Request'),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 15),
          Text(
            'No Incoming Requests',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
