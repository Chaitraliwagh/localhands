
// professional_profile_page.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfessionalProfilePage extends StatefulWidget {
  final Map<String, dynamic> professional;
  final String serviceType;

  const ProfessionalProfilePage({
    Key? key,
    required this.professional,
    required this.serviceType,
  }) : super(key: key);

  @override
  State<ProfessionalProfilePage> createState() => _ProfessionalProfilePageState();

  static void show(BuildContext context, Map<String, dynamic> profile, String serviceType, Function(dynamic) onStepUpdate) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfessionalProfilePage(
          professional: profile,
          serviceType: serviceType,
        ),
      ),
    );
  }
}

class _ProfessionalProfilePageState extends State<ProfessionalProfilePage> {
  bool isFavorite = false;
  int selectedTab = 0;
  bool isLoading = false;
  List<Map<String, dynamic>> reviews = [];
  String selectedService = "";
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  // Notification lists to simulate notification storage
  static List<Map<String, dynamic>> bookingNotifications = [];
  static List<Map<String, dynamic>> requestNotifications = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
    // Auto-select first service
    if (widget.professional["services"] != null && widget.professional["services"].isNotEmpty) {
      selectedService = widget.professional["services"][0];
    }
  }

  void _initializeData() {
    // Initialize reviews
    reviews = [
      {
        "name": "John Doe", 
        "rating": 5.0, 
        "comment": "Excellent service! Fixed my plumbing issue quickly and professionally. Highly recommended!", 
        "days": 2,
        "service": "Pipe Repair"
      },
      {
        "name": "Sarah Smith", 
        "rating": 4.5, 
        "comment": "Professional and on time. Completed the job efficiently and cleaned up afterwards.", 
        "days": 5,
        "service": "Leak Fix"
      },
      {
        "name": "Mike Johnson", 
        "rating": 5.0, 
        "comment": "Great work at reasonable prices. Will definitely hire again for future plumbing needs.", 
        "days": 7,
        "service": "Installation"
      },
      {
        "name": "Emily Chen", 
        "rating": 4.0, 
        "comment": "Good service, arrived on time and fixed the issue. Fair pricing.", 
        "days": 14,
        "service": "Pipe Repair"
      },
    ];
  }

  // ========== ENHANCED PHONE CALLING METHODS ==========

  Future<void> _makePhoneCall(String phoneNumber) async {
    // Clean the phone number - remove any non-digit characters
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Ensure the number has proper format
    if (!cleanNumber.startsWith('+')) {
      // Add country code if missing (adjust for your region)
      cleanNumber = '+1$cleanNumber'; // Change +1 to your country code
    }
    
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanNumber,
    );
    
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
        
        // Show confirmation dialog
        _showCallConfirmation(cleanNumber);
      } else {
        _showCallError(cleanNumber);
      }
    } catch (e) {
      _showCallError(cleanNumber);
    }
  }

  void _showCallConfirmation(String phoneNumber) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling $phoneNumber...'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showCallError(String phoneNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cannot Make Call'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Unable to initiate phone call. This could be because:'),
            const SizedBox(height: 12),
            const Text('• No phone app installed'),
            const Text('• Invalid phone number format'),
            const Text('• Device doesn\'t support calling'),
            const SizedBox(height: 12),
            Text('Phone number: $phoneNumber'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _copyPhoneNumber(phoneNumber);
            },
            child: const Text('Copy Number'),
          ),
        ],
      ),
    );
  }

  void _copyPhoneNumber(String phoneNumber) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Phone number copied to clipboard')),
    );
  }

  void _showCallOptions(String phoneNumber) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              
              // Professional info
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(widget.professional["image"]),
              ),
              const SizedBox(height: 12),
              Text(
                widget.professional["name"],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.professional["services"][0],
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              
              // Phone number
              Text(
                phoneNumber,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),
              
              // Call button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _makePhoneCall(phoneNumber);
                  },
                  icon: const Icon(Icons.phone, color: Colors.white),
                  label: const Text(
                    'CALL NOW',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Alternative options
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _copyPhoneNumber(phoneNumber);
                  },
                  child: const Text('Copy Phone Number'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== NOTIFICATION METHODS ==========
  
  void _sendBookingNotification() {
    // Send request sent notification first
    _sendRequestSentNotification();
    
    // After a delay, send booking confirmed notification
    Future.delayed(const Duration(seconds: 2), () {
      _sendBookingConfirmedNotification();
    });
  }

  void _sendRequestSentNotification() {
    // Create request sent notification
    final requestNotification = {
      "type": "booking",
      "title": "Request Sent 📤",
      "description": "Your booking request for $selectedService with ${widget.professional["name"]} has been sent. Waiting for confirmation.",
      "time": "Just now",
      "isRead": false,
      "icon": Icons.send_rounded,
      "actionText": "Track Status",
      "timestamp": DateTime.now(),
    };

    // Add to notifications list
    requestNotifications.insert(0, requestNotification);
    
    // Show local snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('📤 Booking request sent! Check notifications for status.'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to notifications screen
            _showNotificationPreview("Request Sent", "Your booking request has been sent successfully!");
          },
        ),
      ),
    );

    // Print notification details (for debugging)
    print('📤 REQUEST SENT NOTIFICATION:');
    print('Service: $selectedService');
    print('Professional: ${widget.professional["name"]}');
    print('Time: ${DateTime.now()}');
  }

  void _sendBookingConfirmedNotification() {
    // Create booking confirmed notification
    final bookingNotification = {
      "type": "booking",
      "title": "Booking Confirmed! ✅",
      "description": "Your $selectedService with ${widget.professional["name"]} is confirmed for ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} at ${selectedTime!.format(context)}",
      "time": "Just now",
      "isRead": false,
      "icon": Icons.check_circle_rounded,
      "actionText": "View Booking",
      "timestamp": DateTime.now(),
      "bookingDetails": {
        "service": selectedService,
        "professional": widget.professional["name"],
        "date": "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
        "time": selectedTime!.format(context),
        "price": widget.professional["price"],
        "reference": "#${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}"
      }
    };

    // Add to notifications list
    bookingNotifications.insert(0, bookingNotification);
    
    // Show local snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✅ Booking confirmed! Check notifications for details.'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            _showNotificationPreview("Booking Confirmed", "Your service has been successfully booked!");
          },
        ),
      ),
    );

    // Print notification details (for debugging)
    print('✅ BOOKING CONFIRMED NOTIFICATION:');
    print('Service: $selectedService');
    print('Professional: ${widget.professional["name"]}');
    print('Date: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}');
    print('Time: ${selectedTime!.format(context)}');
    print('Reference: #${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}');
  }

  void _showNotificationPreview(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, this would navigate to notifications screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Navigate to Notifications screen to see all notifications'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('View All Notifications'),
          ),
        ],
      ),
    );
  }

  // Method to get all notifications (for display in notifications screen)
  static List<Map<String, dynamic>> getAllNotifications() {
    List<Map<String, dynamic>> allNotifications = [];
    allNotifications.addAll(bookingNotifications);
    allNotifications.addAll(requestNotifications);
    
    // Sort by timestamp (newest first)
    allNotifications.sort((a, b) => b["timestamp"].compareTo(a["timestamp"]));
    
    return allNotifications;
  }

  // ========== EXISTING METHODS (with notification integration) ==========

  void _confirmBooking() {
    Navigator.pop(context); // Close bottom sheet
    
    // Send booking notification
    _sendBookingNotification();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Confirmed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your $selectedService with ${widget.professional["name"]} has been booked.'),
            const SizedBox(height: 8),
            Text('Date: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'),
            Text('Time: ${selectedTime!.format(context)}'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Booking Reference: #${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '📱 Notifications have been sent to your account',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Header with image and back button
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: _shareProfile,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Profile image
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(widget.professional["image"]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Gradient overlay
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
                  // Professional name and rating at bottom
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.professional["name"],
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
                                    widget.professional["rating"].toStringAsFixed(1),
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
                                widget.professional["experience"],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (widget.professional["isVerified"] ?? false) ...[
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.verified, color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      "Verified",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverList(
            delegate: SliverChildListDelegate([
              // Quick info cards
              _buildQuickInfoSection(),
              
              // Tabs
              _buildTabSection(),
              
              // Tab content
              _buildTabContent(),
              
              const SizedBox(height: 100), // Space for bottom button
            ]),
          ),
        ],
      ),
      
      // Fixed Book Now button at bottom
      bottomNavigationBar: _buildBookNowButton(),
    );
  }

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isFavorite ? 'Added to favorites' : 'Removed from favorites'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareProfile() {
    // Simulate sharing functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Profile'),
        content: const Text('Profile link copied to clipboard!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Service and pricing card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Starting from",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "\$${widget.professional["price"]}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.professional["services"].map<Widget>((service) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedService = service;
                          });
                          _showServiceSelectedSnackbar(service);
                        },
                        child: Chip(
                          label: Text(service),
                          backgroundColor: selectedService == service 
                              ? Colors.blue.withOpacity(0.3)
                              : Colors.blue.withOpacity(0.1),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Stats row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "Jobs Done", 
                  "${widget.professional["jobsCompleted"]}", 
                  Icons.work,
                  onTap: () => _showJobsCompletedDialog()
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  "Response Time", 
                  widget.professional["responseTime"], 
                  Icons.timer,
                  onTap: () => _showResponseTimeInfo()
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  "Success Rate", 
                  widget.professional["successRate"], 
                  Icons.verified,
                  onTap: () => _showSuccessRateInfo()
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: Colors.blue, size: 20),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showServiceSelectedSnackbar(String service) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$service selected for booking'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showJobsCompletedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Experience'),
        content: Text('${widget.professional["name"]} has successfully completed ${widget.professional["jobsCompleted"]} jobs with a ${widget.professional["successRate"]} success rate.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showResponseTimeInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Response Time'),
        content: Text('${widget.professional["name"]} typically responds within ${widget.professional["responseTime"]} for urgent bookings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessRateInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success Rate'),
        content: Text('${widget.professional["name"]} maintains a ${widget.professional["successRate"]} success rate based on customer satisfaction and job completion.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              _buildTabButton("About", 0),
              _buildTabButton("Services", 1),
              _buildTabButton("Reviews", 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    bool isSelected = selectedTab == index;
    return Expanded(
      child: Material(
        color: isSelected ? Colors.blue : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {
            setState(() {
              selectedTab = index;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (selectedTab) {
      case 0:
        return _buildAboutTab();
      case 1:
        return _buildServicesTab();
      case 2:
        return _buildReviewsTab();
      default:
        return _buildAboutTab();
    }
  }

  Widget _buildAboutTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "About Professional",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Experienced ${widget.serviceType.toLowerCase()} with ${widget.professional["experience"]} in the field. "
            "Specialized in ${widget.professional["services"].join(", ").toLowerCase()}. "
            "Committed to providing high-quality service with attention to detail and customer satisfaction.",
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          
          const Text(
            "Contact Information",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildContactInfo(),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildContactRow(
              Icons.location_on, 
              widget.professional["address"],
              onTap: () => _openMaps()
            ),
            const SizedBox(height: 12),
            _buildContactRow(
              Icons.phone, 
              widget.professional["phone"],
              onTap: () => _showCallOptions(widget.professional["phone"])
            ),
            const SizedBox(height: 12),
            _buildContactRow(
              Icons.email, 
              widget.professional["email"],
              onTap: () => _sendEmail(widget.professional["email"])
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[50],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getContactLabel(icon),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getActionIcon(icon),
                  color: Colors.white,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getContactLabel(IconData icon) {
    switch (icon) {
      case Icons.phone:
        return 'PHONE NUMBER';
      case Icons.email:
        return 'EMAIL';
      case Icons.location_on:
        return 'ADDRESS';
      default:
        return 'CONTACT';
    }
  }

  IconData _getActionIcon(IconData icon) {
    switch (icon) {
      case Icons.phone:
        return Icons.phone;
      case Icons.email:
        return Icons.email;
      case Icons.location_on:
        return Icons.directions;
      default:
        return Icons.arrow_forward;
    }
  }

  Future<void> _openMaps() async {
    // Simulate opening maps
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Open Location'),
        content: const Text('Would you like to open this location in maps?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening maps...')),
              );
            },
            child: const Text('Open Maps'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch email app')),
      );
    }
  }

  Widget _buildServicesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Available Services",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.professional["services"].map((service) => 
            _buildServiceItem(service)
          ).toList(),
          const SizedBox(height: 20),
          
          const Text(
            "Service Areas",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              "City Center",
              "Suburbs", 
              "North Area",
              "South Area",
              "East District",
              "West Zone"
            ].map((area) => Chip(
              label: Text(area),
              backgroundColor: Colors.green.withOpacity(0.1),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String service) {
    int serviceIndex = widget.professional["services"].indexOf(service);
    int servicePrice = widget.professional["price"] + serviceIndex * 10;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.green),
        title: Text(service),
        subtitle: Text("${serviceIndex + 1} hour service"),
        trailing: Text(
          "\$$servicePrice",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        onTap: () {
          setState(() {
            selectedService = service;
          });
          _showServiceDetails(service, servicePrice);
        },
      ),
    );
  }

  void _showServiceDetails(String service, int price) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(service),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price: \$$price'),
            const SizedBox(height: 8),
            const Text('Includes:'),
            const Text('• Professional assessment'),
            const Text('• Quality materials'),
            const Text('• 30-day service warranty'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                selectedService = service;
              });
            },
            child: const Text('Select Service'),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Column(
                    children: [
                      Text(
                        widget.professional["rating"].toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (index) => 
                          Icon(
                            Icons.star,
                            color: index < widget.professional["rating"].floor() 
                                ? Colors.amber 
                                : Colors.grey[300],
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${reviews.length} reviews",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRatingBar(5, 0.8),
                        _buildRatingBar(4, 0.15),
                        _buildRatingBar(3, 0.04),
                        _buildRatingBar(2, 0.01),
                        _buildRatingBar(1, 0.0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Customer Reviews",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: _addReview,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Review'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          ...reviews.map((review) => _buildReviewCard(review)).toList(),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text("$stars", style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[200],
              color: Colors.amber,
            ),
          ),
          const SizedBox(width: 8),
          Text("${(percentage * 100).toInt()}%", style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    review["name"][0],
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review["name"],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          ...List.generate(5, (index) => Icon(
                            Icons.star,
                            color: index < review["rating"] ? Colors.amber : Colors.grey[300],
                            size: 16,
                          )),
                          const SizedBox(width: 8),
                          Text(
                            "${review["days"]} days ago",
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      if (review["service"] != null) ...[
                        const SizedBox(height: 4),
                        Chip(
                          label: Text(review["service"]!),
                          backgroundColor: Colors.green.withOpacity(0.1),
                          labelStyle: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(review["comment"]),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.thumb_up, size: 16),
                  onPressed: () => _likeReview(review),
                ),
                const Text('Helpful'),
                const Spacer(),
                TextButton(
                  onPressed: () => _reportReview(review),
                  child: const Text('Report', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _likeReview(Map<String, dynamic> review) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Liked ${review["name"]}\'s review')),
    );
  }

  void _reportReview(Map<String, dynamic> review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Review'),
        content: const Text('Why are you reporting this review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Review reported for moderation')),
              );
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void _addReview() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Review'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please book a service first to leave a review.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookNowButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _handleBookNow,
              icon: const Icon(Icons.calendar_today, size: 20),
              label: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      "Book Now",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.message, color: Colors.blue),
              onPressed: _showMessageDialog,
            ),
          ),
        ],
      ),
    );
  }

  void _handleBookNow() {
    if (!(widget.professional["isAvailable"] ?? true)) {
      _showNotAvailableDialog();
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
      _showBookingOptions();
    });
  }

  void _showNotAvailableDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Not Available'),
        content: Text('${widget.professional["name"]} is not available for new bookings at the moment.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showBookingOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Book Service",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Service Selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select Service",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: widget.professional["services"].map<Widget>((service) {
                      return ChoiceChip(
                        label: Text(service),
                        selected: selectedService == service,
                        onSelected: (selected) {
                          setState(() {
                            selectedService = service;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Date and Time Selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select Date & Time",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _selectDate,
                          icon: const Icon(Icons.calendar_today),
                          label: Text(selectedDate == null 
                              ? "Select Date" 
                              : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _selectTime,
                          icon: const Icon(Icons.access_time),
                          label: Text(selectedTime == null 
                              ? "Select Time" 
                              : selectedTime!.format(context)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Booking Summary
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        "Booking Summary",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildBookingSummaryRow("Service", selectedService),
                      _buildBookingSummaryRow("Professional", widget.professional["name"]),
                      _buildBookingSummaryRow("Price", "\$${widget.professional["price"]}"),
                      if (selectedDate != null && selectedTime != null)
                        _buildBookingSummaryRow(
                          "Schedule", 
                          "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} at ${selectedTime!.format(context)}"
                        ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: (selectedDate != null && selectedTime != null) 
                            ? _confirmBooking 
                            : null,
                        child: const Text("Confirm Booking"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _showMessageDialog() {
    TextEditingController messageController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Send Message"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('To: ${widget.professional["name"]}'),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (messageController.text.isNotEmpty) {
                Navigator.pop(context);
                _showMessageSentDialog();
              }
            },
            child: const Text("Send Message"),
          ),
        ],
      ),
    );
  }

  void _showMessageSentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Message Sent'),
        content: const Text('Your message has been sent to the professional. They will respond shortly.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Helper list (you might want to move this to a provider)
List<Map<String, dynamic>> profiles = [];