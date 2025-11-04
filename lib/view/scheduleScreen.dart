
import 'package:flutter/material.dart';
import 'package:localhands_app/model/workerModal.dart';

class ScheduleScreen extends StatefulWidget {
  final WorkerModel? worker;           // nullable
  final Map<String, dynamic>? profile; // nullable
  final int bookingStep;               // current step
  final ValueChanged<int> onStepChanged;
  final String? category;
  final DateTime startDate;
  final DateTime? endDate;

  const ScheduleScreen({
    super.key,
    this.worker,
    this.profile,
    required this.bookingStep,
    required this.onStepChanged,
    this.category,
    required this.startDate,
    this.endDate,
  });

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late DateTime selectedDate;

  final List<String> steps = [
    "Request Sent",
    "Service Booked",
    "Service Confirmed",
    "Completed"
  ];

  @override
  void initState() {
    super.initState();
    selectedDate = widget.startDate;
  }

  Widget buildMilestone() {
    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isEven) {
          int stepIndex = i ~/ 2;
          bool isCompleted = widget.bookingStep > stepIndex;
          bool isCurrent = widget.bookingStep == stepIndex;

          return Column(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor:
                    isCompleted || isCurrent ? Colors.green : Colors.grey[300],
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
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
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCurrent || isCompleted ? Colors.green : Colors.black54,
                  ),
                ),
              ),
            ],
          );
        } else {
          int leftStep = i ~/ 2;
          bool isCompleted = widget.bookingStep > leftStep;
          return Expanded(
            child: Container(
              height: 2,
              color: isCompleted ? Colors.green : Colors.grey[300],
            ),
          );
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.worker?.name ?? widget.profile?['name'] ?? '';
    final city = widget.worker?.city ?? widget.profile?['city'] ?? '';
    final rating = widget.worker?.rating ?? widget.profile?['rating'] ?? 0;
    final price = widget.worker?.price ?? widget.profile?['cost'] ?? '';
    final services =
        widget.worker?.services ?? (widget.profile?['services'] as List? ?? []);

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Milestone / Step Tracker
            buildMilestone(),
            const SizedBox(height: 24),

            if (city.isNotEmpty) Text("City: $city"),
            Text("Rating: $rating"),
            Text("Price: ₹$price"),
            Text("Services: ${services.join(", ")}"),
            const SizedBox(height: 20),

            // Pick date
            ElevatedButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => selectedDate = date);
                }
              },
              child: Text("Select Date: ${selectedDate.toLocal()}".split(' ')[0]),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.onStepChanged(
                  widget.bookingStep + 1,
                ); // move to next step
                widget.onStepChanged(widget.bookingStep + 1); // move to next step
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Booking Scheduled!")),
                );
              },
              child: const Text("Confirm Booking"),
            ),
          ],
        ),
      ),
    );
  }
}