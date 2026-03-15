import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/AppColors.dart';
import '../Shared/CustomDrawer.dart';
import 'AddEquipmentScreen.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({Key? key}) : super(key: key);

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  bool isOnline = true;
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
  }

  void _acceptRequest(String bookingId) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
        'status': 'Accepted'
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request Accepted! System will notify farmer.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accepting: $e')),
      );
    }
  }

  void _rejectRequest(String bookingId) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
        'status': 'Rejected'
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request Rejected.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error rejecting: $e')),
      );
    }
  }

  void _deleteEquipment(String equipmentId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Equipment'),
        content: const Text('Are you sure you want to delete this listing? Farmers will no longer be able to request it.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      )
    ) ?? false;

    if (confirm) {
        try {
           await FirebaseFirestore.instance.collection('equipment').doc(equipmentId).delete();
           if (!mounted) return;
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Equipment deleted')));
        } catch (e) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting: $e')));
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Scaffold(body: Center(child: Text("Initializing user...")));
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
          bottom: const TabBar(
            labelColor: AppColors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppColors.white,
            indicatorWeight: 4,
             tabs: [
              Tab(text: 'Incoming Requests'),
              Tab(text: 'My Equipment'),
            ],
          ),
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
            
            Expanded(
              child: TabBarView(
                children: [
                    // TAB 1: Requests
                   StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('bookings')
                          .where('ownerId', isEqualTo: userId)
                          .snapshots(),
                      builder: (context, snapshot) {
                         if (snapshot.connectionState == ConnectionState.waiting) {
                           return const Center(child: CircularProgressIndicator());
                         }
                         if (snapshot.hasError) {
                           if (snapshot.error.toString().contains('index')) {
                              return StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('bookings')
                                    .where('ownerId', isEqualTo: userId)
                                    .snapshots(),
                                builder: (context, innerSnapshot) {
                                   return _buildRequestsList(innerSnapshot);
                                }
                              );
                           }
                           return Center(child: Text('Error: ${snapshot.error}'));
                         }
                         return _buildRequestsList(snapshot);
                      },
                  ),

                  // TAB 2: My Equipment
                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('equipment')
                          .where('ownerId', isEqualTo: userId)
                          .snapshots(),
                      builder: (context, snapshot) {
                         if (snapshot.connectionState == ConnectionState.waiting) {
                           return const Center(child: CircularProgressIndicator());
                         }
                         if (snapshot.hasError) {
                           return Center(child: Text('Error: ${snapshot.error}'));
                         }
                         return _buildMyEquipmentList(snapshot);
                      },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList(AsyncSnapshot<QuerySnapshot> snapshot) {
     if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return _buildEmptyState('No Incoming Requests', Icons.inbox);
     }

     final docs = snapshot.data!.docs;
     
     return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        itemCount: docs.length,
        itemBuilder: (context, index) {
          final doc = docs[index];
          final req = doc.data() as Map<String, dynamic>;
          final String status = req['status'] ?? 'Pending';
          final bool isPending = status == 'Pending';

          return GestureDetector(
            onTap: () => _showFarmerDetails(context, req, doc.id),
            child: Container(
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
                      Text('${req['equipment'] ?? 'Equipment'} Request', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPending ? AppColors.secondary : (status == 'Accepted' ? AppColors.success : AppColors.error), 
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Text(status, style: const TextStyle(color: AppColors.white, fontSize: 12)),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Text('Farmer: ${req['farmerName'] ?? 'Unknown'}'),
                  const SizedBox(height: 5),
                  Text('Location: ${req['hospitalName'] ?? 'Unknown'}'),
                  const SizedBox(height: 5),
                  Text('Date: ${req['bookingDate'] ?? 'N/A'}'),
                  const SizedBox(height: 5),
                  Text('Duration: ${req['duration'] ?? 'N/A'}'),
                  const SizedBox(height: 5),
                  Text('Message: "${req['message'] ?? 'None'}"', style: const TextStyle(fontStyle: FontStyle.italic)),
                  const SizedBox(height: 15),
                  if (isPending) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _rejectRequest(doc.id),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Reject'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _acceptRequest(doc.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Accept'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );
  }

  void _showFarmerDetails(BuildContext context, Map<String, dynamic> req, String bookingId) {
    final String? farmerId = req['farmerId'];
    if (farmerId == null) return;

    showDialog(
      context: context,
      builder: (context) => FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(farmerId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return const AlertDialog(title: Text('Error'), content: Text('Could not load farmer details.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final phone = data['phone'] ?? 'N/A';
          final email = data['email'] ?? 'N/A';
          final name = data['fullName'] ?? req['farmerName'] ?? 'Farmer';
          final gender = data['gender'] ?? 'N/A';
          final city = data['city'] ?? req['hospitalName'] ?? 'N/A';

          return AlertDialog(
            title: Text('Farmer Details'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _debugDetail('Full Name', name),
                   _debugDetail('Phone', phone),
                   _debugDetail('Email', email),
                   _debugDetail('City', city),
                   _debugDetail('Gender', gender),
                   const Divider(),
                   _debugDetail('Request Date', req['bookingDate'] ?? 'N/A'),
                   _debugDetail('Duration', req['duration'] ?? 'N/A'),
                   _debugDetail('Message', req['message'] ?? 'None'),
                   const SizedBox(height: 20),
                   Row(
                     children: [
                       Expanded(
                         child: IconButton(
                           icon: const Icon(Icons.phone, color: AppColors.primary),
                           onPressed: () async {
                              final Uri url = Uri.parse('tel:$phone');
                              if (await canLaunchUrl(url)) await launchUrl(url);
                           },
                         ),
                       ),
                       Expanded(
                         child: IconButton(
                           icon: const Icon(Icons.email, color: AppColors.primary),
                           onPressed: () async {
                              final Uri url = Uri.parse('mailto:$email');
                              if (await canLaunchUrl(url)) await launchUrl(url);
                           },
                         ),
                       ),
                     ],
                   )
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))
            ],
          );
        }
      )
    );
  }

  Widget _debugDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: AppColors.textDark, fontSize: 14),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildMyEquipmentList(AsyncSnapshot<QuerySnapshot> snapshot) {
     if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return _buildEmptyState('No Equipment Listed', Icons.agriculture);
     }

     final docs = snapshot.data!.docs;
     
     return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        itemCount: docs.length,
        itemBuilder: (context, index) {
          final doc = docs[index];
          final data = doc.data() as Map<String, dynamic>;
          
          final String name = data['name'] ?? 'Equipment';
          final String cat = data['category'] ?? 'Category';
          final String price = data['pricePerDay'] != null ? 'Rs ${data['pricePerDay']}' : 'N/A';
          final String? assetRef = data['assetImageRef'];

          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(10),
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
                 Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: assetRef != null && assetRef.isNotEmpty 
                          ? Image.asset(assetRef, fit: BoxFit.cover,
                              errorBuilder: (ctx, err, st) => const Icon(Icons.agriculture, color: AppColors.primary))
                          : const Icon(Icons.agriculture, color: AppColors.primary, size: 30),
                    ),
                 ),
                 const SizedBox(width: 15),
                 Expanded(
                    child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 5),
                          Text('$cat • $price/day', style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
                       ]
                    )
                 ),
                 IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: () => _deleteEquipment(doc.id),
                 )
              ],
            ),
          );
        },
      );
  }

  Widget _buildEmptyState(String msg, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 15),
          Text(
            msg,
            style: TextStyle(fontSize: 18, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
