import 'package:flutter/material.dart';

class WorkerProfilePage extends StatefulWidget {
  final Map<String, dynamic> profile;
  final String category;

  const WorkerProfilePage({
    super.key,
    required this.profile,
    required this.category,
  });

  @override
  State<WorkerProfilePage> createState() => _WorkerProfilePageState();
}

class _WorkerProfilePageState extends State<WorkerProfilePage> {
  int bookingStep = 0; // Milestone step
  bool booked = false;

  void bookNow() {
    setState(() {
      booked = true;
      bookingStep = 1; // Request sent
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Booking request sent!")));
  }

  Widget buildMilestone() {
    final steps = ["Selected", "Request Sent", "Confirmed"];
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
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
                  radius: 18,
                  backgroundColor: isCompleted || isCurrent
                      ? Colors.green
                      : Colors.grey[300],
                  child: isCompleted
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : Text(
                          "${stepIndex + 1}",
                          style: TextStyle(
                            color: isCurrent ? Colors.white : Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 80,
                  child: Text(
                    steps[stepIndex],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isCurrent
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isCurrent ? Colors.green : Colors.black54,
                    ),
                  ),
                ),
              ],
            );
          } else {
            int leftStep = i ~/ 2;
            bool isCompleted = bookingStep > leftStep;
            return Expanded(
              child: Container(
                height: 3,
                color: isCompleted ? Colors.green : Colors.grey[300],
              ),
            );
          }
        }),
      ),
    );
  }

  Widget glassyCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final name = profile['name'] ?? '';
    final image = profile['image'] ?? '';
    final rating = profile['rating'] ?? 0.0;
    final experience = profile['experience'] ?? 0;
    final cost = profile['cost'] ?? '';
    final services = (profile['services'] as List<dynamic>? ?? []).join(", ");

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7EC),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Gradient header with back button and profile image
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1D828E), Color(0xFF32BD75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
              ),
              padding: const EdgeInsets.only(
                top: 48,
                bottom: 32,
              ), // top padding includes status bar
              child: Column(
                children: [
                  // Back button
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Profile image with white border
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage(image),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            // Name below image
            Text(
              name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 6),
                Text('$rating', style: const TextStyle(fontSize: 16)),
              ],
            ),

            // Milestone tracker
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: buildMilestone(),
            ),

            const SizedBox(height: 12),

            // Experience, Price, Services
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  glassyCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Experience",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text("$experience yrs"),
                      ],
                    ),
                  ),
                  glassyCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Price per hour",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text("₹$cost"),
                      ],
                    ),
                  ),
                  glassyCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Services Offered",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(services),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Gradient Book Now Button
                  SizedBox(
                    height: 55,
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: booked
                            ? const LinearGradient(
                                colors: [Colors.grey, Colors.grey],
                              )
                            : const LinearGradient(
                                colors: [Color(0xFF1D828E), Color(0xFF32BD75)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: booked ? null : bookNow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          booked ? "Request Sent" : "Book Now",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
