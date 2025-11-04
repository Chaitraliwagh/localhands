import 'dart:developer';
import 'package:flutter/material.dart';

class HomewomenSpa extends StatelessWidget {
  const HomewomenSpa({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {
        "title": "HairCare", 
        "image": "assets/haircare.jpeg",
        "color": Color(0xFFFF6B8B)
      },
      {
        "title": "Waxing", 
        "image": "assets/waxing.jpeg",
        "color": Color(0xFFBA68C8)
      },
      {
        "title": "Massage", 
        "image": "assets/massage.jpeg",
        "color": Color(0xFF4FC3F7)
      },
      {
        "title": "Manicure", 
        "image": "assets/manicure.jpeg",
        "color": Color(0xFFFFB74D)
      },
      {
        "title": "Pedicure", 
        "image": "assets/pedicure.jpeg",
        "color": Color(0xFF81C784)
      },
    ];

    return SingleChildScrollView( // Wrap with SingleChildScrollView
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Enhanced Title Row ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Salon for Women",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Professional beauty services",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    log("View More clicked");
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Color(0xFF1D828E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "See all",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1D828E),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: Color(0xFF1D828E),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // --- Horizontal scrollable cards ---
          SizedBox(
            height: 200, // Reduced height
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return GestureDetector(
                  onTap: () {
                    log("${item["title"]} tapped");
                  },
                  child: Container(
                    width: 150, // Slightly reduced width
                    margin: const EdgeInsets.only(right: 12),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Image section
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: Image.asset(
                                item["image"],
                                height: 110, // Reduced height
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 110,
                                    color: Colors.grey.shade200,
                                    child: Icon(
                                      Icons.spa,
                                      color: item["color"],
                                      size: 40,
                                    ),
                                  );
                                },
                              ),
                            ),
                            Container(
                              height: 110,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.2),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            // Service badge
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: item["color"],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "Popular",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        // Content section
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item["title"],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      "4.8",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  "Book Now",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF1D828E),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
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

          const SizedBox(height: 20),

          // --- Offer container with conditional rendering ---
          LayoutBuilder(
            builder: (context, constraints) {
              // Only show offer if there's enough space
              if (constraints.maxHeight > 500) {
                return _buildOfferSection();
              } else {
                return const SizedBox.shrink(); // Hide if not enough space
              }
            },
          ),
          
          const SizedBox(height: 16),
          
          // Quick actions row
          _buildQuickActionsRow(),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

 Widget _buildOfferSection() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Container(
      height: 160, // Reduced height
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background image
            Image.asset(
              "assets/offerdoorbell.jpeg",
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Color(0xFF1D828E),
                  child: Center(
                    child: Icon(
                      Icons.celebration,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                );
              },
            ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                    Colors.black.withOpacity(0.2),
                  ],
                ),
              ),
            ),

            // Content - FIXED: Added constraints and adjusted padding
            Positioned(
              left: 16,
              top: 16,
              bottom: 16,
              right: 16, // Added right constraint
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8, // Reduced
                      vertical: 3,   // Reduced
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6), // Reduced
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      "SPECIAL OFFER",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9, // Reduced from 10
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8, // Reduced
                      ),
                    ),
                  ),
                  const SizedBox(height: 6), // Reduced
                  Flexible( // Added Flexible to prevent overflow
                    child: Text(
                      "Camera.Doorbell\nAll-in-one.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14, // Reduced from 16
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2, // Added maxLines
                    ),
                  ),
                  const SizedBox(height: 3), // Reduced
                  Text(
                    "Smart home security",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11, // Reduced from 12
                    ),
                    maxLines: 1, // Added maxLines
                  ),
                  const SizedBox(height: 8), // Reduced from 12
                  ElevatedButton(
                    onPressed: () {
                      log("Buy Now clicked");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xFF1D828E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6), // Reduced
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, // Reduced
                        vertical: 6,   // Reduced
                      ),
                      visualDensity: VisualDensity.compact,
                      minimumSize: Size.zero, // Added to make button smaller
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      "Buy Now",
                      style: TextStyle(
                        fontSize: 11, // Reduced from 12
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildQuickActionsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildQuickAction(
            icon: Icons.calendar_today,
            label: "Book\nAppointment",
            onTap: () => log("Book Appointment tapped"),
          ),
          const SizedBox(width: 12),
          _buildQuickAction(
            icon: Icons.local_offer,
            label: "View\nOffers",
            onTap: () => log("View Offers tapped"),
          ),
          const SizedBox(width: 12),
          _buildQuickAction(
            icon: Icons.phone,
            label: "Call\nSalon",
            onTap: () => log("Call Salon tapped"),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Color(0xFF1D828E),
                size: 18,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Color(0xFF2D3748),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}