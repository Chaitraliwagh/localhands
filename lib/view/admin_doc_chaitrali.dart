import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';
import 'package:localhands_app/admin/admin.dart';

class AdminVerificationScreen extends StatelessWidget {
  const AdminVerificationScreen({super.key});

  Color getStatusColor(bool isVerified) =>
      isVerified ? Colors.green : Colors.orangeAccent;

  @override
  Widget build(BuildContext context) {
    final Color bgColor = const Color(0xFFFCFAF8);
    final Color textColor = const Color(0xFF140F1F);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Admin Panel",
          style: GoogleFonts.poppins(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // 🔹 Query only unverified workers
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('type', isEqualTo: 'Worker')
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return Center(
              child: Text(
                "No pending verifications.",
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userDoc = users[index];
              final data = userDoc.data() as Map<String, dynamic>;
              final userId = userDoc.id;

              // ✅ Safe field extraction (no crash if missing)
              final name = data['name'] ?? 'Unnamed User';
              final email = data['email'] ?? 'No email';
              final address = data['address'] ?? 'No address';
              final workField = data['workField'] ?? 'N/A';
              final isVerified = data['isVerified'] ?? false;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OpenContainer(
                  closedElevation: 0,
                  openElevation: 6,
                  closedColor: Colors.transparent,
                  openColor: Colors.white,
                  transitionDuration: const Duration(milliseconds: 350),
                  closedBuilder: (context, _) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.white.withOpacity(0.95)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: getStatusColor(isVerified).withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundColor: getStatusColor(
                          isVerified,
                        ).withOpacity(0.1),
                        child: Icon(
                          isVerified
                              ? Icons.verified
                              : Icons.hourglass_bottom_rounded,
                          color: getStatusColor(isVerified),
                          size: 24,
                        ),
                      ),
                      title: Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            email,
                            style: GoogleFonts.poppins(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Work: $workField",
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            "Address: $address",
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isVerified
                                ? "✅ Verified"
                                : "⏳ Pending Verification",
                            style: GoogleFonts.poppins(
                              color: isVerified
                                  ? Colors.green[700]
                                  : Colors.orange[700],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      trailing: isVerified
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : ElevatedButton(
                              onPressed: () async {
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userId)
                                      .update({'isVerified': true});

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.green,
                                      content: Text(
                                        "User $name verified successfully!",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.redAccent,
                                      content: Text(
                                        "Error verifying user: $e",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                              ),
                              child: Text(
                                "Verify",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                    ),
                  ),
                  openBuilder: (context, _) => Scaffold(
                    backgroundColor: bgColor,
                    appBar: AppBar(
                      backgroundColor: bgColor,
                      elevation: 0,
                      leading: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.black87,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      title: Text(
                        "User Details",
                        style: GoogleFonts.poppins(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    body: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: getStatusColor(
                              isVerified,
                            ).withOpacity(0.1),
                            child: Icon(
                              isVerified
                                  ? Icons.verified_user
                                  : Icons.person_outline_rounded,
                              color: getStatusColor(isVerified),
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "User ID: $userId",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Name: $name",
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                          Text(
                            "Email: $email",
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                          Text(
                            "Work Field: $workField",
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                          Text(
                            "Address: $address",
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                          const SizedBox(height: 20),

                          if (data['documents'] != null &&
                              data['documents'] is Map)
                            Center(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () {
                                  final docs =
                                      data['documents'] as Map<String, dynamic>;
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.white,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    builder: (context) => Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: ListView(
                                        shrinkWrap: true,
                                        children: [
                                          Center(
                                            child: Text(
                                              "Uploaded Documents",
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 18,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          ...docs.entries.map((entry) {
                                            final docName = entry.key;
                                            final base64Data = entry.value
                                                .toString();

                                            Widget preview;
                                            try {
                                              final bytes = base64Decode(
                                                base64Data,
                                              );
                                              preview = Image.memory(
                                                bytes,
                                                height: 200,
                                                fit: BoxFit.cover,
                                              );
                                            } catch (_) {
                                              preview = const Icon(
                                                Icons.description,
                                                size: 40,
                                                color: Colors.grey,
                                              );
                                            }

                                            return Card(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              elevation: 3,
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      docName,
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 15,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Center(child: preview),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                    ),
                                  );
                                },
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
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        offset: const Offset(0, 4),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 14,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.folder_open,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          "View Documents",
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            Center(
                              child: Text(
                                "No documents uploaded yet.",
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),

                          const Spacer(),
                          if (!isVerified)
                            Center(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.check),
                                label: Text(
                                  "Verify User",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 14,
                                  ),
                                ),
                                onPressed: () async {
                                  try {
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(userId)
                                        .update({'isVerified': true});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.green,
                                        content: Text(
                                          "User verified successfully!",
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    );
                                    Navigator.pop(context);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.redAccent,
                                        content: Text(
                                          "Error verifying user: $e",
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
