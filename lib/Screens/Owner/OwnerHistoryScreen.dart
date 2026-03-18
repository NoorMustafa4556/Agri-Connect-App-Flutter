import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../utils/AppColors.dart';

class OwnerHistoryScreen extends StatelessWidget {
  const OwnerHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Past Requests history'),
          bottom: const TabBar(
            labelColor: AppColors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppColors.white,
            indicatorWeight: 4,
            tabs: [
              Tab(text: 'Accepted'),
              Tab(text: 'Rejected'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _OwnerRequestsView(statusFilter: 'Accepted'),
            _OwnerRequestsView(statusFilter: 'Rejected'),
          ],
        ),
      ),
    );
  }
}

class _OwnerRequestsView extends StatelessWidget {
  final String statusFilter;
  
  const _OwnerRequestsView({Key? key, required this.statusFilter}) : super(key: key);

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
          .where('ownerId', isEqualTo: userId)
          .where('status', isEqualTo: statusFilter)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history, size: 60, color: Colors.grey),
                const SizedBox(height: 10),
                Text('No $statusFilter requests found'),
              ],
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final req = docs[index].data() as Map<String, dynamic>;
            final String equipment = req['equipment'] ?? 'Equipment';
            final String farmerName = req['farmerName'] ?? 'Unknown Farmer';
            final String duration = req['duration'] ?? 'N/A';
            final String bookingDate = req['bookingDate'] ?? 'N/A';
            
            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: (statusFilter == 'Accepted' ? AppColors.success : AppColors.error).withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.15 : 0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: (statusFilter == 'Accepted' ? AppColors.success : AppColors.error).withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.4 : 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(equipment, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.getTextColor(context))),
                      Text(statusFilter, style: TextStyle(color: statusFilter == 'Accepted' ? AppColors.success : AppColors.error, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 20),
                  Text('Farmer: $farmerName', style: TextStyle(color: AppColors.getTextColor(context))),
                  const SizedBox(height: 5),
                  Text('Booking Date: $bookingDate', style: TextStyle(color: AppColors.getTextColor(context))),
                  const SizedBox(height: 5),
                  Text('Duration: $duration', style: TextStyle(color: AppColors.getTextColor(context))),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
