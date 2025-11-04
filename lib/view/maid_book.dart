import 'package:flutter/material.dart';
import 'workerProfile.dart';

class MaidBookingScreen extends StatefulWidget {
  final String bookingType;
  final DateTime startDate;
  final DateTime? endDate;

  const MaidBookingScreen({
    super.key,
    required this.bookingType,
    required this.startDate,
    this.endDate,
  });

  @override
  State<MaidBookingScreen> createState() => _MaidBookingScreenState();
}

class _MaidBookingScreenState extends State<MaidBookingScreen> {
  final List<Map<String, dynamic>> allWorkers = [
    {
      'name': 'Anita',
      'image': 'assets/maid1.jpg',
      'rating': 4.5,
      'experience': 3,
      'cost': 300,
      'services': ['Cleaning', 'Cooking', 'Laundry'],
      'location': 'Nearby',
      'availableForUrgent': true,
      'gender': 'Female',
      'responseTime': '15 mins',
      'languages': ['Hindi', 'English'],
    },
    {
      'name': 'Sunita',
      'image': 'assets/maid2.jpg',
      'rating': 4.8,
      'experience': 5,
      'cost': 400,
      'services': ['Cleaning', 'Dishwashing'],
      'location': 'City Center',
      'availableForUrgent': true,
      'gender': 'Female',
      'responseTime': '20 mins',
      'languages': ['Hindi'],
    },
    {
      'name': 'Rekha',
      'image': 'assets/maid3.jpg',
      'rating': 4.2,
      'experience': 2,
      'cost': 250,
      'services': ['Cleaning', 'Ironing'],
      'location': 'Suburb',
      'availableForUrgent': false,
      'gender': 'Female',
      'responseTime': '30 mins',
      'languages': ['Hindi', 'Marathi'],
    },
    {
      'name': 'Priya',
      'image': 'assets/maid4.jpg',
      'rating': 4.9,
      'experience': 6,
      'cost': 500,
      'services': ['Cleaning', 'Cooking', 'Child Care'],
      'location': 'Nearby',
      'availableForUrgent': true,
      'gender': 'Female',
      'responseTime': '10 mins',
      'languages': ['Hindi', 'English', 'Tamil'],
    },
    {
      'name': 'Meena',
      'image': 'assets/maid5.jpg',
      'rating': 4.0,
      'experience': 1,
      'cost': 200,
      'services': ['Cleaning'],
      'location': 'Downtown',
      'availableForUrgent': false,
      'gender': 'Female',
      'responseTime': '25 mins',
      'languages': ['Hindi'],
    },
    {
      'name': 'Rajesh',
      'image': 'assets/maid6.jpg',
      'rating': 4.3,
      'experience': 4,
      'cost': 350,
      'services': ['Cleaning', 'Laundry', 'Gardening'],
      'location': 'City Center',
      'availableForUrgent': true,
      'gender': 'Male',
      'responseTime': '18 mins',
      'languages': ['Hindi', 'English'],
    },
  ];

  // Filter states
  String selectedLocation = 'All';
  String selectedCostRange = 'All';
  double minRating = 0.0;
  bool urgentOnly = false;
  List<String> selectedServices = [];
  String selectedGender = 'All';
  String selectedExperience = 'All';
  String selectedSortBy = 'Recommended';

  // Available options for filters
  final List<String> locations = ['All', 'Nearby', 'City Center', 'Suburb', 'Downtown'];
  final List<String> costRanges = ['All', 'Under ₹200', '₹200-₹300', '₹300-₹400', 'Above ₹400'];
  final List<String> allServices = ['Cleaning', 'Cooking', 'Laundry', 'Dishwashing', 'Ironing', 'Child Care', 'Gardening'];
  final List<String> genders = ['All', 'Female', 'Male'];
  final List<String> experienceRanges = ['All', '0-2 years', '2-5 years', '5+ years'];
  final List<String> sortOptions = ['Recommended', 'Rating: High to Low', 'Cost: Low to High', 'Cost: High to Low', 'Experience: High to Low'];

  List<Map<String, dynamic>> get filteredWorkers {
    List<Map<String, dynamic>> result = List.from(allWorkers);
    
    // Apply filters
    result = result.where((worker) {
      // Location filter
      if (selectedLocation != 'All' && worker['location'] != selectedLocation) {
        return false;
      }

      // Cost filter
      if (selectedCostRange != 'All') {
        final cost = worker['cost'];
        switch (selectedCostRange) {
          case 'Under ₹200':
            if (cost >= 200) return false;
            break;
          case '₹200-₹300':
            if (cost < 200 || cost > 300) return false;
            break;
          case '₹300-₹400':
            if (cost < 300 || cost > 400) return false;
            break;
          case 'Above ₹400':
            if (cost <= 400) return false;
            break;
        }
      }

      // Rating filter
      if (worker['rating'] < minRating) {
        return false;
      }

      // Urgent filter
      if (urgentOnly && !worker['availableForUrgent']) {
        return false;
      }

      // Gender filter
      if (selectedGender != 'All' && worker['gender'] != selectedGender) {
        return false;
      }

      // Experience filter
      if (selectedExperience != 'All') {
        final experience = worker['experience'];
        switch (selectedExperience) {
          case '0-2 years':
            if (experience > 2) return false;
            break;
          case '2-5 years':
            if (experience < 2 || experience > 5) return false;
            break;
          case '5+ years':
            if (experience <= 5) return false;
            break;
        }
      }

      // Services filter
      if (selectedServices.isNotEmpty) {
        final workerServices = List<String>.from(worker['services']);
        if (!selectedServices.any((service) => workerServices.contains(service))) {
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
        result.sort((a, b) => a['cost'].compareTo(b['cost']));
        break;
      case 'Cost: High to Low':
        result.sort((a, b) => b['cost'].compareTo(a['cost']));
        break;
      case 'Experience: High to Low':
        result.sort((a, b) => b['experience'].compareTo(a['experience']));
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

  void openProfile(Map<String, dynamic> worker) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            WorkerProfilePage(profile: worker, category: widget.bookingType),
      ),
    );
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
        selectedExperience: selectedExperience,
        selectedSortBy: selectedSortBy,
        selectedServices: selectedServices,
        locations: locations,
        costRanges: costRanges,
        genders: genders,
        experienceRanges: experienceRanges,
        sortOptions: sortOptions,
        allServices: allServices,
        onLocationChanged: (value) => setState(() => selectedLocation = value),
        onCostRangeChanged: (value) => setState(() => selectedCostRange = value),
        onRatingChanged: (value) => setState(() => minRating = value),
        onUrgentChanged: (value) => setState(() => urgentOnly = value),
        onGenderChanged: (value) => setState(() => selectedGender = value),
        onExperienceChanged: (value) => setState(() => selectedExperience = value),
        onSortByChanged: (value) => setState(() => selectedSortBy = value),
        onServicesChanged: (services) => setState(() => selectedServices = services),
        onReset: () {
          setState(() {
            selectedLocation = 'All';
            selectedCostRange = 'All';
            minRating = 0.0;
            urgentOnly = false;
            selectedGender = 'All';
            selectedExperience = 'All';
            selectedSortBy = 'Recommended';
            selectedServices = [];
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  int get activeFilterCount {
    int count = 0;
    if (selectedLocation != 'All') count++;
    if (selectedCostRange != 'All') count++;
    if (minRating > 0.0) count++;
    if (urgentOnly) count++;
    if (selectedGender != 'All') count++;
    if (selectedExperience != 'All') count++;
    if (selectedServices.isNotEmpty) count++;
    if (selectedSortBy != 'Recommended') count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("${widget.bookingType} Service"),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/maid.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.8)),
            child: Column(
              children: [
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
                        if (selectedGender != 'All')
                          _buildFilterChip(
                            'Gender: $selectedGender',
                            onDeleted: () => setState(() => selectedGender = 'All'),
                          ),
                        if (selectedExperience != 'All')
                          _buildFilterChip(
                            'Exp: $selectedExperience',
                            onDeleted: () => setState(() => selectedExperience = 'All'),
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
                        "${filteredWorkers.length} maids found",
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

                // Workers list
                Expanded(
                  child: filteredWorkers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cleaning_services,
                                color: Colors.white.withOpacity(0.5),
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No maids found",
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
                          itemCount: filteredWorkers.length,
                          itemBuilder: (context, index) {
                            final worker = filteredWorkers[index];
                            return _buildWorkerCard(worker);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

 Widget _buildWorkerCard(Map<String, dynamic> worker) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        // Profile Image
        CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage(worker['image']),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                worker['name'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              // First row: Rating and Experience
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${worker['rating']}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.work, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${worker['experience']} yrs',
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
                      worker['location'],
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (worker['availableForUrgent'])
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
                '₹${worker['cost']} per hour',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                (worker['services'] as List<dynamic>).join(", "),
                style: const TextStyle(color: Colors.white70),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (worker['languages'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Languages: ${(worker['languages'] as List<dynamic>).join(", ")}',
                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (worker['responseTime'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    'Response: ${worker['responseTime']}',
                    style: const TextStyle(color: Colors.green, fontSize: 11),
                  ),
                ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => openProfile(worker),
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
}

// Enhanced Filter Bottom Sheet Widget
class FilterBottomSheet extends StatefulWidget {
  final String selectedLocation;
  final String selectedCostRange;
  final double minRating;
  final bool urgentOnly;
  final String selectedGender;
  final String selectedExperience;
  final String selectedSortBy;
  final List<String> selectedServices;
  final List<String> locations;
  final List<String> costRanges;
  final List<String> genders;
  final List<String> experienceRanges;
  final List<String> sortOptions;
  final List<String> allServices;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<String> onCostRangeChanged;
  final ValueChanged<double> onRatingChanged;
  final ValueChanged<bool> onUrgentChanged;
  final ValueChanged<String> onGenderChanged;
  final ValueChanged<String> onExperienceChanged;
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
    required this.selectedExperience,
    required this.selectedSortBy,
    required this.selectedServices,
    required this.locations,
    required this.costRanges,
    required this.genders,
    required this.experienceRanges,
    required this.sortOptions,
    required this.allServices,
    required this.onLocationChanged,
    required this.onCostRangeChanged,
    required this.onRatingChanged,
    required this.onUrgentChanged,
    required this.onGenderChanged,
    required this.onExperienceChanged,
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
  late String _selectedExperience;
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
    _selectedExperience = widget.selectedExperience;
    _selectedSortBy = widget.selectedSortBy;
    _selectedServices = List.from(widget.selectedServices);
  }

  void _applyFilters() {
    widget.onLocationChanged(_selectedLocation);
    widget.onCostRangeChanged(_selectedCostRange);
    widget.onRatingChanged(_minRating);
    widget.onUrgentChanged(_urgentOnly);
    widget.onGenderChanged(_selectedGender);
    widget.onExperienceChanged(_selectedExperience);
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
                    title: 'Cost per Hour',
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

                  // Experience Filter
                  _buildFilterSection(
                    title: 'Experience',
                    children: [
                      Wrap(
                        spacing: 8,
                        children: widget.experienceRanges.map((exp) {
                          return FilterChip(
                            label: Text(exp),
                            selected: _selectedExperience == exp,
                            onSelected: (selected) {
                              setState(() {
                                _selectedExperience = selected ? exp : 'All';
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