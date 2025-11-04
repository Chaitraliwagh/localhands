import 'package:flutter/material.dart';
import 'maid_book.dart';
import 'pick_date.dart';

class MaidScreen extends StatefulWidget {
  const MaidScreen({super.key});

  @override
  State<MaidScreen> createState() => _MaidScreenState();
}

class _MaidScreenState extends State<MaidScreen> {
  String? selectedOption; // regular, monthly, festive
  DateTime? startDate;
  DateTime? endDate;

  Future<void> pickDate({required bool isStart}) async {
    DateTime initialDate = isStart
        ? (startDate ?? DateTime.now())
        : (endDate ?? DateTime.now());
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
          if (selectedOption != "regular" &&
              endDate != null &&
              picked.isAfter(endDate!)) {
            endDate = null;
          }
        } else {
          endDate = picked;
        }
      });
    }
  }

  bool isContinueEnabled() {
    if (selectedOption == "regular") return startDate != null;
    if (selectedOption == "monthly" || selectedOption == "festive")
      return startDate != null && endDate != null;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Choose Maid Type",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Wallpaper
          SizedBox.expand(
            child: Image.asset("assets/maid.jpg", fit: BoxFit.cover),
          ),
          // Transparent overlay
          Container(color: Colors.black.withOpacity(0.7)),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Options
              buildOption("Regular", "regular"),
              buildOption("Monthly", "monthly"),
              buildOption("Festive", "festive"),

              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: isContinueEnabled()
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MaidBookingScreen(
                              bookingType: selectedOption!.toUpperCase(),
                              startDate:
                                  startDate!, // pass the selected start date
                              endDate: endDate,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isContinueEnabled() ? const Color.fromARGB(255, 7, 11, 10) : Colors.grey,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text("Continue", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildOption(String title, String value) {
    bool isSelected = selectedOption == value;
    return GestureDetector(
      onTap: () async {
        setState(() => selectedOption = value);
        if (value == "regular") {
          await pickDate(isStart: true);
        } else {
          await pickDate(isStart: true);
          await pickDate(isStart: false);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromARGB(255, 10, 16, 10).withOpacity(0.6) : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withOpacity(0.6)),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
