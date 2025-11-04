import 'package:flutter/material.dart';
import 'package:localhands_app/home/booking_page_sejal.dart';
import 'package:localhands_app/home/home_screen.dart';
import 'package:localhands_app/home/custom_bottom_nav.dart';
import 'package:localhands_app/home/service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:localhands_app/view/booking_new.dart';
import 'package:geolocator/geolocator.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int _selectedIndex = 3; // Notifications is selected

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ServiceScreen()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BookingPage()),
      );
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: const Color(0xFF1D828E),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // Mark all as read functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications marked as read'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
      body: const NotificationList(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class NotificationList extends StatelessWidget {
  const NotificationList({super.key});

  final List<NotificationItem> notifications = const [
    NotificationItem(
      type: NotificationType.otp,
      title: "OTP Verification",
      description: "Your OTP for service booking is 784592. Valid for 10 minutes.",
      time: "Just now",
      isRead: false,
      icon: Icons.security_rounded,
      actionText: "Verify",
      otpCode: "784592",
    ),
    NotificationItem(
      type: NotificationType.workerOut,
      title: "Worker On The Way! 🚗",
      description: "John is on the way to your location. ETA: 15 minutes",
      time: "10 mins ago",
      isRead: false,
      icon: Icons.delivery_dining_rounded,
      actionText: "Track",
      workerName: "John Doe",
      workerPhone: "+1234567890",
      eta: "15 mins",
      destinationAddress: "123 Main Street, City, State 12345",
      workerLatitude: 40.7128,
      workerLongitude: -74.0060,
    ),
    NotificationItem(
      type: NotificationType.upcomingService,
      title: "Upcoming Service Tomorrow",
      description: "Your AC maintenance service is scheduled for tomorrow at 2:00 PM",
      time: "1 hour ago",
      isRead: false,
      icon: Icons.schedule_rounded,
      actionText: "View Details",
      serviceDate: "Tomorrow, 2:00 PM",
      serviceType: "AC Maintenance",
    ),
    NotificationItem(
      type: NotificationType.festive,
      title: "Diwali Cleaning Special! 🪔",
      description: "Get your home sparkling clean for Diwali. Book maid services now!",
      time: "2 hours ago",
      isRead: false,
      icon: Icons.celebration_rounded,
      actionText: "Book Maid",
    ),
    NotificationItem(
      type: NotificationType.workerOut,
      title: "Electrician En Route",
      description: "David is coming for electrical repairs. ETA: 8 minutes",
      time: "5 mins ago",
      isRead: false,
      icon: Icons.electric_bolt_rounded,
      actionText: "Track",
      workerName: "David Smith",
      workerPhone: "+1987654321",
      eta: "8 mins",
      destinationAddress: "456 Oak Avenue, City, State 12345",
      workerLatitude: 40.7589,
      workerLongitude: -73.9851,
    ),
    NotificationItem(
      type: NotificationType.booking,
      title: "Booking Confirmed ✅",
      description: "Your plumbing service has been confirmed for tomorrow at 10:00 AM",
      time: "3 hours ago",
      isRead: true,
      icon: Icons.check_circle_rounded,
      actionText: "View Booking",
    ),
    NotificationItem(
      type: NotificationType.offer,
      title: "Special Offer! 🎉",
      description: "Get 25% off on your next cleaning service. Limited time offer!",
      time: "1 day ago",
      isRead: true,
      icon: Icons.local_offer_rounded,
      actionText: "Claim Offer",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              "No new notifications yet",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            Text(
              "We'll notify you when something arrives",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return NotificationCard(notification: notification);
      },
    );
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationItem notification;

  const NotificationCard({super.key, required this.notification});

  // Check and request location permissions
  Future<bool> _checkLocationPermissions(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are denied. Please enable them in settings.'),
            backgroundColor: Colors.orange,
          ),
        );
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Location permissions are permanently denied. Please enable them in app settings.'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Open Settings',
            onPressed: () {
              Geolocator.openAppSettings();
            },
          ),
        ),
      );
      return false;
    }
    
    return true;
  }

  // Function to open maps for navigation
  Future<void> _openMapForNavigation(BuildContext context, double destLat, double destLng, String destinationName) async {
    try {
      // Check location permissions first
      bool hasPermission = await _checkLocationPermissions(context);
      if (!hasPermission) {
        return; // Exit if permissions are denied
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location services are disabled. Please enable them.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Get current location
      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Create Google Maps URL with directions from current location to destination
      final String googleMapsUrl = 
          'https://www.google.com/maps/dir/?api=1&origin=${currentPosition.latitude},${currentPosition.longitude}&destination=$destLat,$destLng&travelmode=driving&dir_action=navigate';
      
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(
          Uri.parse(googleMapsUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback: Simple Google Maps location without directions
        final String simpleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$destLat,$destLng';
        if (await canLaunchUrl(Uri.parse(simpleMapsUrl))) {
          await launchUrl(
            Uri.parse(simpleMapsUrl),
            mode: LaunchMode.externalApplication,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch any maps application'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening maps: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Function to make REAL phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      // Remove any spaces or special characters from the phone number
      String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[-\s()]'), '');
      
      final Uri launchUri = Uri(
        scheme: 'tel',
        path: cleanedNumber,
      );
      
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        throw 'Could not launch phone app';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Function to open OTP verification screen
  void _openOtpVerification(BuildContext context, String otpCode) {
    TextEditingController otpController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("OTP Verification"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter the OTP sent to your mobile:"),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue),
                ),
                child: Text(
                  otpCode,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    letterSpacing: 4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: otpController,
                decoration: InputDecoration(
                  labelText: "Enter OTP",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: "Enter 6-digit OTP",
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, letterSpacing: 4),
                maxLength: 6,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (otpController.text == otpCode) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("OTP verified successfully!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Invalid OTP. Please try again."),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text("Verify"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF1D828E);
    final Color secondaryColor = const Color.fromARGB(255, 50, 189, 117);

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primaryColor.withOpacity(0.08),
        secondaryColor.withOpacity(0.05),
      ],
    );

    final readBackground = Colors.white;

    Color getNotificationColor() {
      switch (notification.type) {
        case NotificationType.otp:
          return Colors.blue;
        case NotificationType.workerOut:
          return Colors.purple;
        case NotificationType.upcomingService:
          return Colors.teal;
        case NotificationType.festive:
          return Colors.deepOrange;
        case NotificationType.offer:
          return Colors.orange;
        case NotificationType.booking:
          return secondaryColor;
        case NotificationType.reminder:
          return primaryColor;
        case NotificationType.emergency:
          return Colors.red;
        case NotificationType.referral:
          return Colors.purple;
        case NotificationType.rating:
          return Colors.amber;
        default:
          return primaryColor;
      }
    }

    final notificationColor = getNotificationColor();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: notification.isRead ? Colors.grey.shade200 : primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: notification.isRead ? null : gradient,
          color: notification.isRead ? readBackground : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: notification.isRead 
                          ? LinearGradient(
                              colors: [
                                notificationColor.withOpacity(0.1),
                                notificationColor.withOpacity(0.05),
                              ],
                            )
                          : LinearGradient(
                              colors: [
                                primaryColor.withOpacity(0.2),
                                secondaryColor.withOpacity(0.1),
                              ],
                            ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: notification.isRead 
                            ? notificationColor.withOpacity(0.3)
                            : primaryColor.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      notification.icon,
                      color: notification.isRead ? notificationColor : primaryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                                  color: notification.isRead ? Colors.black87 : primaryColor,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [primaryColor, secondaryColor],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        
                        // OTP Specific UI
                        if (notification.type == NotificationType.otp)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification.description,
                                style: TextStyle(
                                  color: notification.isRead ? Colors.grey[700] : Colors.black87,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                                ),
                                child: Text(
                                  "OTP: ${notification.otpCode}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ],
                          )
                        
                        // Worker Out Specific UI
                        else if (notification.type == NotificationType.workerOut)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification.description,
                                style: TextStyle(
                                  color: notification.isRead ? Colors.grey[700] : Colors.black87,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.person, size: 16, color: Colors.purple),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Worker: ${notification.workerName}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.access_time, size: 16, color: Colors.purple),
                                  const SizedBox(width: 4),
                                  Text(
                                    "ETA: ${notification.eta}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              if (notification.destinationAddress != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.location_on, size: 16, color: Colors.purple),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        "Address: ${notification.destinationAddress!}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          )
                        
                        // Upcoming Service Specific UI
                        else if (notification.type == NotificationType.upcomingService)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification.description,
                                style: TextStyle(
                                  color: notification.isRead ? Colors.grey[700] : Colors.black87,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 16, color: Colors.teal),
                                  const SizedBox(width: 4),
                                  Text(
                                    notification.serviceDate!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.build, size: 16, color: Colors.teal),
                                  const SizedBox(width: 4),
                                  Text(
                                    notification.serviceType!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        
                        // Default description for other types
                        else
                          Text(
                            notification.description,
                            style: TextStyle(
                              color: notification.isRead ? Colors.grey[700] : Colors.black87,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              notification.time,
                              style: TextStyle(
                                fontSize: 12,
                                color: notification.isRead ? Colors.grey[500] : primaryColor.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            
                            // Special buttons for worker out notifications
                            if (notification.type == NotificationType.workerOut)
                              Row(
                                children: [
                                  Container(
                                    height: 32,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        _handleOpenMap(context, notification);
                                      },
                                      icon: const Icon(Icons.map, size: 16),
                                      label: const Text("Open Map"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.purple,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        elevation: 1,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    height: 32,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        _handleCallWorker(context, notification);
                                      },
                                      icon: const Icon(Icons.call, size: 16),
                                      label: const Text("Call"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        elevation: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            
                            // OTP verification button
                            else if (notification.type == NotificationType.otp)
                              Container(
                                height: 32,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    _openOtpVerification(context, notification.otpCode!);
                                  },
                                  icon: const Icon(Icons.verified, size: 16),
                                  label: const Text("Verify OTP"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    elevation: 1,
                                  ),
                                ),
                              )
                            
                            // Regular action button for other notifications
                            else if (notification.actionText != null)
                              Container(
                                height: 32,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _handleNotificationAction(context, notification);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: notification.isRead ? notificationColor : primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    elevation: 1,
                                  ),
                                  child: Text(
                                    notification.actionText!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
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
            ],
          ),
        ),
      ),
    );
  }

  void _handleNotificationAction(BuildContext context, NotificationItem notification) {
    final snackBar = SnackBar(
      content: Text('Action: ${notification.actionText}'),
      backgroundColor: const Color(0xFF1D828E),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _handleOpenMap(BuildContext context, NotificationItem notification) async {
    try {
      if (notification.workerLatitude != null && notification.workerLongitude != null) {
        // Show loading message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opening maps with navigation...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 1),
          ),
        );

        await _openMapForNavigation(
          context,
          notification.workerLatitude!,
          notification.workerLongitude!,
          "Worker Location - ${notification.workerName}",
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location data not available'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening map: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleCallWorker(BuildContext context, NotificationItem notification) async {
    try {
      if (notification.workerPhone != null) {
        // Show preparing message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Calling ${notification.workerName}...'),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 1),
          ),
        );

        // Small delay to show the message
        await Future.delayed(const Duration(milliseconds: 800));
        
        // Make the actual phone call
        await _makePhoneCall(notification.workerPhone!);
        
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone number not available'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot make call: $e'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _handleCallWorker(context, notification),
          ),
        ),
      );
    }
  }
}

class NotificationItem {
  final NotificationType type;
  final String title;
  final String description;
  final String time;
  final bool isRead;
  final IconData icon;
  final String? actionText;
  final String? otpCode;
  final String? workerName;
  final String? workerPhone;
  final String? eta;
  final String? destinationAddress;
  final double? workerLatitude;
  final double? workerLongitude;
  final String? serviceDate;
  final String? serviceType;

  const NotificationItem({
    required this.type,
    required this.title,
    required this.description,
    required this.time,
    required this.isRead,
    required this.icon,
    this.actionText,
    this.otpCode,
    this.workerName,
    this.workerPhone,
    this.eta,
    this.destinationAddress,
    this.workerLatitude,
    this.workerLongitude,
    this.serviceDate,
    this.serviceType,
  });
}

enum NotificationType {
  otp,
  workerOut,
  upcomingService,
  festive,
  seasonal,
  offer,
  booking,
  reminder,
  emergency,
  referral,
  rating,
}