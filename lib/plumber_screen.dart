import 'package:flutter/material.dart';
import 'package:localhands_app/view/booking_new.dart';
import 'package:localhands_app/home/booking_page_sejal.dart';

class PlumberScreen extends StatefulWidget {
  const PlumberScreen({super.key});

  @override
  State<PlumberScreen> createState() => _PlumberScreenState();
}

class _PlumberScreenState extends State<PlumberScreen> {
  bool bookingStarted = false;
  int bookingStep = 0;

  final List<Map<String, dynamic>> allProfiles = List.generate(10, (index) {
    return {
      "name": "Plumber ${index + 1}",
      "address": "Street ${index + 1}, City",
      "rating": 4.0 + (index % 5 + 1) * 0.1,
      "price": 100 + index * 20,
      "services": ["Pipe Repair", "Leak Fix", "Installation"],
      "image": "assets/plum${(index % 5) + 1}.jpeg",
      "distance": "${1 + index % 10} km",
      "gender": index % 3 == 0 ? "Male" : index % 3 == 1 ? "Female" : "Other",
      "isUrgentAvailable": index % 2 == 0,
      "experience": "${2 + index % 8} years",
      "phone": "+1 (555) 123-456${index}",
      "email": "plumber${index + 1}@localhands.com",
      "responseTime": "${5 + index % 10} mins",
      "successRate": "${95 + index % 5}%",
      "jobsCompleted": 100 + index * 25,
      "location": index % 4 == 0 ? "Nearby" : index % 4 == 1 ? "City Center" : index % 4 == 2 ? "Suburb" : "Downtown",
    };
  });

  // Enhanced Filter States
  String selectedLocation = 'All';
  String selectedCostRange = 'All';
  double minRating = 0.0;
  bool urgentOnly = false;
  List<String> selectedServices = [];
  String selectedGender = 'All';
  String selectedSortBy = 'Recommended';

  // Available options for filters
  final List<String> locations = ['All', 'Nearby', 'City Center', 'Suburb', 'Downtown'];
  final List<String> costRanges = ['All', 'Under \$100', '\$100-\$200', '\$200-\$300', 'Above \$300'];
  final List<String> allServices = ['Pipe Repair', 'Leak Fix', 'Installation', 'Maintenance', 'Emergency', 'Consultation'];
  final List<String> genders = ['All', 'Male', 'Female', 'Other'];
  final List<String> sortOptions = ['Recommended', 'Rating: High to Low', 'Cost: Low to High', 'Cost: High to Low', 'Experience: High to Low'];

  // Get filtered and sorted profiles with enhanced filtering
  List<Map<String, dynamic>> get filteredProfiles {
    List<Map<String, dynamic>> result = List.from(allProfiles);
    
    // Apply advanced filters
    result = result.where((profile) {
      // Location filter
      if (selectedLocation != 'All' && profile['location'] != selectedLocation) {
        return false;
      }

      // Cost filter
      if (selectedCostRange != 'All') {
        final price = profile['price'];
        switch (selectedCostRange) {
          case 'Under \$100':
            if (price >= 100) return false;
            break;
          case '\$100-\$200':
            if (price < 100 || price > 200) return false;
            break;
          case '\$200-\$300':
            if (price < 200 || price > 300) return false;
            break;
          case 'Above \$300':
            if (price <= 300) return false;
            break;
        }
      }

      // Rating filter
      if (profile['rating'] < minRating) {
        return false;
      }

      // Urgent filter
      if (urgentOnly && !profile['isUrgentAvailable']) {
        return false;
      }

      // Gender filter
      if (selectedGender != 'All' && profile['gender'] != selectedGender) {
        return false;
      }

      // Services filter
      if (selectedServices.isNotEmpty) {
        final profileServices = List<String>.from(profile['services']);
        if (!selectedServices.any((service) => profileServices.contains(service))) {
          return false;
        }
      }

      return true;
    }).toList();

    // Apply sorting
    switch (selectedSortBy) {
      case 'Rating: High to Low':
        result.sort((a, b) => b['rating'].compareTo(a['rating']));
        break;
      case 'Cost: Low to High':
        result.sort((a, b) => a['price'].compareTo(b['price']));
        break;
      case 'Cost: High to Low':
        result.sort((a, b) => b['price'].compareTo(a['price']));
        break;
      case 'Experience: High to Low':
        result.sort((a, b) => b['experience'].compareTo(a['experience']));
        break;
      case 'Recommended':
      default:
        // Default sorting: urgent available first, then by rating
        result.sort((a, b) {
          if (a['isUrgentAvailable'] && !b['isUrgentAvailable']) return -1;
          if (!a['isUrgentAvailable'] && b['isUrgentAvailable']) return 1;
          return b['rating'].compareTo(a['rating']);
        });
        break;
    }
    
    return result;
  }

  int get activeFilterCount {
    int count = 0;
    if (selectedLocation != 'All') count++;
    if (selectedCostRange != 'All') count++;
    if (minRating > 0.0) count++;
    if (urgentOnly) count++;
    if (selectedGender != 'All') count++;
    if (selectedServices.isNotEmpty) count++;
    if (selectedSortBy != 'Recommended') count++;
    return count;
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        selectedLocation: selectedLocation,
        selectedCostRange: selectedCostRange,
        minRating: minRating,
        urgentOnly: urgentOnly,
        selectedGender: selectedGender,
        selectedSortBy: selectedSortBy,
        selectedServices: selectedServices,
        locations: locations,
        costRanges: costRanges,
        genders: genders,
        sortOptions: sortOptions,
        allServices: allServices,
        onLocationChanged: (value) => setState(() => selectedLocation = value),
        onCostRangeChanged: (value) => setState(() => selectedCostRange = value),
        onRatingChanged: (value) => setState(() => minRating = value),
        onUrgentChanged: (value) => setState(() => urgentOnly = value),
        onGenderChanged: (value) => setState(() => selectedGender = value),
        onSortByChanged: (value) => setState(() => selectedSortBy = value),
        onServicesChanged: (services) => setState(() => selectedServices = services),
        onReset: () {
          setState(() {
            selectedLocation = 'All';
            selectedCostRange = 'All';
            minRating = 0.0;
            urgentOnly = false;
            selectedGender = 'All';
            selectedSortBy = 'Recommended';
            selectedServices = [];
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget buildMilestone() {
    final steps = ["Selected", "Scheduled", "Request Sent", "Booking Confirmed"];
    return Container(
      color: Colors.white.withOpacity(0.9),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isEven) {
            int stepIndex = i ~/ 2;
            bool isCompleted = bookingStep > stepIndex;
            bool isCurrent = bookingStep == stepIndex;
            return Column(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: isCompleted || isCurrent ? Colors.green : Colors.grey[300],
                  child: isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : Text(
                          "${stepIndex + 1}",
                          style: TextStyle(
                              color: isCurrent ? Colors.white : Colors.black54,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 60,
                  child: Text(
                    steps[stepIndex],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCurrent ? Colors.green : Colors.black54),
                  ),
                ),
              ],
            );
          } else {
            int leftStep = i ~/ 2;
            bool isCompleted = bookingStep > leftStep;
            return Expanded(
              child: Container(
                height: 2,
                color: isCompleted ? Colors.green : Colors.grey[300],
              ),
            );
          }
        }),
      ),
    );
  }

  // Function to handle profile navigation
  void _openProfile(Map<String, dynamic> profile) {
    // Show booking options first (same as before)
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBookingOptionsSheet(profile),
    );
  }

  Widget _buildBookingOptionsSheet(Map<String, dynamic> profile) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
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
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage(profile["image"]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile["name"],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Starting from \$${profile["price"]}",
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Booking Options
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select Booking Type",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Urgent Booking Option
                  _buildBookingOptionCard(
                    title: "Urgent Service",
                    subtitle: "Immediate response within 30 minutes",
                    price: profile["price"] + 50,
                    icon: Icons.flash_on,
                    color: Colors.orange,
                    onTap: () => _navigateToBookingPage(profile, "Urgent Service"),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Scheduled Booking Option
                  _buildBookingOptionCard(
                    title: "Scheduled Service",
                    subtitle: "Book for a specific date and time",
                    price: profile["price"],
                    icon: Icons.calendar_today,
                    color: Colors.blue,
                    onTap: () => _navigateToBookingPage(profile, "Scheduled Service"),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // View Profile Option
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.person, color: Colors.purple),
                      title: const Text("View Full Profile"),
                      subtitle: const Text("See detailed information and reviews"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pop(context); // Close bottom sheet
                        _navigateToProfilePage(profile);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingOptionCard({
    required String title,
    required String subtitle,
    required int price,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "\$$price",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const Text(
              "Starting",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  void _navigateToBookingPage(Map<String, dynamic> profile, String serviceType) {
    Navigator.pop(context); // Close bottom sheet
    
    // Start booking milestone
    setState(() {
      bookingStarted = true;
      bookingStep = 0;
    });
    
    // Navigate to booking page with correct parameters
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfessionalProfilePage(
          professional: profile,
          serviceType: serviceType,
        ),
      ),
    ).then((_) {
      // Handle when returning from booking page
      setState(() {
        bookingStep = 4; // Mark as completed when returning
      });
    });
  }

  void _navigateToProfilePage(Map<String, dynamic> profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfessionalProfilePage(
          professional: profile,
          serviceType: "Plumber Service",
        ),
      ),
    );
  }

 Widget _buildProfileCard(Map<String, dynamic> profile, int index) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        // Profile Image
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: AssetImage(profile["image"]),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile["name"],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    profile["rating"].toStringAsFixed(1),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${profile["experience"]} yrs',
                    style: const TextStyle(color: Colors.white),
                  ),
                  if (profile["isUrgentAvailable"])
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Urgent',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "\$${profile["price"]} per service",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${profile["location"]} • ${profile["services"].join(", ")}',
                style: const TextStyle(color: Colors.white70),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Arrow button
        GestureDetector(
          onTap: () => _openProfile(profile),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildFilterChip(String label, {required VoidCallback onDeleted}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: onDeleted,
        backgroundColor: Colors.blue.withOpacity(0.2),
        labelStyle: const TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          /// Wallpaper background
          Positioned.fill(
            child: Image.asset(
              "assets/plumberwallpaper.jpg",
              fit: BoxFit.cover,
            ),
          ),

          /// Optional dark overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.25)),
          ),

          /// Main content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Page title with filter button
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "Professional Plumbers",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.filter_list, color: Colors.white),
                            onPressed: _showFilterBottomSheet,
                          ),
                          if (activeFilterCount > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  activeFilterCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Active filters chips (only Amazon-style filters)
                if (activeFilterCount > 0)
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        if (selectedLocation != 'All')
                          _buildFilterChip(
                            'Location: $selectedLocation',
                            onDeleted: () => setState(() => selectedLocation = 'All'),
                          ),
                        if (selectedCostRange != 'All')
                          _buildFilterChip(
                            'Cost: $selectedCostRange',
                            onDeleted: () => setState(() => selectedCostRange = 'All'),
                          ),
                        if (minRating > 0.0)
                          _buildFilterChip(
                            'Rating: ${minRating.toStringAsFixed(1)}+',
                            onDeleted: () => setState(() => minRating = 0.0),
                          ),
                        if (urgentOnly)
                          _buildFilterChip(
                            'Urgent Only',
                            onDeleted: () => setState(() => urgentOnly = false),
                          ),
                        if (selectedGender != 'All')
                          _buildFilterChip(
                            'Gender: $selectedGender',
                            onDeleted: () => setState(() => selectedGender = 'All'),
                          ),
                        if (selectedServices.isNotEmpty)
                          _buildFilterChip(
                            'Services: ${selectedServices.length}',
                            onDeleted: () => setState(() => selectedServices = []),
                          ),
                        if (selectedSortBy != 'Recommended')
                          _buildFilterChip(
                            'Sort: $selectedSortBy',
                            onDeleted: () => setState(() => selectedSortBy = 'Recommended'),
                          ),
                      ],
                    ),
                  ),
                
                // Results and Sort info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        "${filteredProfiles.length} plumbers found",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      if (selectedSortBy != 'Recommended')
                        Text(
                          "Sorted by: $selectedSortBy",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // List of Plumbers
                Expanded(
                  child: filteredProfiles.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.plumbing,
                                color: Colors.white.withOpacity(0.5),
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No plumbers found",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Try adjusting your filters",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredProfiles.length,
                          itemBuilder: (context, index) {
                            final profile = filteredProfiles[index];
                            return _buildProfileCard(profile, index);
                          },
                        ),
                ),
              ],
            ),
          ),

          // Milestone pinned
          if (bookingStarted)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: buildMilestone(),
            ),
        ],
      ),
    );
  }
}

// Enhanced Filter Bottom Sheet Widget for Plumbers
class FilterBottomSheet extends StatefulWidget {
  final String selectedLocation;
  final String selectedCostRange;
  final double minRating;
  final bool urgentOnly;
  final String selectedGender;
  final String selectedSortBy;
  final List<String> selectedServices;
  final List<String> locations;
  final List<String> costRanges;
  final List<String> genders;
  final List<String> sortOptions;
  final List<String> allServices;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<String> onCostRangeChanged;
  final ValueChanged<double> onRatingChanged;
  final ValueChanged<bool> onUrgentChanged;
  final ValueChanged<String> onGenderChanged;
  final ValueChanged<String> onSortByChanged;
  final ValueChanged<List<String>> onServicesChanged;
  final VoidCallback onReset;

  const FilterBottomSheet({
    super.key,
    required this.selectedLocation,
    required this.selectedCostRange,
    required this.minRating,
    required this.urgentOnly,
    required this.selectedGender,
    required this.selectedSortBy,
    required this.selectedServices,
    required this.locations,
    required this.costRanges,
    required this.genders,
    required this.sortOptions,
    required this.allServices,
    required this.onLocationChanged,
    required this.onCostRangeChanged,
    required this.onRatingChanged,
    required this.onUrgentChanged,
    required this.onGenderChanged,
    required this.onSortByChanged,
    required this.onServicesChanged,
    required this.onReset,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _selectedLocation;
  late String _selectedCostRange;
  late double _minRating;
  late bool _urgentOnly;
  late String _selectedGender;
  late String _selectedSortBy;
  late List<String> _selectedServices;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.selectedLocation;
    _selectedCostRange = widget.selectedCostRange;
    _minRating = widget.minRating;
    _urgentOnly = widget.urgentOnly;
  _selectedGender = widget.selectedGender;
    _selectedSortBy = widget.selectedSortBy;
    _selectedServices = List.from(widget.selectedServices);
  }

  void _applyFilters() {
    widget.onLocationChanged(_selectedLocation);
    widget.onCostRangeChanged(_selectedCostRange);
    widget.onRatingChanged(_minRating);
    widget.onUrgentChanged(_urgentOnly);
    widget.onGenderChanged(_selectedGender);
    widget.onSortByChanged(_selectedSortBy);
    widget.onServicesChanged(_selectedServices);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: widget.onReset,
                  child: const Text(
                    'RESET ALL',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Text(
                  'Filters & Sort',
                  style: TextStyle(
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
          ),
          // Filter Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sort By
                  _buildFilterSection(
                    title: 'Sort By',
                    children: [
                      Wrap(
                        spacing: 8,
                        children: widget.sortOptions.map((sort) {
                          return FilterChip(
                            label: Text(sort),
                            selected: _selectedSortBy == sort,
                            onSelected: (selected) {
                              setState(() {
                                _selectedSortBy = selected ? sort : 'Recommended';
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Location Filter
                  _buildFilterSection(
                    title: 'Location',
                    children: [
                      Wrap(
                        spacing: 8,
                        children: widget.locations.map((location) {
                          return FilterChip(
                            label: Text(location),
                            selected: _selectedLocation == location,
                            onSelected: (selected) {
                              setState(() {
                                _selectedLocation = selected ? location : 'All';
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Cost Range Filter
                  _buildFilterSection(
                    title: 'Cost per Service',
                    children: [
                      Wrap(
                        spacing: 8,
                        children: widget.costRanges.map((range) {
                          return FilterChip(
                            label: Text(range),
                            selected: _selectedCostRange == range,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCostRange = selected ? range : 'All';
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Rating Filter
                  _buildFilterSection(
                    title: 'Minimum Rating',
                    children: [
                      Column(
                        children: [
                          Text(
                            '${_minRating.toStringAsFixed(1)}+ Stars',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Slider(
                            value: _minRating,
                            min: 0.0,
                            max: 5.0,
                            divisions: 10,
                            onChanged: (value) {
                              setState(() {
                                _minRating = value;
                              });
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('0.0'),
                              Text('5.0'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Gender Filter
                  _buildFilterSection(
                    title: 'Gender Preference',
                    children: [
                      Wrap(
                        spacing: 8,
                        children: widget.genders.map((gender) {
                          return FilterChip(
                            label: Text(gender),
                            selected: _selectedGender == gender,
                            onSelected: (selected) {
                              setState(() {
                                _selectedGender = selected ? gender : 'All';
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Urgent Filter
                  _buildFilterSection(
                    title: 'Availability',
                    children: [
                      SwitchListTile(
                        title: const Text('Available for Urgent Booking'),
                        subtitle: const Text('Immediate response within 30 minutes'),
                        value: _urgentOnly,
                        onChanged: (value) {
                          setState(() {
                            _urgentOnly = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Services Filter
                  _buildFilterSection(
                    title: 'Services Required',
                    children: [
                      Wrap(
                        spacing: 8,
                        children: widget.allServices.map((service) {
                          return FilterChip(
                            label: Text(service),
                            selected: _selectedServices.contains(service),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedServices.add(service);
                                } else {
                                  _selectedServices.remove(service);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Apply Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'APPLY FILTERS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}