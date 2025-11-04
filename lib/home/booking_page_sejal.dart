
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({Key? key}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage>
    with TickerProviderStateMixin {
  // Theme colors
  final Color primaryTeal = const Color(0xFF1D828E);
  final Color accentGreen = const Color.fromARGB(255, 50, 189, 117);

  // Tab state: 0 = Urgent, 1 = Scheduled
  int activeTab = 0;

  // Dummy data with complete tracking information
  final List<Map<String, dynamic>> urgentBookings = [
    {
      'title': 'Plumber - Burst Pipe',
      'datetime': 'Today • 6:30 PM',
      'address': 'Faizpur, Maharashtra',
      'image': 'assets/plum1.jpeg',
      'status': 'On the way',
      'workerName': 'Rajesh Kumar',
      'workerPhone': '+919876543210',
      'eta': '15 mins',
      'workerLatitude': 21.0070,  // Added coordinates
      'workerLongitude': 75.5626,
      'destinationLatitude': 21.0070,
      'destinationLongitude': 75.5626,
      'canTrack': true,  // Added tracking availability flag
    },
    {
      'title': 'Electrician - Short Circuit',
      'datetime': 'Today • 7:10 PM',
      'address': 'Jalgaon',
      'image': 'assets/plum2.jpeg',
      'status': 'On the way',  // Changed to "On the way" for tracking
      'workerName': 'Suresh Patil',
      'workerPhone': '+919876543211',
      'eta': '25 mins',
      'workerLatitude': 21.0486,  // Added coordinates
      'workerLongitude': 75.7822,
      'destinationLatitude': 21.0486,
      'destinationLongitude': 75.7822,
      'canTrack': true,  // Added tracking availability flag
    },
  ];

  final List<Map<String, dynamic>> scheduledBookings = [
    {
      'title': 'Home Cleaning - Deep Clean',
      'datetime': '28 Oct • 10:00 AM',
      'address': 'Near Market',
      'image': 'assets/maid1.jpg',
      'status': 'Scheduled',
      'workerName': 'Priya Sharma',
      'workerPhone': '+919876543212',
      'eta': 'Not started',
      'canTrack': false,  // Cannot track scheduled bookings
    },
    {
      'title': 'Sofa Shampoo',
      'datetime': '30 Oct • 2:00 PM',
      'address': 'Bhosari',
      'image': 'assets/maid2.jpg',
      'status': 'Scheduled',
      'workerName': 'Anita Desai',
      'workerPhone': '+919876543213',
      'eta': 'Not started',
      'canTrack': false,  // Cannot track scheduled bookings
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tab buttons
            Row(
              children: [
                _buildTabButton('Urgent', 0),
                const SizedBox(width: 24),
                _buildTabButton('Scheduled', 1),
              ],
            ),
            const SizedBox(height: 20),
            // List view
            Expanded(
              child: _buildListView(),
            ),
          ],
        ),
      ),
    );
  }

  // Check if tracking is available for a booking
  bool _isTrackingAvailable(Map<String, dynamic> booking) {
    return booking['canTrack'] == true &&
        booking['status'] == 'On the way' &&
        booking['workerLatitude'] != null &&
        booking['workerLongitude'] != null;
  }

  // Check and request location permissions
  Future<bool> _checkLocationPermissions(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are denied. Please enable them in settings.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
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
      }
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
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location services are disabled. Please enable them.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
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
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not launch any maps application'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening maps: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  // Handle track button press
  void _handleTrackWorker(BuildContext context, Map<String, dynamic> booking) {
    if (_isTrackingAvailable(booking)) {
      // Show tracking options
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => _buildTrackingBottomSheet(context, booking),
      );
    } else {
      String message = '';
      
      if (booking['status'] != 'On the way') {
        message = 'Tracking available only when worker is on the way';
      } else if (booking['workerLatitude'] == null || booking['workerLongitude'] == null) {
        message = 'Worker location not available for tracking';
      } else {
        message = 'Tracking not available for this booking';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Tracking bottom sheet
  Widget _buildTrackingBottomSheet(BuildContext context, Map<String, dynamic> booking) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Track ${booking['workerName']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Worker info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: primaryTeal.withOpacity(0.2),
                  child: const Icon(Icons.person, color: Colors.teal),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['workerName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ETA: ${booking['eta']}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${booking['status']}',
                        style: TextStyle(
                          color: Colors.green.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _openMapForNavigation(
                      context,
                      booking['workerLatitude'],
                      booking['workerLongitude'],
                      "Worker Location - ${booking['workerName']}",
                    );
                  },
                  icon: const Icon(Icons.map, size: 20),
                  label: const Text('Open Map'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    try {
                      await _makePhoneCall(booking['workerPhone']);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error making call: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.call, size: 20),
                  label: const Text('Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          // Live tracking button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showLiveTrackingScreen(context, booking);
              },
              icon: const Icon(Icons.location_searching, size: 20),
              label: const Text('Live Tracking'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Live tracking screen
  void _showLiveTrackingScreen(BuildContext context, Map<String, dynamic> booking) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.location_searching, color: Colors.orange),
            const SizedBox(width: 8),
            Text('Live Tracking - ${booking['workerName']}'),
          ],
        ),
        content: SizedBox(
          height: 200,
          child: Column(
            children: [
              // Simulated map view
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map, size: 40, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        'Live Location Tracking',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ETA: ${booking['eta']}',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Tracking info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTrackingInfo('Distance', '2.5 km'),
                  _buildTrackingInfo('Time', booking['eta']),
                  _buildTrackingInfo('Status', 'On the way'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _openMapForNavigation(
                context,
                booking['workerLatitude'],
                booking['workerLongitude'],
                "Worker Location - ${booking['workerName']}",
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryTeal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Open in Maps'),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingInfo(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(String label, int index) {
    final bool selected = (activeTab == index);
    return GestureDetector(
      onTap: () {
        setState(() => activeTab = index);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            style: TextStyle(
              color: selected
                  ? (index == 0 ? Colors.red : accentGreen)
                  : Colors.black87,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 16,
            ),
            child: Text(label),
          ),
          const SizedBox(height: 6),
          // underline
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            height: 3,
            width: selected ? 48 : 0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: selected
                  ? (index == 0 ? Colors.red : accentGreen)
                  : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    final List<Map<String, dynamic>> data = activeTab == 0
        ? urgentBookings
        : scheduledBookings;

    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              activeTab == 0 ? Icons.flash_on : Icons.event_available,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              activeTab == 0
                  ? 'No urgent bookings right now'
                  : 'No scheduled services',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemBuilder: (context, idx) {
        final item = data[idx];
        return _buildBookingCard(item, activeTab == 0);
      },
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemCount: data.length,
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> item, bool isUrgent) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isUrgent
            ? LinearGradient(
                colors: [
                  Colors.red.withOpacity(0.18),
                  Colors.red.withOpacity(0.12),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  primaryTeal.withOpacity(0.18),
                  accentGreen.withOpacity(0.12),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // open booking details - TODO connect real action
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 72,
                      height: 72,
                      child: Image.asset(
                        item['image'] ?? 'assets/plum1.jpeg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.build, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              item['datetime'] ?? '',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item['address'] ?? '',
                                style: TextStyle(color: Colors.grey[700]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Worker info (if available)
                        if (item['workerName'] != null) ...[
                          Row(
                            children: [
                              const Icon(
                                Icons.person,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Worker: ${item['workerName']}',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],

                        // Status + actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Status badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.12),
                                ),
                              ),
                              child: Text(
                                item['status'] ?? '',
                                style: TextStyle(
                                  color: isUrgent
                                      ? Colors.red.shade700
                                      : primaryTeal,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Action buttons
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    _handleTrackWorker(context, item);
                                  },
                                  child: const Text('Track'),
                                ),
                                const SizedBox(width: 4),
                                TextButton(
                                  onPressed: () {
                                    // cancel (if allowed)
                                  },
                                  child: const Text('Cancel'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


