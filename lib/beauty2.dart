import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Beauty2Screen extends StatefulWidget {
  const Beauty2Screen({super.key});

  @override
  State<Beauty2Screen> createState() => _Beauty2ScreenState();
}

class _Beauty2ScreenState extends State<Beauty2Screen> {
  String? selectedOption;
  DateTime? startDate;
  DateTime? endDate;
  int bookingStep = 0;

  // Enhanced Filter States
  String selectedLocation = 'All';
  String selectedCostRange = 'All';
  double minRating = 0.0;
  bool urgentOnly = false;
  List<String> selectedServices = [];
  String selectedSortBy = 'Recommended';

  // Available options for filters
  final List<String> locations = ['All', 'Jalgaon', 'Faizpur', 'Bhusawal', 'Yawal', 'Raver'];
  final List<String> costRanges = ['All', 'Under ₹500', '₹500-₹1000', '₹1000-₹2000', 'Above ₹2000'];
  final List<String> allServices = ['Facial', 'Hair Spa', 'Makeup', 'Haircut', 'Manicure', 'Pedicure', 'Hair Coloring', 'Waxing', 'Threading', 'Massage'];
  final List<String> sortOptions = ['Recommended', 'Rating: High to Low', 'Cost: Low to High', 'Cost: High to Low'];

  final List<Map<String, dynamic>> allProviders = [
    {
      "name": "Glow Studio",
      "rating": 4.8,
      "price": 800,
      "address": "Main Road, Jalgaon",
      "services": ["Facial", "Hair Spa", "Makeup"],
      "image": "assets/b1.jpg",
      "location": "Jalgaon",
      "availableForUrgent": true,
      "responseTime": "15 mins",
      "experience": "5 years",
    },
    {
      "name": "Style Avenue",
      "rating": 4.5,
      "price": 1200,
      "address": "Market Area, Faizpur",
      "services": ["Haircut", "Manicure", "Pedicure"],
      "image": "assets/b2.jpg",
      "location": "Faizpur",
      "availableForUrgent": true,
      "responseTime": "20 mins",
      "experience": "3 years",
    },
    {
      "name": "Glamour Spot",
      "rating": 4.7,
      "price": 600,
      "address": "Station Road, Bhusawal",
      "services": ["Hair Coloring", "Waxing"],
      "image": "assets/b3.jpg",
      "location": "Bhusawal",
      "availableForUrgent": false,
      "responseTime": "25 mins",
      "experience": "4 years",
    },
    {
      "name": "Beauty Bliss",
      "rating": 4.9,
      "price": 1500,
      "address": "City Center, Jalgaon",
      "services": ["Facial", "Makeup", "Threading"],
      "image": "assets/b4.jpg",
      "location": "Jalgaon",
      "availableForUrgent": true,
      "responseTime": "10 mins",
      "experience": "6 years",
    },
    {
      "name": "Elegant Looks",
      "rating": 4.3,
      "price": 500,
      "address": "Suburb, Faizpur",
      "services": ["Haircut", "Manicure"],
      "image": "assets/b5.jpg",
      "location": "Faizpur",
      "availableForUrgent": false,
      "responseTime": "30 mins",
      "experience": "2 years",
    },
  ];

  List<Map<String, dynamic>> get filteredProviders {
    List<Map<String, dynamic>> result = List.from(allProviders);
    
    // Apply filters
    result = result.where((provider) {
      // Location filter
      if (selectedLocation != 'All' && provider['location'] != selectedLocation) {
        return false;
      }

      // Cost filter
      if (selectedCostRange != 'All') {
        final price = provider['price'];
        switch (selectedCostRange) {
          case 'Under ₹500':
            if (price >= 500) return false;
            break;
          case '₹500-₹1000':
            if (price < 500 || price > 1000) return false;
            break;
          case '₹1000-₹2000':
            if (price < 1000 || price > 2000) return false;
            break;
          case 'Above ₹2000':
            if (price <= 2000) return false;
            break;
        }
      }

      // Rating filter
      if (provider['rating'] < minRating) {
        return false;
      }

      // Urgent filter
      if (urgentOnly && !provider['availableForUrgent']) {
        return false;
      }

      // Services filter
      if (selectedServices.isNotEmpty) {
        final providerServices = List<String>.from(provider['services']);
        if (!selectedServices.any((service) => providerServices.contains(service))) {
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
      case 'Recommended':
      default:
        // Default sorting: urgent available first, then by rating
        result.sort((a, b) {
          if (a['availableForUrgent'] && !b['availableForUrgent']) return -1;
          if (!a['availableForUrgent'] && b['availableForUrgent']) return 1;
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
        selectedSortBy: selectedSortBy,
        selectedServices: selectedServices,
        locations: locations,
        costRanges: costRanges,
        sortOptions: sortOptions,
        allServices: allServices,
        onLocationChanged: (value) => setState(() => selectedLocation = value),
        onCostRangeChanged: (value) => setState(() => selectedCostRange = value),
        onRatingChanged: (value) => setState(() => minRating = value),
        onUrgentChanged: (value) => setState(() => urgentOnly = value),
        onSortByChanged: (value) => setState(() => selectedSortBy = value),
        onServicesChanged: (services) => setState(() => selectedServices = services),
        onReset: () {
          setState(() {
            selectedLocation = 'All';
            selectedCostRange = 'All';
            minRating = 0.0;
            urgentOnly = false;
            selectedSortBy = 'Recommended';
            selectedServices = [];
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> pickDate({required bool isStart}) async {
    DateTime initialDate = isStart ? (startDate ?? DateTime.now()) : (endDate ?? DateTime.now());
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
          bookingStep = 1; // Scheduled
          if (selectedOption != "regular" && endDate != null && picked.isAfter(endDate!)) {
            endDate = null; // Reset invalid end date
          }
        } else {
          endDate = picked;
        }
      });
    }
  }

  bool isContinueEnabled() {
    if (selectedOption == null) return false;
    if (selectedOption == "regular") return startDate != null;
    if (selectedOption == "monthly" || selectedOption == "festive") return startDate != null && endDate != null;
    return false;
  }

  void resetBooking() {
    setState(() {
      selectedOption = null;
      startDate = null;
      endDate = null;
      bookingStep = 0;
    });
  }

  void _openProfile(Map<String, dynamic> provider) {
    // Show booking options
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBookingOptionsSheet(provider),
    );
  }

  Widget _buildBookingOptionsSheet(Map<String, dynamic> provider) {
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
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: AssetImage(provider["image"]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider["name"],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Starting from ₹${provider["price"]}",
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
                    price: provider["price"] + 200,
                    icon: Icons.flash_on,
                    color: Colors.orange,
                    onTap: () => _navigateToBookingPage(provider, "Urgent Service"),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Scheduled Booking Option
                  _buildBookingOptionCard(
                    title: "Scheduled Service",
                    subtitle: "Book for a specific date and time",
                    price: provider["price"],
                    icon: Icons.calendar_today,
                    color: Colors.blue,
                    onTap: () => _navigateToBookingPage(provider, "Scheduled Service"),
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
              "₹$price",
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

  void _navigateToBookingPage(Map<String, dynamic> provider, String serviceType) {
    Navigator.pop(context); // Close bottom sheet
    
    // Start booking milestone
    setState(() {
      bookingStep = 0;
    });
    
    // Navigate to booking page (you can replace this with your actual booking page)
    // Navigator.push(...);
  }

  Widget _buildProviderCard(Map<String, dynamic> provider, int index) {
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
                image: AssetImage(provider["image"]),
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
                  provider["name"],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                // First row: Rating and Experience
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      provider["rating"].toStringAsFixed(1),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.work, color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      provider["experience"],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Second row: Location and Urgent badge
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        provider["location"],
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (provider["availableForUrgent"])
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
                  "₹${provider["price"]} per service",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  provider["services"].join(", "),
                  style: const TextStyle(color: Colors.white70),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (provider["responseTime"] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Response: ${provider["responseTime"]}',
                      style: const TextStyle(color: Colors.green, fontSize: 11),
                    ),
                  ),
              ],
            ),
          ),

          // Arrow button
          GestureDetector(
            onTap: () => _openProfile(provider),
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
      body: Stack(
        children: [
          // Wallpaper
          SizedBox.expand(
            child: Image.asset(
              'assets/beauty.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Container(color: Colors.black.withOpacity(0.3)),
          SafeArea(
            child: Column(
              children: [
                // Header with filter button
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "Beauty & Salon Services",
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

                // Active filters chips
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
                        "${filteredProviders.length} salons found",
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

                // Milestone chain
                if (bookingStep > 0) buildMilestone(),

                // Provider list
                Expanded(
                  child: filteredProviders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.spa,
                                color: Colors.white.withOpacity(0.5),
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No salons found",
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
                          itemCount: filteredProviders.length,
                          itemBuilder: (context, index) {
                            final provider = filteredProviders[index];
                            return _buildProviderCard(provider, index);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMilestone() {
    final steps = ["Selected", "Scheduled", "Request Sent", "Booking Confirmed"];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: steps.asMap().entries.map((entry) {
          int idx = entry.key;
          String name = entry.value;
          bool isCompleted = bookingStep > idx;
          bool isCurrent = bookingStep == idx;
          return Column(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: isCompleted || isCurrent ? Colors.green : Colors.grey[300],
                child: isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : Text(
                        "${idx + 1}",
                        style: TextStyle(
                            color: isCurrent ? Colors.white : Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCurrent ? Colors.green : Colors.black54,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// Filter Bottom Sheet Widget for Salon
class FilterBottomSheet extends StatefulWidget {
  final String selectedLocation;
  final String selectedCostRange;
  final double minRating;
  final bool urgentOnly;
  final String selectedSortBy;
  final List<String> selectedServices;
  final List<String> locations;
  final List<String> costRanges;
  final List<String> sortOptions;
  final List<String> allServices;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<String> onCostRangeChanged;
  final ValueChanged<double> onRatingChanged;
  final ValueChanged<bool> onUrgentChanged;
  final ValueChanged<String> onSortByChanged;
  final ValueChanged<List<String>> onServicesChanged;
  final VoidCallback onReset;

  const FilterBottomSheet({
    super.key,
    required this.selectedLocation,
    required this.selectedCostRange,
    required this.minRating,
    required this.urgentOnly,
    required this.selectedSortBy,
    required this.selectedServices,
    required this.locations,
    required this.costRanges,
    required this.sortOptions,
    required this.allServices,
    required this.onLocationChanged,
    required this.onCostRangeChanged,
    required this.onRatingChanged,
    required this.onUrgentChanged,
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
  late String _selectedSortBy;
  late List<String> _selectedServices;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.selectedLocation;
    _selectedCostRange = widget.selectedCostRange;
    _minRating = widget.minRating;
    _urgentOnly = widget.urgentOnly;
    _selectedSortBy = widget.selectedSortBy;
    _selectedServices = List.from(widget.selectedServices);
  }

  void _applyFilters() {
    widget.onLocationChanged(_selectedLocation);
    widget.onCostRangeChanged(_selectedCostRange);
    widget.onRatingChanged(_minRating);
    widget.onUrgentChanged(_urgentOnly);
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