import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localhands_app/view/admin_doc_chaitrali.dart';
import 'package:localhands_app/view/home_chaitrali.dart';
import 'package:localhands_app/home/login.dart';
import 'package:open_file/open_file.dart';

class DocumentationScreen extends StatefulWidget {
  const DocumentationScreen({super.key});

  @override
  State<DocumentationScreen> createState() => _DocumentationScreenState();
}

class _DocumentationScreenState extends State<DocumentationScreen>
    with SingleTickerProviderStateMixin {
  String? aadhaarFile;
  String? panFile;
  String? certificateFile;
  String? profilePhotoFile;

  final ImagePicker _picker = ImagePicker();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  String? userId;

  bool allUploaded = false;
  bool verificationRequested = false;
  bool isVerified = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    // ✅ Get logged-in Firebase user
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;

      // ✅ Check immediately if user already verified
      FirebaseFirestore.instance.collection('users').doc(userId).get().then((
        doc,
      ) {
        if (doc.exists && doc['isVerified'] == true) {
          // Already verified → skip document upload screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const PartnerDashboard()),
          );
        } else {
          // Not verified → continue listening for updates
          _listenToVerificationUpdates();
        }
      });
    } else {
      // No user signed in — show snackbar or handle redirection if needed
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User not logged in.")));
      });
    }
  }

  void _listenToVerificationUpdates() {
    if (userId == null) return;
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            setState(() {
              verificationRequested =
                  snapshot['verificationRequested'] ?? false;
              isVerified = snapshot['isVerified'] ?? false;
            });
          }
        });
  }

  Future<void> _requestVerification() async {
    if (userId == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'verificationRequested': true,
        'isVerified': false,
      }, SetOptions(merge: true));

      setState(() {
        verificationRequested = true;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Verification requested!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error requesting verification: $e")),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _checkAllUploaded() {
    setState(() {
      allUploaded =
          aadhaarFile != null &&
          panFile != null &&
          certificateFile != null &&
          profilePhotoFile != null;
    });
  }

  void _proceed() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PartnerDashboard()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // 🔙 Back arrow button
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black87,
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AuthScreen(),
                        ),
                      ); // Go back to login screen
                    },
                  ),
                ),
                const SizedBox(height: 5),

                Text(
                  "Upload Documents 📑",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF140F1F),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Please upload your verification documents to continue",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 30),

                _buildDocCard(
                  "Aadhaar / ID Proof",
                  Icons.credit_card,
                  aadhaarFile,
                ),
                const SizedBox(height: 20),
                _buildDocCard("PAN Card", Icons.badge, panFile),
                const SizedBox(height: 20),
                _buildDocCard(
                  "Certificate / License",
                  Icons.school,
                  certificateFile,
                ),
                const SizedBox(height: 20),
                _buildDocCard(
                  "Profile Photo",
                  Icons.person,
                  profilePhotoFile,
                  isImage: true,
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: allUploaded
                      ? (!verificationRequested
                            ? ElevatedButton(
                                onPressed: _requestVerification,
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
                                    width: 310,
                                    height: 45,
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Request Verification",
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : (!isVerified
                                  ? ElevatedButton(
                                      onPressed: null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey.shade400,
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: Container(
                                        width: 310,
                                        height: 45,
                                        alignment: Alignment.center,
                                        child: Text(
                                          "Waiting for Verification...",
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            color: Colors.white70,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
                                  : ElevatedButton(
                                      onPressed: _proceed,
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: Ink(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              hexToColor("#1D828E"),
                                              hexToColor("#1A237E"),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Container(
                                          width: 310,
                                          height: 45,
                                          alignment: Alignment.center,
                                          child: Text(
                                            "Continue",
                                            style: GoogleFonts.poppins(
                                              fontSize: 18,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )))
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color hexToColor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  Widget _buildDocCard(
    String title,
    IconData icon,
    String? file, {
    bool isImage = false,
  }) {
    final fileName = file?.split('/').last ?? '';
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        gradient: file != null
            ? LinearGradient(
                colors: [hexToColor("#1D828E"), hexToColor("#1A237E")],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: file == null ? Colors.white : null,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: file != null
                      ? LinearGradient(
                          colors: [
                            hexToColor("#1D828E"),
                            hexToColor("#1A237E"),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  icon,
                  color: file != null ? Colors.white : hexToColor("#1D828E"),
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: file != null
                        ? Colors.white
                        : const Color(0xFF140F1F),
                  ),
                ),
              ),
              if (file != null)
                const Icon(
                  Icons.check_circle,
                  color: Colors.lightGreenAccent,
                  size: 24,
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (file != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    fileName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: file != null ? Colors.white70 : Colors.grey[700],
                    ),
                  ),
                ),
                if (isImage)
                  GestureDetector(
                    onTap: () => OpenFile.open(file),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: FileImage(File(file)),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  )
                else
                  IconButton(
                    icon: Icon(
                      Icons.remove_red_eye,
                      color: file != null ? Colors.white : Colors.teal,
                    ),
                    onPressed: () => OpenFile.open(file),
                  ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: () {
                    setState(() {
                      if (title.contains("Aadhaar")) aadhaarFile = null;
                      if (title.contains("PAN")) panFile = null;
                      if (title.contains("Certificate")) certificateFile = null;
                      if (title.contains("Profile")) profilePhotoFile = null;
                      verificationRequested = false;
                      isVerified = false;
                    });
                    _checkAllUploaded();
                  },
                ),
              ],
            )
          else
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _pickFile(title),
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
                        colors: [hexToColor("#1D828E"), hexToColor("#1A237E")],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      width: 110,
                      height: 40,
                      alignment: Alignment.center,
                      child: Text(
                        "Upload",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _captureImage(title),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Camera",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: hexToColor("#1A237E"),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _pickFile(String title) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );
      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        setState(() {
          if (title.contains("Aadhaar")) aadhaarFile = filePath;
          if (title.contains("PAN")) panFile = filePath;
          if (title.contains("Certificate")) certificateFile = filePath;
          if (title.contains("Profile")) profilePhotoFile = filePath;
        });
        _checkAllUploaded();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Selected: ${result.files.single.name}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _captureImage(String title) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          if (title.contains("Aadhaar")) aadhaarFile = image.path;
          if (title.contains("PAN")) panFile = image.path;
          if (title.contains("Certificate")) certificateFile = image.path;
          if (title.contains("Profile")) profilePhotoFile = image.path;
        });
        _checkAllUploaded();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}
