import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class EquipmentDetailsScreen extends StatelessWidget {
  final String ownerName;
  final String category;

  const EquipmentDetailsScreen({
    Key? key,
    required this.ownerName,
    required this.category,
  }) : super(key: key);

  void _showRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const BookingRequestDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Owner Details'),
        elevation: 0,
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Banner with Avatar
            Container(
              width: double.infinity,
              color: AppColors.primary,
              padding: const EdgeInsets.only(bottom: 30, top: 20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.white,
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor: AppColors.primaryLight,
                      child: const Icon(Icons.person, size: 60, color: AppColors.white),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    ownerName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Contact Information Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        _buildInfoTile(Icons.email, 'Email', 'hidden@example.com'),
                        const Divider(height: 1),
                        _buildInfoTile(Icons.phone, 'Phone', '0300------- (Hidden)'),
                        const Divider(height: 1),
                        _buildInfoTile(Icons.location_city, 'City', 'Lahore'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Request Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () => _showRequestDialog(context),
                      icon: const Icon(Icons.send, color: AppColors.white),
                      label: const Text(
                        'Send Booking Request',
                        style: TextStyle(fontSize: 18, color: AppColors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 16, color: AppColors.textDark, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// Dialog Component embedded in this file for simplicity (matches reference popup)
class BookingRequestDialog extends StatefulWidget {
  const BookingRequestDialog({Key? key}) : super(key: key);

  @override
  State<BookingRequestDialog> createState() => _BookingRequestDialogState();
}

class _BookingRequestDialogState extends State<BookingRequestDialog> {
  String? _duration = '1 Day';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.background,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: const Column(
                children: [
                  Icon(Icons.agriculture, color: AppColors.white, size: 50),
                  SizedBox(height: 10),
                  Text(
                    'Request Equipment',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'To: Owner Name',
                    style: TextStyle(color: AppColors.white),
                  ),
                ],
              ),
            ),
            
            // Form Fields
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildTextField('Your Name'),
                  const SizedBox(height: 15),
                  _buildTextField('Farm Location / Address'),
                  const SizedBox(height: 15),
                  
                  // Duration Dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border.all(color: AppColors.textLight.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _duration,
                            items: ['1 Hour', '1 Day', '1 Week', '1 Month']
                                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (val) => setState(() => _duration = val),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Message Field
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border.all(color: AppColors.textLight.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const TextField(
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Message (e.g. Needs driver too)',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 25),
                  
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel', style: TextStyle(color: AppColors.error)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Submit Logic
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Request Sent Successfully!')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        ),
                        child: const Text('Send'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.textLight.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        ),
      ),
    );
  }
}
