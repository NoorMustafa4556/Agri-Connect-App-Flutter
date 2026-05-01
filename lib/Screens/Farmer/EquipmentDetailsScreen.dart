import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/AppColors.dart';
import '../../utils/AssetManager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../utils/UIUtils.dart';

class EquipmentDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> equipmentData;

  const EquipmentDetailsScreen({
    Key? key,
    required this.equipmentData,
  }) : super(key: key);

  void _showRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BookingRequestDialog(equipmentData: equipmentData);
      },
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String ownerId = equipmentData['ownerId'];
    final String ownerName = equipmentData['ownerName'] ?? 'Unknown Owner';
    final String category = equipmentData['category'] ?? 'Equipment';
    final String price = equipmentData['pricePerDay'] != null ? 'Rs ${equipmentData['pricePerDay']}/day' : 'Price TBA';
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Owner Details'),
        elevation: 0,
        backgroundColor: AppColors.primary,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(ownerId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Failed to load owner details.'));
          }

          final ownerDoc = snapshot.data!.data() as Map<String, dynamic>;
          final email = ownerDoc['email'] ?? 'Not provided';
          final phone = ownerDoc['phone'] ?? 'Not provided';
          final city = equipmentData['city'] ?? ownerDoc['city'] ?? 'Unknown';
          final String? profileImageUrl = ownerDoc['profileImageUrl'];

          return SingleChildScrollView(
            child: Column(
              children: [
                // Equipment Image Header
                Container(
                  width: double.infinity,
                  height: 250,
                  color: Theme.of(context).dividerColor,
                  child: equipmentData['assetImageRef'] != null && equipmentData['assetImageRef'].toString().isNotEmpty
                      ? (equipmentData['assetImageRef'].toString().startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: equipmentData['assetImageRef'],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => UIUtils.getShimmer(context),
                              errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, size: 50),
                            )
                          : Image.asset(equipmentData['assetImageRef'], fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 50)))
                      : const Icon(Icons.agriculture, size: 80, color: AppColors.primary),
                ),

                // Owner Profile Info
                Container(
                  width: double.infinity,
                  transform: Matrix4.translationValues(0, -30, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.white,
                        child: profileImageUrl != null
                            ? ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: profileImageUrl,
                                  fit: BoxFit.cover,
                                  width: 92,
                                  height: 92,
                                  placeholder: (context, url) => UIUtils.getShimmer(context, borderRadius: 50),
                                  errorWidget: (context, url, error) => const CircleAvatar(
                                    radius: 46,
                                    backgroundColor: AppColors.primaryLight,
                                    child: Icon(Icons.person, size: 50, color: AppColors.white),
                                  ),
                                ),
                              )
                            : const CircleAvatar(
                                radius: 46,
                                backgroundColor: AppColors.primaryLight,
                                child: Icon(Icons.person, size: 50, color: AppColors.white),
                              ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        ownerName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextColor(context),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$category • $price',
                          style: const TextStyle(
                            color: AppColors.white,
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
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            _buildInfoTile(context, Icons.email, 'Email', email),
                            const Divider(height: 1),
                            _buildInfoTile(
                              context,
                              Icons.phone, 
                              'Phone', 
                              phone,
                              onTap: phone != 'Not provided' ? () => _makePhoneCall(phone) : null,
                            ),
                            const Divider(height: 1),
                            _buildInfoTile(context, Icons.location_city, 'City', city),
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
          );
        }
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, IconData icon, String title, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: TextStyle(fontSize: 12, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textGrey : AppColors.textLight)),
        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: 16, 
            color: onTap != null ? AppColors.primary : AppColors.getTextColor(context), 
            fontWeight: FontWeight.bold,
            decoration: onTap != null ? TextDecoration.underline : TextDecoration.none,
          ),
        ),
        trailing: onTap != null ? const Icon(Icons.call, color: AppColors.primary) : null,
      ),
    );
  }
}

// Dialog Component embedded in this file for simplicity
class BookingRequestDialog extends StatefulWidget {
  final Map<String, dynamic> equipmentData;
  const BookingRequestDialog({Key? key, required this.equipmentData}) : super(key: key);

  @override
  State<BookingRequestDialog> createState() => _BookingRequestDialogState();
}

class _BookingRequestDialogState extends State<BookingRequestDialog> {
  String? _duration = '1 Day';
  String? _selectedArea;
  DateTime? _selectedDate;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isSubmitting = false;
  List<DateTime> _bookedDates = [];

  @override
  void initState() {
    super.initState();
    _fetchBookedDates();
  }

  void _fetchBookedDates() async {
    final equipmentId = widget.equipmentData['equipmentId'];
    if (equipmentId == null) {
      debugPrint('Warning: equipmentId is null in BookingRequestDialog!');
      return;
    }

    try {
      // Index-free query: only filter by equipmentId
      final snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('equipmentId', isEqualTo: equipmentId)
          .get();

      final List<DateTime> dates = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final String status = data['status'] ?? 'Pending';
        
        // Filter status in Dart to avoid needing a composite index in Firestore
        if (status == 'Accepted' || status == 'Pending') {
          final String? dateStr = data['bookingDate'];
          if (dateStr != null) {
            try {
              final parts = dateStr.split('-');
              if (parts.length == 3) {
                final day = int.parse(parts[0]);
                final month = int.parse(parts[1]);
                final year = int.parse(parts[2]);
                dates.add(DateTime(year, month, day));
              }
            } catch (e) {
              debugPrint('Error parsing date: $e');
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _bookedDates = dates;
          debugPrint('Fetched ${_bookedDates.length} booked/pending dates for equipment $equipmentId');
        });
      }
    } catch (e) {
      debugPrint('Error fetching booked dates: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  bool _isDateBooked(DateTime date) {
    return _bookedDates.any((bookedDate) =>
        bookedDate.year == date.year &&
        bookedDate.month == date.month &&
        bookedDate.day == date.day);
  }

  void _presentDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      selectableDayPredicate: (DateTime day) {
        return !_isDateBooked(day);
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _submitRequest() async {
    if (_nameController.text.isEmpty || _selectedArea == null || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill name, select area and date')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final String equipmentId = widget.equipmentData['equipmentId'] ?? 'unknown';
      final String bookingDate = '${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}';

      // FINAL VALIDATION: Check if someone else booked it while the dialog was open
      final existingCheck = await FirebaseFirestore.instance
          .collection('bookings')
          .where('equipmentId', isEqualTo: equipmentId)
          .where('bookingDate', isEqualTo: bookingDate)
          .get();

      bool alreadyBooked = existingCheck.docs.any((doc) {
        final status = doc.data()['status'] ?? 'Pending';
        return status == 'Accepted' || status == 'Pending';
      });

      if (alreadyBooked) {
        setState(() => _isSubmitting = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Already Booked For That Day'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final String farmerId = FirebaseAuth.instance.currentUser?.uid ?? '';
      
      await FirebaseFirestore.instance.collection('bookings').add({
        'farmerId': farmerId,
        'ownerId': widget.equipmentData['ownerId'],
        'equipmentId': equipmentId,
        'equipment': widget.equipmentData['name'] ?? widget.equipmentData['category'],
        'farmerName': _nameController.text.trim(),
        'hospitalName': _selectedArea, // Reusing hospitalName as per plan/screenshot
        'duration': _duration,
        'bookingDate': bookingDate,
        'message': _messageController.text.trim(),
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context); // close dialog
      Navigator.pop(context); // go back to search screen
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request Sent Successfully!')),
      );
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String ownerName = widget.equipmentData['equipmentData']?['ownerName'] ?? widget.equipmentData['ownerName'] ?? 'Owner';
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              child: Column(
                children: [
                  const Icon(Icons.agriculture, color: AppColors.white, size: 50),
                  const SizedBox(height: 10),
                  const Text(
                    'Request Equipment',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'To: $ownerName',
                    style: const TextStyle(color: AppColors.white),
                  ),
                ],
              ),
            ),
            
            // Form Fields
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildTextField(_nameController, 'Your Name'),
                  const SizedBox(height: 15),
                  
                  // Area Dropdown
                  _buildDropdown(
                    hint: 'Select Farm Area',
                    value: _selectedArea,
                    items: AssetManager.areas,
                    onChanged: (val) => setState(() => _selectedArea = val),
                  ),
                  
                  const SizedBox(height: 15),

                  // Date Picker Picker
                  GestureDetector(
                    onTap: _presentDatePicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      decoration: BoxDecoration(
                        color: AppColors.getCardColor(context),
                        border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            _selectedDate == null 
                                ? 'Select Booking Date' 
                                : '${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}',
                            style: TextStyle(
                              color: _selectedDate == null ? Colors.grey[600] : AppColors.getTextColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),
                  
                  // Duration Dropdown
                  _buildDropdown(
                    hint: 'Select Duration',
                    value: _duration,
                    items: AssetManager.bookingDurations,
                    onChanged: (val) => setState(() => _duration = val),
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Message Field
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.getCardColor(context),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: TextField(
                      controller: _messageController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Message (e.g. Needs driver too)',
                        hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textGrey : AppColors.textLight),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(10),
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
                      _isSubmitting
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _submitRequest,
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

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextField(
        controller: controller,
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
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint),
          isExpanded: true,
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
