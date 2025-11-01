import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';

// Screens
import 'package:localhands_app/beauty_screen.dart';
import 'package:localhands_app/home/notification.dart';
import 'package:localhands_app/plumber_screen.dart';
import 'package:localhands_app/profile_sejal.dart';
import 'package:localhands_app/view/booking_page_sejal.dart';
import 'package:localhands_app/view/maid.dart';
import 'package:localhands_app/view/service.dart';
import 'package:localhands_app/view/womenSalon.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> popularServices = [
    {"icon": Icons.content_cut, "title": "Salon"},
    {"icon": Icons.plumbing, "title": "Plumbing"},
    {"icon": Icons.family_restroom, "title": "BabySitter"},
    {"icon": Icons.cleaning_services, "title": "Maid"},
    {"icon": Icons.local_dining, "title": "Caterers"},
  ];

  final List<Map<String, dynamic>> allServices = [
    {"icon": Icons.content_cut, "title": "Salon"},
    {"icon": Icons.plumbing, "title": "Plumbing"},
    {"icon": Icons.family_restroom, "title": "BabySitter"},
    {"icon": Icons.cleaning_services, "title": "Maid"},
    {"icon": Icons.local_dining, "title": "Caterers"},
    {"icon": Icons.electric_bolt, "title": "Electrician"},
    {"icon": Icons.car_repair, "title": "Car Wash"},
    {"icon": Icons.computer, "title": "Computer Repair"},
    {"icon": Icons.brush, "title": "Painting"},
  ];

  final Map<String, Widget> screenMap = {
    "Plumbing": const PlumberScreen(),
    "Salon": const BeautyScreen(),
    "Maid": const MaidScreen(),
    "BabySitter": const MaidScreen(), // replace with BabysitterScreen if exists
  };

  late PageController _carouselController;
  int _carouselPage = 0;
  Timer? _carouselTimer;

  @override
  void initState() {
    super.initState();
    _carouselController = PageController(viewportFraction: 0.9);

    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_carouselController.hasClients) {
        setState(() {
          _carouselPage = (_carouselPage + 1) % 3;
          _carouselController.animateToPage(
            _carouselPage,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _carouselController.dispose();
    _carouselTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      bottomNavigationBar: _buildBottomNavBar(),
      body: Stack(
        children: [
          // Watermark
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset('assets/logo.jpeg', fit: BoxFit.cover),
            ),
          ),
          // Main Content
          Column(
            children: [
              _buildTopRectangle(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      _buildPopularServices(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: _buildServicesCarousel(),
                      ),
                      _buildDiscoverAllServices(),
                      const SizedBox(height: 16),
                      _buildSpecialOfferCard(),
                      const HomewomenSpa(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------- Bottom Navigation --------------------
  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 65,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
      onTap: () {
        if (label == "Services") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ServiceScreen()),
          );
        } else if (label == "Booking") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BookingPage()),
          );
        } else if (label == "Notifications") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationScreen()),
          );
        } else {
          setState(() => _selectedIndex = index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? Colors.white : Colors.white54),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- Top Rectangle --------------------
  Widget _buildTopRectangle() {
    final today = DateTime.now();
    final formattedDate = "${today.day}-${today.month}";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D828E), Color.fromARGB(255, 50, 189, 117)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Hey Anushri 👋",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
              GestureDetector(
  onTap: () {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      pageBuilder: (context, animation, secondaryAnimation) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0), // slides from right
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        )),
        child: const _GlassyProfileOverlay(),
      ),
    ));
  },
  child: const CircleAvatar(
    radius: 20,
    backgroundImage: AssetImage("assets/profile.jpg"),
  ),
)

            ],
          ),
          const SizedBox(height: 12),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: const [
            Icon(Icons.search, color: Colors.black54),
            SizedBox(width: 8),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search services...",
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- Popular Services --------------------
  Widget _buildPopularServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            "Popular Services",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: popularServices.length,
            itemBuilder: (context, index) {
              final service = popularServices[index];
              return _buildServiceCircle(service["icon"], service["title"]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCircle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: GestureDetector(
        onTap: () {
          if (screenMap.containsKey(title)) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => screenMap[title]!),
            );
          }
        },
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 236, 226, 226),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color.fromARGB(143, 49, 45, 39),
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Icon(icon, size: 40, color: Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- Services Carousel --------------------
  Widget _buildServicesCarousel() {
    final List<Map<String, String>> carouselItems = [
      {
        "image": "assets/caterings.jpg",
        "title": "Book Catering Services",
        "subtitle": "Delicious food for all your events!",
      },
      {
        "image": "assets/child-care.jpeg",
        "title": "Book Babysitter Services",
        "subtitle": "Safe and caring environment for your kids.",
      },
      {
        "image": "assets/diwali.jpg",
        "title": "Special Diwali Offers",
        "subtitle": "Exciting deals for your festive needs!",
      },
    ];

    return SizedBox(
      height: 220,
      child: PageView.builder(
        controller: _carouselController,
        itemCount: carouselItems.length,
        itemBuilder: (context, index) {
          final item = carouselItems[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: AssetImage(item["image"]!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["title"]!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item["subtitle"]!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        "Book Now",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // -------------------- Discover All Services --------------------
  Widget _buildDiscoverAllServices() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Discover All Services",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ServiceScreen()),
                  );
                },
                child: const Text(
                  "View All",
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allServices.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final item = allServices[index];
              return _buildServiceItem(item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(Map<String, dynamic> item) {
    return InkWell(
      onTap: () {
        if (screenMap.containsKey(item["title"])) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screenMap[item["title"]]!),
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color.fromARGB(255, 68, 210, 165),
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Icon(item["icon"], size: 36, color: Colors.black),
          ),
          const SizedBox(height: 6),
          Text(
            item["title"],
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // -------------------- Special Offer --------------------
  Widget _buildSpecialOfferCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Color(0xFF1D828E), Color.fromARGB(255, 50, 189, 117)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          
           child: Text(
            "     Special Offer! Get 20% off on your  first booking.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // -------------------- Drawer --------------------
  Drawer _buildDrawer() {
    return Drawer(
      child: Stack(
        children: [
          // watermark
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset('assets/logoicon.png', fit: BoxFit.cover),
            ),
          ),

          ListView(
            padding: EdgeInsets.zero,
            children: [
              ClipPath(
                clipper: _WaveClipper(), // <-- constructor call
                child: Container(
                  width: double.infinity,
                  height: 220,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF003C6E), Color(0xFF007C91)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: AssetImage(
                              "assets/profilepic.jpg",
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            "Sejal Patil",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.white70,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Jalgaon, Maharashtra",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
              _drawerTile(Icons.check_circle, "Completed Services"),
              _drawerTile(Icons.cancel, "Cancelled Services"),
              _drawerTile(Icons.timer, "Upcoming Services"),
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                child: Text(
                  "Payments",
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              _drawerTile(Icons.credit_card, "Payment Methods"),
              _drawerTile(
                Icons.account_balance_wallet,
                "Wallet & Transactions",
              ),
              _drawerTile(Icons.receipt_long, "Receipts"),
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                child: Text(
                  "System",
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              _drawerTile(Icons.notifications, "Notifications"),
              _drawerTile(Icons.dark_mode, "Dark Mode"),
              _drawerTile(Icons.settings, "Settings"),
              _drawerTile(Icons.help_outline, "Help & Support"),
              _drawerTile(Icons.info_outline, "About Local Hands"),
              const SizedBox(height: 12),
              _drawerTile(Icons.logout, "Logout", color: Colors.redAccent),
              const SizedBox(height: 24),
            ],
          ),
        ],
      ),
    );
  }

  ListTile _drawerTile(
    IconData icon,
    String title, {
    Color color = Colors.black,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500, color: color),
      ),
      onTap: () {
        if (title == "Profile") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        }
      },
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0, size.height - 40);

    // first curve
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height - 30,
    );

    // second curve
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 80,
      size.width,
      size.height - 40,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
class _GlassyProfileOverlay extends StatelessWidget {
  const _GlassyProfileOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.3), // glassy backdrop
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context), // tap outside to close
            child: Container(color: Colors.transparent),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85), // glassy panel
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: const Offset(-4, 0),
                  ),
                ],
              ),
              child: const ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                ),
                child: ProfileScreen(), // your profile screen widget
              ),
            ),
          ),
        ],
      ),
    );
  }
}
