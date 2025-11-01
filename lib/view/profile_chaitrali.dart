// profile_screen_with_scanner_and_payment.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localhands_app/view/info_chaitrali.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class WorkerProfile {
  String name;
  String role;
  String location;
  String experience;
  String hourlyRate;
  String availability;
  List<String> services;
  double rating;
  int jobsCompleted;
  int pendingTasks;
  Map<String, String> documents;
  String phone;
  String email;

  // New payment fields
  String upiId; // e.g. chaitrali@upi
  String
  upiQr; // free-text representation of QR (could be a code or URL stored as text)
  String paymentNotes; // any extra notes about payment preferences

  WorkerProfile({
    required this.name,
    required this.role,
    required this.location,
    required this.experience,
    required this.hourlyRate,
    required this.availability,
    required this.services,
    required this.rating,
    required this.jobsCompleted,
    required this.pendingTasks,
    required this.documents,
    required this.phone,
    required this.email,
    this.upiId = "",
    this.upiQr = "",
    this.paymentNotes = "",
  });
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// Initially set to your default image
String profileImage = 'assets/images/explore.jpeg';

class _ProfileScreenState extends State<ProfileScreen> {
  WorkerProfile profile = WorkerProfile(
    name: "Chaitrali Wagh",
    role: "Professional Electrician",
    location: "Pune, Maharashtra",
    experience: "5 Years",
    hourlyRate: "₹400/hr",
    availability: "Mon–Sat, 9AM–6PM",
    services: ["Wiring", "Fan Repair", "Switchboard Setup", "LED Installation"],
    rating: 4.8,
    jobsCompleted: 126,
    pendingTasks: 3,
    documents: {
      "Aadhar Card": "Verified",
      "PAN Card": "Pending",
      "Police Verification": "Verified",
    },
    phone: "+91 9876543210",
    email: "chaitrali.worker@example.com",
    upiId: "chaitrali@upi", // default example - editable by worker
    upiQr: "", // empty initially
    paymentNotes: "Prefer UPI / Cash",
  );

  Future<void> _editField(
    String title,
    String current,
    ValueChanged<String> onSave,
  ) async {
    final controller = TextEditingController(text: current);
    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text("Edit $title"),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: title),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  onSave(controller.text.trim());
                  Navigator.of(ctx).pop();
                },
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }

  Future<void> _editServices() async {
    final controller = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (ctx) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Edit Services",
                    style: GoogleFonts.urbanist(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        profile.services
                            .map(
                              (s) => Chip(
                                label: Text(s),
                                onDeleted: () {
                                  setState(() {
                                    profile.services.remove(s);
                                  });
                                  Navigator.of(ctx).pop();
                                  _editServices();
                                },
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            hintText: "Add service",
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final val = controller.text.trim();
                          if (val.isNotEmpty) {
                            setState(() {
                              profile.services.add(val);
                            });
                            controller.clear();
                            Navigator.of(ctx).pop();
                            _editServices();
                          }
                        },
                        child: const Text("Add"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text("Done"),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 40, bottom: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1D828E), Color(0xFF1A237E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTap: _showProfilePhotoOptions,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 52,
                        backgroundImage:
                            profileImage.startsWith('assets/')
                                ? AssetImage(profileImage) as ImageProvider
                                : FileImage(File(profileImage)),
                      ),
                    ),
                  ),

                  Positioned(
                    right: MediaQuery.of(context).size.width * 0.23,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified,
                        color: Colors.blue,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                "Chaitrali Wagh",
                style: GoogleFonts.urbanist(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Professional Electrician",
                style: GoogleFonts.urbanist(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          // 🟢 New edit icon in top-right corner (only addition)
          Positioned(
            top: -9,
            right: 15,
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.white, size: 24),
              onPressed: () {
                _showAllEditDialog();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showProfilePhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Update Profile Photo",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                // Icons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildIconOption(
                      icon: Icons.photo_library,
                      label: "Upload",
                      color: Colors.blue,
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickProfileImage();
                      },
                    ),
                    _buildIconOption(
                      icon: Icons.camera_alt,
                      label: "Camera",
                      color: Colors.green,
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickProfileImageFromCamera();
                      },
                    ),
                    _buildIconOption(
                      icon: Icons.delete_forever,
                      label: "Remove",
                      color: Colors.red,
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() {
                          profileImage = 'assets/images/explore.jpeg';
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Cancel button
                /*GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),*/
              ],
            ),
          ),
    );
  }

  Widget _buildIconOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Add camera option
  Future<void> _pickProfileImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        profileImage = pickedFile.path;
      });
    }
  }

  // Add this function to pick an image from gallery or camera
  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImage = pickedFile.path;
      });
    }
  }

  Future<void> _showAllEditDialog() async {
    final upiController = TextEditingController(text: profile.upiId);
    final qrController = TextEditingController(text: profile.upiQr);
    final notesController = TextEditingController(text: profile.paymentNotes);
    final phoneController = TextEditingController(text: profile.phone);
    final emailController = TextEditingController(text: profile.email);
    final locationController = TextEditingController(text: profile.location);
    final rateController = TextEditingController(text: profile.hourlyRate);
    final availabilityController = TextEditingController(
      text: profile.availability,
    );

    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              "Edit Profile Details",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: hexToColor("#1A237E"),
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  _buildRoundedTextField(phoneController, "Phone"),
                  _buildRoundedTextField(emailController, "Email"),
                  _buildRoundedTextField(locationController, "Location"),
                  _buildRoundedTextField(rateController, "Hourly Rate"),
                  _buildRoundedTextField(
                    availabilityController,
                    "Availability",
                  ),
                  const SizedBox(height: 10),
                  Divider(thickness: 1, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  _buildRoundedTextField(upiController, "UPI ID"),
                  //_buildRoundedTextField(qrController, "QR Info / Code"),
                  _buildRoundedTextField(notesController, "Payment Notes"),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),

                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: hexToColor("#1A237E"), // text color
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    profile.upiId = upiController.text.trim();
                    //profile.upiQr = qrController.text.trim();
                    profile.paymentNotes = notesController.text.trim();
                    profile.phone = phoneController.text.trim();
                    profile.email = emailController.text.trim();
                    profile.location = locationController.text.trim();
                    profile.hourlyRate = rateController.text.trim();
                    profile.availability = availabilityController.text.trim();
                  });
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      EdgeInsets
                          .zero, // remove default padding to match container height
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4, // similar shadow
                  shadowColor: Colors.black26,
                  backgroundColor: Colors.transparent, // required for gradient
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [hexToColor("#1D828E"), hexToColor("#1A237E")],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    width: 90,
                    height: 40, // match Accept button height
                    alignment: Alignment.center,
                    child: Text(
                      "Save",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildRoundedTextField(
    TextEditingController controller,
    String label,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
      ),
    );
  }

  // BASIC INFO CARD
  Widget _buildInfoCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.badge, "Experience", "5 Years"),
          const Divider(),
          _buildInfoRow(
            Icons.location_on_rounded,
            "Location",
            "Pune, Maharashtra",
          ),
          const Divider(),
          _buildInfoRow(Icons.attach_money_rounded, "Hourly Rate", "₹400/hr"),
          const Divider(),
          _buildInfoRow(
            Icons.access_time_rounded,
            "Availability",
            "Mon–Sat, 9AM–6PM",
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: hexToColor("#1A237E"), size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.urbanist(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.urbanist(
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // SERVICES / SKILLS
  Widget _buildServiceDetails() {
    final skills = [
      "Wiring",
      "Fan Repair",
      "Switchboard Setup",
      "LED Installation",
    ];
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Services Offered",
            style: GoogleFonts.urbanist(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                skills
                    .map(
                      (skill) => Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 14,
                        ),
                        decoration: BoxDecoration(
                          color: hexToColor("#1A237E").withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          skill,
                          style: GoogleFonts.urbanist(
                            color: hexToColor("#1A237E"),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  // RATINGS AND JOB STATS
  Widget _buildRatingsAndJobs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D828E), Color(0xFF1A237E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat("⭐ 4.8", "Average Rating", Colors.white),
          _buildStat("126", "Jobs Completed", Colors.white),
          _buildStat("3", "Pending Tasks", Colors.white),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.urbanist(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.urbanist(
            color: color.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // DOCUMENT SECTION
  Widget _buildDocumentsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Documents",
            style: GoogleFonts.urbanist(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _buildDocRow("Aadhar Card", "Verified"),
          const SizedBox(height: 10),
          _buildDocRow("PAN Card", "Pending"),
          const SizedBox(height: 10),
          _buildDocRow("Police Verification", "Verified"),
        ],
      ),
    );
  }

  Widget _buildDocRow(String name, String status) {
    Color color =
        status == "Verified"
            ? Colors.green
            : (status == "Pending" ? Colors.orange : Colors.red);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(name, style: GoogleFonts.urbanist(fontWeight: FontWeight.w600)),
        Row(
          children: [
            Icon(Icons.circle, size: 10, color: color),
            const SizedBox(width: 6),
            Text(
              status,
              style: GoogleFonts.urbanist(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // CONTACT SECTION
  Widget _buildContactSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, Colors.grey.shade100]),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Contact Info",
            style: GoogleFonts.urbanist(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _buildContactItem(Icons.phone, profile.phone),
          const SizedBox(height: 8),
          _buildContactItem(Icons.email_outlined, profile.email),
          const SizedBox(height: 8),
          _buildContactItem(Icons.location_pin, profile.location),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: hexToColor("#1A237E"), size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.urbanist(
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // New: Payment section (worker-provided)
  Widget _buildPaymentSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8), // top spacing
              Text(
                "Payment Info",
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              _paymentRow(
                Icons.account_balance_wallet,
                profile.upiId.isNotEmpty ? profile.upiId : "No UPI ID added",
              ),
              const SizedBox(height: 8),
              _paymentRow(
                Icons.qr_code,
                profile.upiQr.isNotEmpty ? "QR info added" : "No QR info",
              ),
              const SizedBox(height: 8),
              _paymentRow(
                Icons.note,
                profile.paymentNotes.isNotEmpty
                    ? profile.paymentNotes
                    : "No payment notes",
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(Icons.edit, color: hexToColor("#1A237E")),
              onPressed: _editPaymentInfo,
            ),
          ),
        ],
      ),
    );
  }

  // Row builder without individual edit buttons
  Widget _paymentRow(IconData icon, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: hexToColor("#1A237E")),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.urbanist(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  // Single dynamic edit dialog for all payment info
  void _editPaymentInfo() async {
    final upiController = TextEditingController(text: profile.upiId);
    final notesController = TextEditingController(text: profile.paymentNotes);
    File? qrImage;

    await showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setDialogState) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24), // rounder dialog
                  ),
                  backgroundColor: Colors.white,
                  title: Center(
                    child: Text(
                      "Edit Payment Info",
                      style: GoogleFonts.urbanist(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: hexToColor("#1A237E"),
                      ),
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        // UPI ID field
                        TextField(
                          controller: upiController,
                          decoration: InputDecoration(
                            labelText: "UPI ID",
                            labelStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // QR Image upload
                        GestureDetector(
                          onTap: () async {
                            final picked = await ImagePicker().pickImage(
                              source: ImageSource.gallery,
                            );
                            if (picked != null) {
                              setDialogState(() {
                                qrImage = File(picked.path);
                              });
                            }
                          },
                          child: Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade300),
                              color: Colors.grey.shade50,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child:
                                qrImage != null
                                    ? ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.file(
                                        qrImage!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                    : profile.upiQr.isNotEmpty
                                    ? ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.file(
                                        File(profile.upiQr),
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                    : Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.add_a_photo,
                                            size: 32,
                                            color: Colors.grey.shade400,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            "Upload QR Image",
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Payment notes
                        TextField(
                          controller: notesController,
                          decoration: InputDecoration(
                            labelText: "Payment Notes",
                            labelStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                  actionsPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: hexToColor("#1A237E")),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          profile.upiId = upiController.text.trim();
                          profile.paymentNotes = notesController.text.trim();
                          if (qrImage != null) profile.upiQr = qrImage!.path;
                        });
                        Navigator.pop(ctx);
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
                              hexToColor("#1D828E"),
                              hexToColor("#1A237E"),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          width: 80,
                          height: 40,
                          alignment: Alignment.center,
                          child: Text(
                            "Save",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showPaymentOptions({required String jobId, required int amount}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Pay ₹$amount",
                style: GoogleFonts.urbanist(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.payment),
                title: const Text("Pay with UPI"),
                subtitle: Text(
                  profile.upiId.isNotEmpty
                      ? profile.upiId
                      : "No UPI ID provided",
                ),
                onTap: () {
                  if (profile.upiId.isEmpty) {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Worker has not provided a UPI ID"),
                      ),
                    );
                    return;
                  }
                  Navigator.of(ctx).pop();
                  _payWithUpi(
                    upiId: profile.upiId,
                    name: profile.name,
                    amount: amount.toString(),
                    txnRef: jobId,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: const Text("Wallet / In-app"),
                subtitle: const Text("Use wallet balance or in-app payment"),
                onTap: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Wallet payment flow (demo)")),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.money),
                title: const Text("Cash (On Job Completion)"),
                subtitle: const Text("Pay the worker in cash after service"),
                onTap: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Marked as Cash on Delivery")),
                  );
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("Cancel"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _payWithUpi({
    required String upiId,
    required String name,
    required String amount,
    required String txnRef,
  }) async {
    final uri = Uri.parse(
      "upi://pay?pa=$upiId&pn=${Uri.encodeComponent(name)}&tr=$txnRef&am=$amount&cu=INR&tn=${Uri.encodeComponent("Payment for service")}",
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No UPI app found")));
    }
  }

  // ✅ Replaced scanner with manual entry
  Future<void> _scanDocument(String documentKey) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Enter Document ID / Code"),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: "Enter scanned code"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                child: const Text("Save"),
              ),
            ],
          ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        profile.documents[documentKey] = "Scanned: $result";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Document scanned and saved (demo)")),
      );
    }
  }

  // New: manual QR entry for UPI QR value
  Future<void> _scanQrManual() async {
    final controller = TextEditingController(text: profile.upiQr);
    final result = await showDialog<String?>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Enter QR info / code"),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Paste QR text / URL / code",
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, null),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                child: const Text("Save"),
              ),
            ],
          ),
    );

    if (result != null) {
      setState(() {
        profile.upiQr = result;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("QR info saved (demo)")));
    }
  }

  Widget _editIcon(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.edit, size: 18, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔽 Entire UI remains unchanged (only additions appended)
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeaderSection(context),
              const SizedBox(height: 20),
              _buildInfoCard(context),
              const SizedBox(height: 20),
              _buildServiceDetails(),
              const SizedBox(height: 20),
              _buildRatingsAndJobs(),
              const SizedBox(height: 20),
              _buildDocumentsSection(),
              const SizedBox(height: 20),
              _buildContactSection(),
              const SizedBox(height: 20),
              // NEW: Payment section (worker-editable)
              _buildPaymentSection(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Demo: open payment sheet for a sample job
          _showPaymentOptions(jobId: "JOB12345", amount: 500);
        },
        label: const Text("Pay / Test"),
        icon: const Icon(Icons.payments),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
    VoidCallback onEdit,
  ) {
    return Row(
      children: [
        Icon(icon, color: hexToColor("#1A237E")),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.urbanist(fontWeight: FontWeight.w600),
          ),
        ),
        Text(value, style: GoogleFonts.urbanist(color: Colors.grey[700])),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onEdit,
          icon: const Icon(Icons.edit),
          color: Colors.grey,
        ),
      ],
    );
  }

  Widget _statColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.urbanist(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.urbanist(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Future<String?> _promptChoiceForDocStatus(String current) async {
    return showModalBottomSheet<String>(
      context: context,
      builder:
          (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text("Mark Verified"),
                  onTap: () => Navigator.of(ctx).pop("Verified"),
                ),
                ListTile(
                  title: const Text("Mark Pending"),
                  onTap: () => Navigator.of(ctx).pop("Pending"),
                ),
                ListTile(
                  title: const Text("Remove / Not Uploaded"),
                  onTap: () => Navigator.of(ctx).pop("Not Uploaded"),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }
}
