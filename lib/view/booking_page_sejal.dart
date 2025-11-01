import 'package:flutter/material.dart';

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

  // Dummy data
  final List<Map<String, String>> urgentBookings = [
    {
      'title': 'Plumber - Burst Pipe',
      'datetime': 'Today • 6:30 PM',
      'address': 'Faizpur, Maharashtra',
      'image': 'assets/plum1.jpeg',
      'status': 'On the way',
    },
    {
      'title': 'Electrician - Short Circuit',
      'datetime': 'Today • 7:10 PM',
      'address': 'Jalgaon',
      'image': 'assets/plum2.jpeg',
      'status': 'Request sent',
    },
  ];

  final List<Map<String, String>> scheduledBookings = [
    {
      'title': 'Home Cleaning - Deep Clean',
      'datetime': '28 Oct • 10:00 AM',
      'address': 'Near Market',
      'image': 'assets/maid1.jpg',
      'status': 'Scheduled',
    },
    {
      'title': 'Sofa Shampoo',
      'datetime': '30 Oct • 2:00 PM',
      'address': 'Bhosari',
      'image': 'assets/maid2.jpg',
      'status': 'Scheduled',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.7,
        centerTitle: true,
        title: const Text(
          'Bookings',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1D828E), Color.fromARGB(255, 50, 189, 117)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),

      body: Stack(
        children: [
          // 🌊 Full watermark background layer
          Opacity(
            opacity: 0.06, // faint logo effect
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/logoicon.png'),
                  fit: BoxFit.cover, // fills the whole background
                ),
              ),
            ),
          ),

          // 🌟 Main content above the watermark
          Column(
            children: [
              const SizedBox(height: 8),

              // Myntra-style horizontal tab row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    _buildTabButton('Urgent', 0),
                    const SizedBox(width: 16),
                    _buildTabButton('Scheduled', 1),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Divider
              Container(height: 1, color: Colors.grey.withOpacity(0.6)),

              // List
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8.0,
                  ),
                  child: _buildListView(),
                ),
              ),
            ],
          ),
        ],
      ),
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
    final List<Map<String, String>> data = activeTab == 0
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

  Widget _buildBookingCard(Map<String, String> item, bool isUrgent) {
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
                                    // track or details
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
