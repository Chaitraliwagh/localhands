import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkerProfilePage extends StatefulWidget {
  final Map<String, dynamic> profile;
  final String category;

  const WorkerProfilePage({
    super.key,
    required this.profile,
    required this.category,
  });

  @override
  State<WorkerProfilePage> createState() => _WorkerProfilePageState();
}

class _WorkerProfilePageState extends State<WorkerProfilePage> {
  int bookingStep = 0;
  bool booked = false;
  bool isFavorite = false;
  int selectedTab = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // Worker details data
  final Map<String, dynamic> workerDetails = {
    'address': '123 Main Street, Mumbai - 400001',
    'message': 'Available for immediate booking. Flexible timing available.',
  };
  
  get CrossNotificationService => null;

  Future<void> bookNow() async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please login to book services"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Sending booking request...'),
            ],
          ),
        ),
      );

      // Get user data from Firestore
      final userDoc = await _firestore.collection('users').doc(_currentUser!.uid).get();
      final userData = userDoc.data() ?? {};
      
      // Generate unique booking ID
      final bookingId = 'booking_${DateTime.now().millisecondsSinceEpoch}_${_currentUser!.uid}';
      
      // Prepare booking data
      final bookingData = {
        'bookingId': bookingId,
        'workerId': widget.profile['id'] ?? widget.profile['uid'] ?? 'unknown_worker',
        'workerName': widget.profile['name'] ?? 'Unknown Worker',
        'workerPhone': widget.profile['phone'] ?? '+919876543210',
        'userId': _currentUser!.uid,
        'userName': userData['name'] ?? _currentUser!.displayName ?? 'Customer',
        'userEmail': _currentUser!.email ?? '',
        'userPhone': userData['phone'] ?? 'Not provided',
        'service': widget.category,
        'serviceCategory': widget.category,
        'description': 'Booking request for ${widget.category} services',
        'location': workerDetails['address'],
        'price': widget.profile['cost'] ?? 'Not specified',
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
        'startDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 1))),
        'rating': widget.profile['rating'] ?? 4.5,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // 1. Create booking request in Firestore
      await _firestore.collection('requests').add(bookingData);

      // 2. Send push notification to worker
      await _sendBookingNotificationToWorker(bookingData);

      // 3. Create notification for worker in Firestore
      await _createWorkerNotification(bookingData);

      // 4. Create notification for the user
      await _firestore.collection('user_notifications').add({
        'userId': _currentUser!.uid,
        'title': 'Booking Request Sent! 📤',
        'body': 'Your ${widget.category} booking request has been sent to ${widget.profile['name'] ?? 'the worker'}. Waiting for confirmation.',
        'type': 'request_sent',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'category': 'info',
        'priority': 'medium',
        'bookingData': bookingData,
      });

      // 5. Create a job entry for the worker
      await _createWorkerJob(bookingData);

      // Close loading dialog
      Navigator.pop(context);

      setState(() {
        booked = true;
        bookingStep = 1;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Booking request sent successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      print('✅ Booking request created and notification sent to worker: ${widget.profile['name']}');

    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      
      print('❌ Error creating booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error sending booking request: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Send push notification to worker using CrossNotificationService
  Future<void> _sendBookingNotificationToWorker(Map<String, dynamic> bookingData) async {
    try {
      final workerId = bookingData['workerId'];
      final workerName = bookingData['workerName'];
      final serviceType = bookingData['service'];
      final customerName = bookingData['userName'];
      final location = bookingData['location'];
      final price = bookingData['price'];

      // Prepare job data for notification
      final jobData = {
        'bookingId': bookingData['bookingId'],
        'service': serviceType,
        'professionalName': workerName,
        'workerId': workerId,
        'customerName': customerName,
        'customerPhone': bookingData['userPhone'],
        'customerUserId': bookingData['userId'],
        'location': location,
        'price': price,
        'status': 'pending',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      // Send notification to worker
      await CrossNotificationService.sendUserToWorkerNotification(
        workerId: workerId,
        title: "New Booking Request! 🎯",
        message: "$customerName requested $serviceType at $location",
        serviceType: serviceType,
        jobData: jobData,
      );

      print('📱 Push notification sent to worker: $workerName');

    } catch (e) {
      print('❌ Error sending push notification: $e');
      // Don't throw error here - the booking should still be created even if notification fails
    }
  }

  /// Create notification for worker in Firestore
  Future<void> _createWorkerNotification(Map<String, dynamic> bookingData) async {
    try {
      final workerId = bookingData['workerId'];
      
      await _firestore.collection('worker_notifications').add({
        'workerId': workerId,
        'title': 'New Booking Request 📋',
        'body': '${bookingData['userName']} requested ${bookingData['service']} at ${bookingData['location']}',
        'type': 'booking_request',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'category': 'info',
        'priority': 'high',
        'senderUserId': bookingData['userId'],
        'bookingData': bookingData,
      });

      print('📋 Notification created for worker in Firestore');
      
    } catch (e) {
      print('❌ Error creating worker notification: $e');
    }
  }

  /// Create a job entry for the worker
  Future<void> _createWorkerJob(Map<String, dynamic> bookingData) async {
    try {
      final workerId = bookingData['workerId'];
      
      await _firestore.collection('worker_jobs').add({
        'workerId': workerId,
        'bookingId': bookingData['bookingId'],
        'title': bookingData['service'],
        'service': bookingData['service'],
        'customer': bookingData['userName'],
        'customerUserId': bookingData['userId'],
        'customerPhone': bookingData['userPhone'],
        'location': bookingData['location'],
        'time': 'ASAP',
        'status': 'pending',
        'paymentStatus': 'Pending',
        'earnings': int.tryParse(bookingData['price'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 500,
        'rating': 0.0,
        'urgent': false,
        'distance': '1.2 km',
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('📝 Job entry created for worker');
      
    } catch (e) {
      print('❌ Error creating worker job: $e');
    }
  }

  // TEST FUNCTION: Add this temporary button to test
  Widget _buildTestButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton(
        onPressed: _testFirestoreConnection,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        child: const Text('Test Firestore Connection'),
      ),
    );
  }

  void _testFirestoreConnection() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ User not logged in');
        return;
      }

      print('=== FIRESTORE TEST ===');
      print('User ID: ${user.uid}');
      print('Worker ID: ${widget.profile['id']}');
      print('Worker Name: ${widget.profile['name']}');

      // Test write to Firestore
      final testDoc = await _firestore.collection('test_connections').add({
        'userId': user.uid,
        'workerId': widget.profile['id'],
        'timestamp': FieldValue.serverTimestamp(),
        'test': 'Connection test successful',
      });

      print('✅ Firestore write successful. Document ID: ${testDoc.id}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Firestore connection test successful!'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      print('❌ Firestore test failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Firestore test failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isFavorite ? 'Added to favorites' : 'Removed from favorites'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> callWorker(String phone) async {
    final Uri callUri = Uri(scheme: 'tel', path: phone);
    
    try {
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cannot make a call.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error making call")),
      );
    }
  }

  // ========== SIMPLIFIED WORKER DETAILS SECTION ==========
  Widget _buildWorkerDetailsSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          const Text(
            "📋 Worker Details",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // Address Field
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Address",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        workerDetails['address'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Message Field
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.message, color: Colors.blue, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Message",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        workerDetails['message'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // TEST BUTTON - Add this to see it in the UI
          const SizedBox(height: 16),
          _buildTestButton(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final name = profile['name'] ?? '';
    final image = profile['image'] ?? '';
    final rating = profile['rating'] ?? 0.0;
    final experience = profile['experience'] ?? 0;
    final cost = profile['cost'] ?? '';
    final phone = profile['phone'] ?? '+919876543210';

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // Header Section
          Container(
            height: 280,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                
                Positioned(
                  top: 40,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                
                Positioned(
                  top: 40,
                  right: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: _toggleFavorite,
                    ),
                  ),
                ),
                
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$experience yrs exp',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Quick Info Cards
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.work_history,
                    title: 'Experience',
                    value: '$experience years',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.currency_rupee,
                    title: 'Rate',
                    value: '₹$cost/hr',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.timer,
                    title: 'Response',
                    value: '15 min',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          
          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildTabButton("About", 0),
                _buildTabButton("Reviews", 1),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: SingleChildScrollView(
              child: _buildTabContent(),
            ),
          ),
        ],
      ),
      
      // Bottom Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Call button
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.phone, color: Colors.blue),
                onPressed: () => callWorker(phone),
              ),
            ),
            const SizedBox(width: 12),
            
            // Main book now button
            Expanded(
              child: SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: booked ? null : bookNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    booked ? "Booking Confirmed" : "Book Now",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceChips(List<dynamic> services) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: services.map((service) {
        return Chip(
          label: Text(
            service.toString(),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue.shade600,
        );
      }).toList(),
    );
  }

  Widget _buildTabContent() {
    final profile = widget.profile;
    final services = profile['services'] as List<dynamic>? ?? [];
    
    switch (selectedTab) {
      case 0: // About Tab
        return Column(
          children: [
            // About Me Section
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "👤 About Me",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Experienced ${widget.category.toLowerCase()} with ${profile['experience']} years of professional service. Specialized in ${services.join(", ").toLowerCase()}.",
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            // Services Offered Section
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "🛠️ Services Offered",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildServiceChips(services),
                ],
              ),
            ),
            
            // Worker Details Section
            _buildWorkerDetailsSection(),
          ],
        );
        
      case 1: // Reviews Tab
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "⭐ Reviews",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "No reviews yet",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
        
      default:
        return Container();
    }
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    bool isSelected = selectedTab == index;
    return Expanded(
      child: Material(
        color: isSelected ? Colors.blue : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            setState(() {
              selectedTab = index;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}