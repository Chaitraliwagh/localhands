
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localhands_app/home/login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _pickImage(String uid) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery, 
        imageQuality: 80
      );
      
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final base64Image = base64Encode(bytes);

        final docRef = _firestore.collection('users').doc(uid);
        await docRef.set(
          {'profileImage': base64Image}, 
          SetOptions(merge: true)
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile picture: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editInfo(String uid, String currentName, String currentAddress) {
    final nameController = TextEditingController(text: currentName);
    final addressController = TextEditingController(text: currentAddress);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: "Address",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              final newAddress = addressController.text.trim();

              if (newName.isEmpty || newAddress.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all fields'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              try {
                final docRef = _firestore.collection('users').doc(uid);
                await docRef.set({
                  'name': newName,
                  'address': newAddress,
                  'updatedAt': FieldValue.serverTimestamp(),
                }, SetOptions(merge: true));

                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to update profile: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D828E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Save",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (route) => false,
      );
    } catch (e) {
      print('Logout error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Logout",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingProfile(Color themeColor) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            const SizedBox(height: 20),

            // Loading profile section
            Row(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white24,
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 160,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Divider(color: Colors.white24, thickness: 0.5),

            // Loading sections
            ...List.generate(3, (index) => Column(
              children: [
                _buildSectionLoading(),
                const SizedBox(height: 20),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(3, (index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _profileTile(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white70, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return _buildLoggedOutProfile();
    }

    final Color themeColor = const Color(0xFF1D828E);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Blurred Glassy Background - FIXED: Moved to bottom
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themeColor.withOpacity(0.9),
                  themeColor.withOpacity(0.7)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),

          // Main content - FIXED: Made interactive
          IgnorePointer(
            ignoring: false, // Ensure touch events pass through
            child: Column(
              children: [
                // SafeArea for top part only
                SafeArea(
                  bottom: false,
                  child: Container(),
                ),
                
                // Scrollable content
                Expanded(
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: _firestore.collection('users').doc(user.uid).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return _buildLoadingProfile(themeColor);
                      }

                      final data = snapshot.data!.data() as Map<String, dynamic>?;
                      
                      final name = data?['name'] ?? "No Name";
                      final address = data?['address'] ?? "No Address";
                      final role = data?['role'] ?? "User";
                      final imageBase64 = data?['profileImage'];

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Back button - FIXED: Wrapped with Material for better touch
                              Material(
                                color: Colors.transparent,
                                child: IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                                ),
                              ),

                              // Profile Header with Image Picker
                              Row(
                                children: [
                                  // Profile Image with GestureDetector
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => _pickImage(user.uid),
                                      borderRadius: BorderRadius.circular(50),
                                      child: Stack(
                                        children: [
                                          CircleAvatar(
                                            radius: 50,
                                            backgroundColor: Colors.white,
                                            child: CircleAvatar(
                                              radius: 48,
                                              backgroundImage: imageBase64 != null
                                                  ? MemoryImage(base64Decode(imageBase64))
                                                  : const AssetImage('assets/profilepic.jpg')
                                                      as ImageProvider,
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.blueAccent,
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(color: Colors.white, width: 2),
                                              ),
                                              padding: const EdgeInsets.all(6),
                                              child: const Icon(Icons.camera_alt,
                                                  color: Colors.white, size: 16),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                name,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            // Edit button - FIXED: Wrapped with Material
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () => _editInfo(user.uid, name, address),
                                                borderRadius: BorderRadius.circular(8),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withOpacity(0.3),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  padding: const EdgeInsets.all(6),
                                                  child: const Icon(Icons.edit,
                                                      size: 18, color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          address,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            role,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 30),
                              const Divider(color: Colors.white24, thickness: 0.5),

                              // Services Section
                              _buildSection("Services", [
                                _profileTile(Icons.pending_actions, "Upcoming Services", () {
                                  print("Upcoming Services tapped");
                                  // Navigate to upcoming services
                                }),
                                _profileTile(Icons.check_circle, "Completed Services", () {
                                  print("Completed Services tapped");
                                  // Navigate to completed services
                                }),
                                _profileTile(Icons.cancel, "Cancelled Services", () {
                                  print("Cancelled Services tapped");
                                  // Navigate to cancelled services
                                }),
                              ]),

                              const SizedBox(height: 20),

                              // Payments Section
                              _buildSection("Payments", [
                                _profileTile(Icons.receipt, "Receipts", () {
                                  print("Receipts tapped");
                                  // Navigate to receipts
                                }),
                                _profileTile(Icons.credit_card, "Payment Methods", () {
                                  print("Payment Methods tapped");
                                  // Navigate to payment methods
                                }),
                                _profileTile(Icons.history, "Transaction History", () {
                                  print("Transaction History tapped");
                                  // Navigate to transaction history
                                }),
                                _profileTile(Icons.account_balance_wallet, "Wallet & Transactions", () {
                                  print("Wallet tapped");
                                  // Navigate to wallet
                                }),
                              ]),

                              const SizedBox(height: 20),

                              // Settings Section
                              _buildSection("Settings", [
                                _profileTile(Icons.notifications, "Notifications", () {
                                  print("Notifications tapped");
                                  // Navigate to notifications
                                }),
                                _profileTile(Icons.settings, "Settings", () {
                                  print("Settings tapped");
                                  // Navigate to settings
                                }),
                                _profileTile(Icons.help, "Help & Support", () {
                                  print("Help & Support tapped");
                                  // Navigate to help & support
                                }),
                                _profileTile(Icons.info, "About App", () {
                                  print("About App tapped");
                                  // Navigate to about app
                                }),
                              ]),

                              const SizedBox(height: 30),

                              // Logout Button - FIXED: Wrapped with Material
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _showLogoutConfirmation,
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white.withOpacity(0.6)),
                                      color: Colors.red.withOpacity(0.3),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.logout, color: Colors.white, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          "Logout",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedOutProfile() {
    final Color themeColor = const Color(0xFF1D828E);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themeColor.withOpacity(0.9),
                  themeColor.withOpacity(0.7)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          IgnorePointer(
            ignoring: false,
            child: Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: Container(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 40),
                          const CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white24,
                            child: Icon(Icons.person, color: Colors.white, size: 50),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Guest User",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Please login to access your profile",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                                  (route) => false,
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.6)),
                                  color: Colors.white.withOpacity(0.2),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Login / Sign Up",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
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
    );
  }
}