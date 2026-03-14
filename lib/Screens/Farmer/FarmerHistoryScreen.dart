import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

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
            _ActiveRequestsView(),
            _PastHistoryView(),
          ],
        ),
      ),
    );
  }
}

class _ActiveRequestsView extends StatelessWidget {
  const _ActiveRequestsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy active request
    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        // Pending Card
        Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
             color: AppColors.secondary.withOpacity(0.1),
             borderRadius: BorderRadius.circular(15),
             border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.schedule, color: AppColors.secondary, size: 30),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Need Tractor for Plowing', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Dec 22', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Text('Location: Farm Model Town', style: TextStyle(color: AppColors.textLight)),
                    const SizedBox(height: 5),
                    const Text('Duration: 1 Day', style: TextStyle(color: AppColors.textLight)),
                    const SizedBox(height: 10),
                    Text('Status: Pending', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Accepted Card
        Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
             color: AppColors.primary.withOpacity(0.1),
             borderRadius: BorderRadius.circular(15),
             border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle, color: AppColors.primary, size: 30),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Need Harvester', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Dec 22', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Text('Location: Farm DHA', style: TextStyle(color: AppColors.textLight)),
                    const SizedBox(height: 5),
                    const Text('Duration: 1 Week', style: TextStyle(color: AppColors.textLight)),
                    const SizedBox(height: 10),
                    const Text('Status: Accepted', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    const Text('Response: Accepted, Contact for details\n(My Contact: 0300-1234567)', 
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PastHistoryView extends StatelessWidget {
  const _PastHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy cancelled output
    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
             color: AppColors.error.withOpacity(0.1),
             borderRadius: BorderRadius.circular(15),
             border: Border.all(color: AppColors.error.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.cancel, color: AppColors.error, size: 30),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Need Water Pump', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Dec 15', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                      ],
                    ),
                     const SizedBox(height: 5),
                    const Text('Status: Fulfilled / Cancelled', style: TextStyle(color: AppColors.textLight)),
                    const SizedBox(height: 10),
                    const Text('Response: System Auto-Cancelled (Time Limit Reached)', 
                        style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
