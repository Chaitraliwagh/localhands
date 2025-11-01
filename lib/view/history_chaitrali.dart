import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  final Color bgColor = const Color(0xFFFCFAF8);
  final Color primaryColor = const Color(0xFF1D828E);
  final Color textColor = const Color(0xFF140F1F);

  final List<Map<String, String>> pastJobs = const [
    {"job": "AC Repair", "customer": "Ramesh Kumar", "date": "06 Oct 2025"},
    {"job": "Plumbing", "customer": "Sneha Joshi", "date": "05 Oct 2025"},
    {
      "job": "Washing Machine Fix",
      "customer": "Suresh Patil",
      "date": "04 Oct 2025",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          "History",
          style: GoogleFonts.poppins(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pastJobs.length,
        itemBuilder: (context, index) {
          final job = pastJobs[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job["job"]!,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Customer: ${job["customer"]}",
                    style: GoogleFonts.poppins(color: Colors.grey[700]),
                  ),
                  Text(
                    "Date: ${job["date"]}",
                    style: GoogleFonts.poppins(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
