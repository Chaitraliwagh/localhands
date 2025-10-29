import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localhands_app/view/earnings_chaitrali.dart';
import 'package:localhands_app/view/help_chaitrali.dart';
import 'package:localhands_app/view/history_chaitrali.dart';
import 'package:localhands_app/view/job_chaitrali.dart';
import 'package:localhands_app/view/not_chaitrali.dart';
import 'package:localhands_app/view/profile_chaitrali.dart';
import 'package:localhands_app/view/settings_chaitrali.dart';
import 'package:localhands_app/view/sidebar_chaitrali.dart';
import 'package:localhands_app/view/viewdetails_chaitrali.dart';

class PartnerDashboard extends StatefulWidget {
  const PartnerDashboard({super.key});

  @override
  State<PartnerDashboard> createState() => _PartnerDashboardState();
}

class _PartnerDashboardState extends State<PartnerDashboard>
    with SingleTickerProviderStateMixin {
  final Color bgColor = Color(0xFFFCFAF8);
  final Color primaryColor = Color(0xFF1D828E);
  final Color secondaryColor = Color(0xFFFEAC5D);
  final Color textColor = Color(0xFF140F1F);
  int _selectedIndex = 0;

  bool isOnline = false;

  late PageController _pageController;
  int _currentPage = 0;
  Timer? _carouselTimer;

  AnimationController? _animationController;

  final List<Map<String, dynamic>> promotionCards = [
    {
      "title": "Work More!",
      "description": "Get 20% off on your first booking.",
      "image": "assets/images/explore.jpeg",
    },
    {
      "title": "Invest Time!",
      "description": "Avail premium services today.",
      "image": "assets/images/explore.jpeg",
    },
  ];
  String location = "Fetching location...";

  void _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => location = "Location services disabled");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => location = "Permission denied");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => location = "Permission denied forever");
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      location =
          "${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}";
    });
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pageController = PageController(initialPage: 0, viewportFraction: 1.0);

    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % promotionCards.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _pageController.dispose();
    _carouselTimer?.cancel();
    super.dispose();
  }

  String getCurrentDay() {
    final now = DateTime.now();
    final weekdays = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];
    return weekdays[now.weekday - 1];
  }

  String getCurrentDate() {
    final now = DateTime.now();
    return "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
  }

  Color hexToColor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: bgColor,
      bottomNavigationBar: buildBottomNav(),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildTopSection(screenHeight),
                const SizedBox(height: 16),

                // Earnings Card
                // Earnings Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: buildEarningsCard(),
                ),
                const SizedBox(height: 16),

                // Earnings Graph
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: buildEarningsGraph(),
                ),
                const SizedBox(height: 16),

                // Promotion Card 1
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: buildPromotionCard(promotionCards[0]),
                ),
                const SizedBox(height: 16),

                // Next Job
                // Next Jobs - Horizontal Scroll
                // Jobs grouped by category
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // List of categories with their jobs
                    ...[
                      {
                        "category": "Electrician",
                        "jobs": [
                          {
                            "service": "AC Repair",
                            "customer": "Ramesh Kumar",
                            "rating": 4.5,
                            "time": "2:30 PM Today",
                            "location": "MG Road, Pune",
                          },
                          {
                            "service": "Fan Installation",
                            "customer": "Suresh Patil",
                            "rating": 4.6,
                            "time": "4:00 PM Today",
                            "location": "Shivaji Nagar, Pune",
                          },
                        ],
                      },
                      {
                        "category": "Plumber",
                        "jobs": [
                          {
                            "service": "Pipe Leakage",
                            "customer": "Aman Singh",
                            "rating": 4.8,
                            "time": "11:00 AM Tomorrow",
                            "location": "Koregaon Park, Pune",
                          },
                          {
                            "service": "Tap Repair",
                            "customer": "Sita Verma",
                            "rating": 4.7,
                            "time": "6:00 PM Tomorrow",
                            "location": "MG Road, Pune",
                          },
                        ],
                      },
                    ].map((entry) {
                      final category = entry["category"] as String;
                      final jobs = entry["jobs"] as List<Map<String, dynamic>>;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Text(
                              category,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 280,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: jobs.length,
                              separatorBuilder:
                                  (context, index) => const SizedBox(width: 16),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemBuilder: (context, index) {
                                final job = jobs[index];
                                return SizedBox(
                                  width: 320,
                                  child: buildNextJobCard(
                                    service: job["service"] as String,
                                    customer: job["customer"] as String,
                                    rating: job["rating"] as double,
                                    time: job["time"] as String,
                                    location: job["location"] as String,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),

                const SizedBox(height: 16),

                // Quick Actions / Customer Requests
                /*Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: buildQuickActions(),
                ),
                const SizedBox(height: 16),*/

                // Promotion Card 2
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: buildPromotionCard(promotionCards[1]),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          JobsScreen(),
          EarningsScreen(),
          //PartnerDashboard(),
          NotificationsScreen(),
          const ProfileScreen(),
          SupportScreen(),
          HistoryScreen(),
          SettingsScreen(),
        ],
      ),
    );
  }

  Widget _buildTopSection(double screenHeight) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [hexToColor("#1D828E"), hexToColor("#1A237E")],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (_animationController != null)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _StringLightsPainter(
                      animation: _animationController!,
                    ),
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location + Profile
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Your Location",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                location,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              opaque: false,
                              pageBuilder:
                                  (_, __, ___) => const PartnerSidebar(),
                              transitionDuration: Duration(milliseconds: 400),
                            ),
                          );
                        },

                        child: const CircleAvatar(
                          radius: 22,
                          backgroundImage: NetworkImage(
                            'https://randomuser.me/api/portraits/men/75.jpg',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Hello, Worker 👋",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${getCurrentDay()}, ${getCurrentDate()}",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Your Location: $location",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  // Carousel
                  SizedBox(
                    height: screenHeight * 0.25,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: promotionCards.length,
                      onPageChanged: (page) {
                        setState(() => _currentPage = page);
                      },
                      itemBuilder: (context, index) {
                        double scale = _currentPage == index ? 1.0 : 0.85;
                        return TweenAnimationBuilder(
                          tween: Tween(begin: scale, end: scale),
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOut,
                          builder: (context, double value, child) {
                            return Transform.scale(scale: value, child: child);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                image: AssetImage(
                                  promotionCards[index]["image"],
                                ),
                                fit: BoxFit.cover,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black26,
                                        Colors.transparent,
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 16,
                                  left: 16,
                                  child: Text(
                                    promotionCards[index]["title"],
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Dots Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      promotionCards.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 16 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              _currentPage == index
                                  ? Colors.white
                                  : Colors.white54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search services",
                        hintStyle: GoogleFonts.poppins(fontSize: 14),
                        border: InputBorder.none,
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildEarningsCard() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Earnings",
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              "₹450",
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This Week ₹3200 | This Month ₹12000',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  // Earnings graph based on weekly and monthly data
  Widget buildEarningsGraph() {
    // Sample data
    final weeklyEarnings = [
      4000,
      3200,
      4500,
      3800,
      5000,
      4200,
      4800,
    ]; // Mon-Sun
    final monthlyEarningsAvg = [12000, 14000, 13500, 15000]; // Last 4 months

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Weekly Earnings",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY:
                    weeklyEarnings.reduce((a, b) => a > b ? a : b).toDouble() +
                    1000,
                alignment: BarChartAlignment.spaceAround,
                groupsSpace: 12,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      const days = [
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat',
                        'Sun',
                      ];
                      final day =
                          groupIndex >= 0 && groupIndex < days.length
                              ? days[groupIndex]
                              : '';
                      return BarTooltipItem(
                        "$day\n₹${rod.toY.toInt()}",
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),

                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun',
                        ];
                        return Text(
                          days[value.toInt()],
                          style: GoogleFonts.poppins(fontSize: 12),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50, // ✅ Add spacing so numbers fit
                      interval: 1000,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            right: 8.0,
                          ), // ✅ Small padding
                          child: Text(
                            '₹${value.toInt()}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1000,
                  getDrawingHorizontalLine:
                      (value) => FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      ),
                ),
                borderData: FlBorderData(show: false),
                barGroups:
                    weeklyEarnings.asMap().entries.map((entry) {
                      final index = entry.key;
                      final value = entry.value.toDouble();
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: value,
                            borderRadius: BorderRadius.circular(6),
                            width: 22,
                            gradient: LinearGradient(
                              colors: [Color(0xFF1D828E), Color(0xFFFEAC5D)],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: 6000,
                              color: Colors.grey.withOpacity(0.1),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
              swapAnimationDuration: Duration(milliseconds: 800),
              swapAnimationCurve: Curves.easeInOut,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Weekly Total: ₹${weeklyEarnings.reduce((a, b) => a + b)}",
                style: GoogleFonts.poppins(
                  color: Colors.grey[700],
                  fontSize: 12,
                ),
              ),
              Text(
                "Monthly Avg: ₹${(monthlyEarningsAvg.reduce((a, b) => a + b) / monthlyEarningsAvg.length).round()}",
                style: GoogleFonts.poppins(
                  color: Colors.grey[700],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildPromotionCard(Map<String, dynamic> card) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage(card["image"]),
          fit: BoxFit.cover,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.black26, Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Text(
              card["title"],
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNextJobCard({
    required String service,
    required String customer,
    required double rating,
    required String time,
    required String location,
  }) {
    return GestureDetector(
      onTapDown: (_) => setState(() {}),
      child: Container(
        height: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              hexToColor("#1D828E").withOpacity(0.9),
              hexToColor("#1A237E").withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.05),
              blurRadius: 2,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Service Icon + Service Title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Icon(Icons.build, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    service,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Customer Name & Location Row
            // Customer Name
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  customer,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Location
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.white70),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    location,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Time
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Rating
            Row(
              children: [
                Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  rating.toString(),
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Badges Row: Rating + Time
            Row(
              children: [
                // Rating Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        rating.toString(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Time Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 1),

            // Divider to separate info from button
            Divider(color: Colors.white.withOpacity(0.3), thickness: 1),

            const Spacer(),

            // Accept Button at bottom
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [hexToColor("#1D828E"), hexToColor("#1A237E")],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  splashColor: Colors.white.withOpacity(0.3),
                  highlightColor: Colors.white.withOpacity(0.1),
                  onTap: () {
                    showJobDetailsBottomSheet(context, {
                      "service": service,
                      "customer": customer,
                      "rating": rating,
                      "time": time,
                      "location": location,
                      "image": "assets/images/explore.jpeg",
                      "earnings": 450,
                      "instructions": "Handle carefully",
                      "latLng": LatLng(18.5204, 73.8567),
                      "acceptCallback": () => Navigator.pop(context),
                      "rejectCallback": () => Navigator.pop(context),
                      "navigateCallback": () {},
                    });
                  },
                  child: Center(
                    child: Text(
                      'Accept',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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

  /*Widget buildQuickActions() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          quickActionButton('My Jobs', Icons.list_alt, primaryColor, 1),
          quickActionButton(
            'Withdraw',
            Icons.account_balance_wallet,
            secondaryColor,
            8,
          ),
          quickActionButton(
            'Support',
            Icons.support_agent,
            primaryColor.withOpacity(0.9),
            5,
          ),
          quickActionButton(
            'History',
            Icons.history,
            secondaryColor.withOpacity(0.9),
            6,
          ),
          quickActionButton(
            'Settings',
            Icons.settings,
            primaryColor.withOpacity(0.8),
            7,
          ),
          quickActionButton(
            'Notifications',
            Icons.notifications,
            secondaryColor.withOpacity(0.8),
            4,
          ),
        ],
      ),
    );
  }

  Widget quickActionButton(
    String title,
    IconData icon,
    Color color,
    int index,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }*/

  Widget buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Jobs'),

        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: 'Earnings',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.notification_add),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      currentIndex: _selectedIndex > 3 ? 0 : _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }

  Widget animatedActionButton({
    required String text,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.white.withOpacity(0.3),
        highlightColor: Colors.white.withOpacity(0.1),
        onTap: onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

// Dummy painter for lights animation
class _StringLightsPainter extends CustomPainter {
  final Animation<double> animation;
  _StringLightsPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()..color = Colors.yellow.withOpacity(0.5 + 0.5 * animation.value);
    for (double i = 0; i < size.width; i += 20) {
      canvas.drawCircle(Offset(i, 20 + 10 * animation.value), 5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StringLightsPainter oldDelegate) => true;
}
