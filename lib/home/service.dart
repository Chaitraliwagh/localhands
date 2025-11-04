import 'package:flutter/material.dart';
import 'package:localhands_app/beauty_screen.dart';
import 'package:localhands_app/plumber_screen.dart';
import 'package:localhands_app/view/booking_new.dart';
import 'package:localhands_app/view/maid.dart';
import 'package:localhands_app/home/home_screen.dart';
import 'package:localhands_app/home/booking_page_sejal.dart';
import 'package:localhands_app/home/notification.dart';
import 'package:iconsax/iconsax.dart';

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  int _selectedIndex = 1;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> allServices = [
    {
      "title": "Salon for Women",
      "image": "assets/services/salonservice.jpg",
      "screen": const BeautyScreen(),
    },
    {
      "title": "Plumber",
      "image": "assets/services/plumbingservice.jpg",
      "screen": const PlumberScreen(),
    },
    {
      "title": "Maid",
      "image": "assets/services/maidservice.jpg",
      "screen": const MaidScreen(),
    },
    {
      "title": "Baby Sitter",
      "image": "assets/child-care.jpeg",
      "screen": const MaidScreen(),
    },
    {
      "title": "Electrician",
      "image": "assets/services/electricianservice.jpg",
      "screen": const PlumberScreen(),
    },
    {
      "title": "Catering",
      "image": "assets/caterings.jpg",
      "screen": const PlumberScreen(),
    },
    {
      "title": "Car Wash",
      "image": "assets/services/carwash.jpg",
      "screen": const PlumberScreen(),
    },
    {
      "title": "Painting",
      "image": "assets/services/paintingservice.jpg",
      "screen": const PlumberScreen(),
    },
    {
      "title": "Computer Repair",
      "image": "assets/services/comprepair.jpg",
      "screen": const PlumberScreen(),
    },
  ];

  List<Map<String, dynamic>> displayedServices = [];

  @override
  void initState() {
    super.initState();
    displayedServices = List.from(allServices);
    _searchController.addListener(() {
      filterServices(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void filterServices(String query) {
    setState(() {
      if (query.isEmpty) {
        displayedServices = List.from(allServices);
      } else {
        displayedServices = allServices
            .where((service) =>
                service["title"].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ProfessionalProfilePage(
            professional: {}, // Add appropriate professional data here
            serviceType: 'default', // Add appropriate service type here
          ),
        ),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NotificationScreen()),
      );
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search services...",
          hintStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: Icon(Iconsax.search_normal, color: Colors.grey.shade600),
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: const Color(0xFF1D828E), width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.black, // Changed to black
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navBarItem(Iconsax.home, "Home", 0),
          _navBarItem(Iconsax.category, "Services", 1),
          _navBarItem(Iconsax.card_tick, "Booking", 2),
          _navBarItem(Iconsax.notification, "Notifications", 3),
        ],
      ),
    );
  }

  Widget _navBarItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.white54,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white54,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => service["screen"]),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white, // Simple white background
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 80,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey.shade100,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        service["image"],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: Icon(Iconsax.category, color: Colors.grey.shade400),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    service["title"],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF1D828E),
                            const Color.fromARGB(255, 50, 189, 117),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Iconsax.arrow_right_3,
                        size: 16,
                        color: Colors.white,
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar with gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1D828E),
                    const Color.fromARGB(255, 50, 189, 117),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    "All Services",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSearchBar(),
                ],
              ),
            ),
            
            // Services count
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    "${displayedServices.length} services available",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            // Services Grid
            Expanded(
              child: displayedServices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.search_status,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No services found",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Try searching with different keywords",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: displayedServices.length,
                      itemBuilder: (context, index) {
                        return _buildServiceCard(displayedServices[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}