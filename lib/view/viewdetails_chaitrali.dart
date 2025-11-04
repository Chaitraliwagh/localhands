import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localhands_app/view/info_chaitrali.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String twilioAccountSid =
    "AC88947f06e39dfcff722cb8da0bdd4873"; // your Account SID
const String twilioAuthToken =
    "2dbb482af5e26a93b2bb50d0c1308093"; // your Auth Token
const String twilioVerifyServiceSid =
    "VA05415f30aa2b6da332d47ab5589e084d"; // your Verify Service SID

Future<bool> sendOtpToCustomer(
  String phoneNumber,
  Function() onCodeSent,
) async {
  try {
    // 1) Guard: phone number present
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      print("⚠️ sendOtpToCustomer: phoneNumber is null/empty");
      return false;
    }

    // 2) Ensure E.164 format (basic)
    if (!phoneNumber.startsWith('+')) {
      phoneNumber = '+91${phoneNumber.replaceAll(RegExp(r'\D'), '')}';
    }

    print("📲 sendOtpToCustomer: sending to $phoneNumber");

    final url = Uri.parse(
      "https://verify.twilio.com/v2/Services/$twilioVerifyServiceSid/Verifications",
    );

    // 3) Make request with a timeout
    final response = await http
        .post(
          url,
          headers: {
            'Authorization':
                'Basic ${base64Encode(utf8.encode('$twilioAccountSid:$twilioAuthToken'))}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {'To': phoneNumber, 'Channel': 'sms'},
        )
        .timeout(const Duration(seconds: 15));

    print("📩 Twilio Response: ${response.statusCode} -> ${response.body}");

    // 4) Accept 200 OR 201
    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final body = jsonDecode(response.body);
        if (body['status'] == 'pending' || body['status'] == 'sent') {
          print("✅ Twilio: OTP request pending/sent");
          onCodeSent();
          return true;
        } else {
          print("⚠️ Twilio returned unexpected status: ${body['status']}");
        }
      } catch (e) {
        // if body is not JSON, still treat as success when code is 200/201
        print("ℹ️ Non-JSON response but status is ${response.statusCode}");
        onCodeSent();
        return true;
      }
    }

    print("❌ Failed to send OTP: ${response.body}");
    return false;
  } on TimeoutException catch (te) {
    print("⏱️ Timeout sending OTP: $te");
    return false;
  } catch (e) {
    print("🔥 Exception in sendOtpToCustomer: $e");
    return false;
  }
}

Future<bool> verifyOtpFromCustomer(String phoneNumber, String otpCode) async {
  final url = Uri.parse(
    "https://verify.twilio.com/v2/Services/$twilioVerifyServiceSid/VerificationCheck",
  );

  final response = await http.post(
    url,
    headers: {
      'Authorization':
          'Basic ${base64Encode(utf8.encode('$twilioAccountSid:$twilioAuthToken'))}',
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: {'To': phoneNumber, 'Code': otpCode},
  );

  final data = jsonDecode(response.body);
  if (response.statusCode == 200 && data['status'] == 'approved') {
    print("✅ OTP verified successfully");
    return true;
  } else {
    print("❌ Invalid OTP: ${response.body}");
    return false;
  }
}

Widget gradientButton(String text, VoidCallback onTap) {
  return Container(
    width: double.infinity,
    height: 50,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF1D828E), Color.fromARGB(255, 50, 189, 117)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.white.withOpacity(0.3),
        highlightColor: Colors.white.withOpacity(0.1),
        onTap: onTap,
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _infoRow({
  required IconData icon,
  required String label,
  required String value,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A237E).withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: const Color(0xFF1A237E), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF0E0E0E),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Future<void> testTwilioFromApp() async {
  print("🔧 testTwilioFromApp running...");
  final ok = await sendOtpToCustomer('+917219619447', () {
    print("callback: onCodeSent called from testTwilioFromApp");
  });
  print("testTwilioFromApp result: $ok");
}

void showJobDetailsBottomSheet(BuildContext context, Map<String, dynamic> job) {
  bool isAccepted = job["status"] == "ongoing";
  bool isCompleted = job["status"] == "completed";
  bool otpRequested = false;
  final TextEditingController otpController = TextEditingController();

  showModalBottomSheet(
    context: context,
    enableDrag: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.75,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFCFAF8),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Pull indicator
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Service Image Card
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          job["image"] ?? "assets/images/explore.jpeg",
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Service Name
                    Text(
                      job["service"] ?? job["title"] ?? "Service not specified",

                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF140F1F),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Customer Info Card
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 5,
                      shadowColor: Colors.black12,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [Colors.white, const Color(0xFFF8FAFB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with customer name
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF1D828E,
                                    ).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(
                                    Icons.person,
                                    color: Color(0xFF1D828E),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        job["customer"] ?? "Unknown Customer",
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF0E0E0E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),
                            const Divider(
                              color: Color(0xFFE0E0E0),
                              thickness: 1,
                              height: 10,
                            ),
                            const SizedBox(height: 10),

                            // Info Rows
                            _infoRow(
                              icon: Icons.location_on_outlined,
                              label: "Location",
                              value: job["location"] ?? "Not specified",
                            ),
                            _infoRow(
                              icon: Icons.calendar_today_outlined,
                              label: "Date",
                              value: job["date"] ?? "N/A",
                            ),

                            _infoRow(
                              icon: Icons.access_time_outlined,
                              label: "Time",
                              value: job["time"] ?? "N/A",
                            ),
                            _infoRow(
                              icon: Icons.payment_rounded,
                              label: "Payment Mode",
                              value: job["paymentMode"] ?? "Cash",
                            ),

                            const SizedBox(height: 8),

                            // Footer / Earnings
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF1D828E,
                                ).withOpacity(0.07),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Estimated Earnings",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: const Color(0xFF1D828E),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    "₹${job["earnings"] ?? 0}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1A237E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Location Card with Map
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target:
                                      job["latLng"] ??
                                      const LatLng(18.5204, 73.8567),
                                  zoom: 14,
                                ),
                                markers: {
                                  Marker(
                                    markerId: const MarkerId("jobLocation"),
                                    position:
                                        job["latLng"] ??
                                        const LatLng(18.5204, 73.8567),
                                  ),
                                },
                                zoomControlsEnabled: false,
                                myLocationButtonEnabled: false,
                                mapType: MapType.normal,
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Color(0xFF1D828E),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    job["location"] ?? "Not specified",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: const Color(0xFF140F1F),
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final lat =
                                        job["latLng"]?.latitude ?? 18.5204;
                                    final lng =
                                        job["latLng"]?.longitude ?? 73.8567;
                                    final Uri uri = Uri.parse(
                                      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
                                    );
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(
                                        uri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 4,
                                    shadowColor: Colors.black26,
                                    backgroundColor: Colors.transparent,
                                  ),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF1D828E),
                                          Color.fromARGB(255, 50, 189, 117),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Container(
                                      width: 120,
                                      height: 40,
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.map,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "Open Map",
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
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
                    const SizedBox(height: 12),

                    // Special Instructions
                    if ((job["instructions"] ?? "").isNotEmpty)
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Special Instructions",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF140F1F),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                job["instructions"] ??
                                    "No special instructions",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: const Color(0xFF140F1F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),

                    // Estimated Earnings
                    Text(
                      "Estimated Earnings: ₹${job["earnings"] ?? 0}",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF140F1F),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Accept / Reject / Navigate Buttons
                    Row(
                      children: [
                        Expanded(
                          child: gradientButton(
                            isAccepted ? "Accepted" : "Accept",
                            isAccepted
                                ? () {}
                                : () {
                                    setState(() {
                                      isAccepted = true;
                                    });
                                    job["status"] = "ongoing";
                                    (job["onAcceptJob"] ?? () {})();
                                  },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: job["rejectCallback"] ?? () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              "Reject",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF140F1F),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    gradientButton(
                      "Navigate",
                      job["navigateCallback"] ?? () {},
                    ),

                    const SizedBox(height: 20),

                    // Work Completion Flow
                    if (isAccepted && !isCompleted) ...[
                      const Divider(height: 32, thickness: 1),
                      Text(
                        "Work Completion",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF140F1F),
                        ),
                      ),
                      const SizedBox(height: 10),

                      if (!otpRequested)
                        gradientButton("Mark Work as Completed", () async {
                          // quick guard
                          final customerPhone =
                              job["customerPhone"]?.toString() ?? '';
                          print(
                            "➡️ Mark Work tapped for phone: $customerPhone",
                          );

                          if (customerPhone.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Customer phone not available"),
                              ),
                            );
                            return;
                          }

                          // show loading snackbar while waiting
                          final snack = ScaffoldMessenger.of(context)
                              .showSnackBar(
                                const SnackBar(
                                  content: Text("Sending OTP..."),
                                  duration: Duration(seconds: 30),
                                ),
                              );

                          final success = await sendOtpToCustomer(
                            customerPhone,
                            () {
                              setState(() {
                                otpRequested = true;
                              });
                            },
                          );

                          // hide (or replace) the previous snackbar
                          snack.close();

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "OTP sent (check customer's phone)",
                                ),
                              ),
                            );
                            print("✅ sendOtpToCustomer returned true");
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Failed to send OTP. Check console logs.",
                                ),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            print("❌ sendOtpToCustomer returned false");
                          }
                        }),

                      if (otpRequested) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: otpController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Enter OTP received by customer",
                            hintStyle: GoogleFonts.poppins(fontSize: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        gradientButton("Confirm Completion", () async {
                          final enteredOtp = otpController.text.trim();

                          bool verified = await verifyOtpFromCustomer(
                            job["customerPhone"],
                            enteredOtp,
                          );
                          if (verified) {
                            setState(() {
                              isCompleted = true;
                              job["status"] = "completed";
                            });
                            (job["onCompleteJob"] ?? () {})();

                            (job["onNotify"] ?? () {})();

                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Invalid OTP. Please try again."),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        }),
                      ],
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}
