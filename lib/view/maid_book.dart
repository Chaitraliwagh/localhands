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
  final List<Map<String, dynamic>> workers = [
    {
      'name': 'Anita',
      'image': 'assets/maid1.jpg',
      'rating': 4.5,
      'experience': 3,
      'cost': 300,
      'services': ['Cleaning', 'Cooking', 'Laundry'],
    },
    {
      'name': 'Sunita',
      'image': 'assets/maid2.jpg',
      'rating': 4.8,
      'experience': 5,
      'cost': 400,
      'services': ['Cleaning', 'Dishwashing'],
    },
    {
      'name': 'Rekha',
      'image': 'assets/maid3.jpg',
      'rating': 4.2,
      'experience': 2,
      'cost': 250,
      'services': ['Cleaning', 'Ironing'],
    },
  ];

  void openProfile(Map<String, dynamic> worker) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            WorkerProfilePage(profile: worker, category: widget.bookingType),
      ),
    );
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
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/maid.jpg'), // your wallpaper image
            fit: BoxFit.cover, // fills the screen properly
          ),
        ),
        child: SafeArea(
          child: Container(
            // optional: add slight overlay for better text visibility
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.6)),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: workers.length,
              itemBuilder: (context, index) {
                final worker = workers[index];
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
                                const SizedBox(width: 16),
                                Text(
                                  '${worker['experience']} yrs',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${worker['cost']} per hour',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (worker['services'] as List<dynamic>? ?? []).join(
                                ", ",
                              ),
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => openProfile(worker),
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
