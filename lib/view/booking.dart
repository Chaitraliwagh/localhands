import 'package:flutter/material.dart';
import 'scheduleScreen.dart';
import 'pick_date.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// pickDate function

class BookingBottomSheet {
  static void show(
    BuildContext context,
    Map<String, dynamic> profile,
    String category,
    ValueChanged<int> onStepChanged, {
    int initialBookingStep = 0,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        int bookingStep = initialBookingStep;

        return StatefulBuilder(
          builder: (context, setState) {
            void updateStep(int step) {
              setState(() => bookingStep = step);
              onStepChanged(step);
            }

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Milestone chain
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ["Selected", "Scheduled", "Request Sent", "Booking Confirmed"]
                        .asMap()
                        .entries
                        .map((entry) {
                      int idx = entry.key;
                      String stepName = entry.value;
                      bool isCompleted = bookingStep > idx;
                      bool isCurrent = bookingStep == idx;

                      return Column(
                        children: [
                          CircleAvatar(
                            radius: 14,
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
                          SizedBox(
                            width: 70,
                            child: Text(
                              stepName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                color: isCurrent ? Colors.green : Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Profile info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundImage: AssetImage(profile["image"]),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(profile["name"] ?? "",
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(profile["services"] != null ? (profile["services"] as List).join(", ") : "",
                                style: const TextStyle(color: Colors.grey)),
                            Text(profile["price"] ?? "",
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Schedule button
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? startDate = await pickDate(context);
                      if (startDate == null) return;

                      DateTime? endDate;
                      if (category.toUpperCase() == "MONTHLY" || category.toUpperCase() == "FESTIVE") {
                        endDate = await pickDate(context, initialDate: startDate);
                        if (endDate == null) return;
                      }

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ScheduleScreen(
                            profile: profile,
                            bookingStep: bookingStep,
                            onStepChanged: updateStep,
                            category: category,
                            startDate: startDate,
                            endDate: endDate,
                          ),
                        ),
                      );

                      updateStep(1);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                    child: const Text("Schedule", style: TextStyle(color: Colors.white)),
                  ),

                  const SizedBox(height: 10),

                  // Send request button
                  ElevatedButton(
  onPressed: bookingStep >= 1
      ? () async {
          try {
            final user = FirebaseAuth.instance.currentUser;

            await FirebaseFirestore.instance.collection('requests').add({
              'userId': user?.uid ?? '',
              'userEmail': user?.email ?? '',
              'workerName': profile["name"],
              'workerImage': profile["image"],
              'category': category,
              'status': 'pending',
              'startDate': DateTime.now().toIso8601String(),
              'timestamp': FieldValue.serverTimestamp(),
            });

            updateStep(2);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Request Sent Successfully!")),
            );
            Navigator.pop(context);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to send request: $e")),
            );
          }
        }
      : null,

                    style: ElevatedButton.styleFrom(
                        backgroundColor: bookingStep >= 1 ? Colors.green : Colors.grey,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                    child: const Text("Send Request", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
