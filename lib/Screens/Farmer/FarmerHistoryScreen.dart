import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/AppColors.dart';

class FarmerHistoryScreen extends StatelessWidget {
  const FarmerHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Request History'),
          bottom: const TabBar(
            labelColor: AppColors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppColors.white,
            indicatorWeight: 4,
            tabs: [
              Tab(text: 'Active Requests'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _RequestsView(isActiveTab: true),
            _RequestsView(isActiveTab: false),
          ],
        ),
      ),
    );
  }
}

class _RequestsView extends StatelessWidget {
  final bool isActiveTab;
  
  const _RequestsView({Key? key, required this.isActiveTab}) : super(key: key);

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown Date';
    return DateFormat('MMM dd, yyyy').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Center(child: Text("Please login to view history"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('farmerId', isEqualTo: userId)
          // Removing orderBy temporarily to handle missing indexes on new apps
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
           // Suppress indexing error temporarily if index isn't built yet
           if (snapshot.error.toString().contains('index')) {
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bookings')
                    .where('farmerId', isEqualTo: userId)
                    .snapshots(), // simpler query without ordering
                builder: (context, innerSnapshot) {
                   return _buildList(innerSnapshot);
                }
              );
           }
           return Center(child: Text('Error: ${snapshot.error}'));
        }

        return _buildList(snapshot);
      },
    );
  }

  Widget _buildList(AsyncSnapshot<QuerySnapshot> snapshot) {
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history_toggle_off, size: 60, color: Colors.grey),
            const SizedBox(height: 10),
            Text(isActiveTab ? 'No active requests yet' : 'No past history'),
          ],
        ),
      );
    }

    final docs = snapshot.data!.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['status'] ?? 'Pending';
      final bool isActive = status == 'Pending' || status == 'Accepted';
      return isActiveTab ? isActive : !isActive;
    }).toList();

    if (docs.isEmpty) {
      return Center(
        child: Text(isActiveTab ? 'No active requests right now' : 'No past history to show'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        final req = doc.data() as Map<String, dynamic>;
        
        final String status = req['status'] ?? 'Pending';
        final String equipment = req['equipment'] ?? 'Equipment';
        final String duration = req['duration'] ?? 'N/A';
        final Timestamp? createdAt = req['createdAt'] as Timestamp?;
        
        Color statusColor;
        IconData statusIcon;
        
        switch (status) {
          case 'Accepted':
            statusColor = AppColors.success;
            statusIcon = Icons.check_circle;
            break;
          case 'Rejected':
          case 'Cancelled':
            statusColor = AppColors.error;
            statusIcon = Icons.cancel;
            break;
          case 'Pending':
          default:
            statusColor = AppColors.secondary;
            statusIcon = Icons.schedule;
            break;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
             color: statusColor.withOpacity(0.05),
             borderRadius: BorderRadius.circular(15),
             border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(statusIcon, color: statusColor, size: 30),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text('Requested $equipment', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                        Text(_formatDate(createdAt), style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text('Location: ${req['hospitalName'] ?? 'Unknown'}', style: const TextStyle(color: AppColors.textLight)),
                    const SizedBox(height: 5),
                    Text('Duration: $duration', style: const TextStyle(color: AppColors.textLight)),
                    const SizedBox(height: 10),
                    Text('Status: $status', style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                    if (status == 'Accepted') ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showOwnerDetails(context, req['ownerId']),
                          icon: const Icon(Icons.contact_phone, size: 18),
                          label: const Text('Contact Owner for Details', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOwnerDetails(BuildContext context, String? ownerId) async {
    if (ownerId == null) return;

    showDialog(
      context: context,
      builder: (context) => FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(ownerId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return const AlertDialog(title: Text('Error'), content: Text('Could not load owner details.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final phone = data['phone'] ?? 'N/A';
          final email = data['email'] ?? 'N/A';
          final name = data['fullName'] ?? 'Owner';

          return AlertDialog(
            title: Text('Contact $name'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.phone, color: AppColors.primary),
                  title: const Text('Phone'),
                  subtitle: Text(phone),
                  onTap: () async {
                     final Uri url = Uri.parse('tel:$phone');
                     if (await canLaunchUrl(url)) await launchUrl(url);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.email, color: AppColors.primary),
                  title: const Text('Email'),
                  subtitle: Text(email),
                  onTap: () async {
                     final Uri url = Uri.parse('mailto:$email');
                     if (await canLaunchUrl(url)) await launchUrl(url);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))
            ],
          );
        },
      ),
    );
  }
}
