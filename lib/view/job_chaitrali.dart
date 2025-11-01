import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localhands_app/view/chatscreen.dart';
import 'package:localhands_app/view/viewdetails_chaitrali.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> with TickerProviderStateMixin {
  final Color bgColor = const Color(0xFFFCFAF8);
  final Color primaryColor = const Color(0xFF1D828E);
  final Color secondaryColor = const Color(0xFFFEAC5D);
  final Color textColor = const Color(0xFF140F1F);

  final List<Map<String, dynamic>> jobs = [
    {
      "title": "AC Repair",
      "service": "AC Repair", // Add this
      "location": "MG Road, Pune",
      "customer": "Ramesh Kumar",
      "customerPhone": "+917219619447",
      "time": "2:30 PM",
      "rating": 4.5,
      "urgent": true,
      "paymentStatus": "Paid",
      "distance": "1.2 km",
      "status": "Ongoing",
      "earnings": 500, // Add this
    },
    {
      "title": "Washing Machine Fix",
      "service": "Washing Machine Fix",
      "location": "Kothrud, Pune",
      "customer": "Suresh Patil",
      "customerPhone": "+917219619447",
      "time": "4:00 PM",
      "rating": 4.0,
      "urgent": false,
      "paymentStatus": "Pending",
      "distance": "2.5 km",
      "status": "Upcoming",
      "earnings": 700,
    },
    {
      "title": "Plumbing",
      "service": "Plumbing",
      "location": "Aundh, Pune",
      "customerPhone": "+917219619447",
      "customer": "Sneha Joshi",
      "time": "6:30 PM",
      "rating": 5.0,
      "urgent": true,
      "paymentStatus": "Paid",
      "distance": "0.8 km",
      "status": "Ongoing",
      "earnings": 300,
    },
  ];

  late TabController _tabController;
  String searchQuery = '';
  String filterType = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  List<Map<String, dynamic>> getFilteredJobs(String status) {
    return jobs.where((job) {
      final matchesStatus = job['status'] == status;
      final matchesSearch =
          job['title'].toString().toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
          job['customer'].toString().toLowerCase().contains(
            searchQuery.toLowerCase(),
          );
      return matchesStatus && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          "Jobs Update",
          style: GoogleFonts.poppins(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  onChanged: (value) => setState(() => searchQuery = value),
                  decoration: InputDecoration(
                    hintText: "Search jobs or customer...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: primaryColor,
                labelColor: textColor,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: "Ongoing"),
                  Tab(text: "Upcoming"),
                  Tab(text: "Completed"),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildJobList(getFilteredJobs('Ongoing')),
          buildJobList(getFilteredJobs('Upcoming')),
          buildJobList(getFilteredJobs('Completed')),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showFilterSheet(),
        backgroundColor: primaryColor,
        child: const Icon(Icons.filter_list),
      ),
    );
  }

  Widget buildJobList(List<Map<String, dynamic>> jobList) {
    if (jobList.isEmpty) {
      return Center(
        child: Text(
          "No jobs found",
          style: GoogleFonts.poppins(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jobList.length,
      itemBuilder: (context, index) {
        final job = jobList[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: buildJobCard(job),
        );
      },
    );
  }

  Widget buildJobCard(Map<String, dynamic> job) {
    Color urgentColor = job['urgent'] ? Colors.red : Colors.green;

    return Dismissible(
      key: Key(job['title'] + job['time']),
      background: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerLeft,
        color: Colors.green,
        child: const Icon(Icons.check, color: Colors.white),
      ),
      secondaryBackground: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        color: Colors.red,
        child: const Icon(Icons.close, color: Colors.white),
      ),
      onDismissed: (direction) {
        // handle swipe actions
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    job["title"],
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: urgentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    job['urgent'] ? "Urgent" : "Normal",
                    style: GoogleFonts.poppins(
                      color: urgentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  job["location"],
                  style: GoogleFonts.poppins(color: Colors.grey[700]),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  job["time"],
                  style: GoogleFonts.poppins(color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  job["customer"],
                  style: GoogleFonts.poppins(color: Colors.grey[700]),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.star, size: 16, color: Colors.amber),
                Text(
                  job["rating"].toString(),
                  style: GoogleFonts.poppins(color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  job["paymentStatus"],
                  style: GoogleFonts.poppins(color: Colors.grey[700]),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.directions, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  job["distance"],
                  style: GoogleFonts.poppins(color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 🔹 Buttons depending on job status
            Row(
              children: [
                if (job['status'] == 'Ongoing') ...[
                  _buildGradientButton(
                    "Open",
                    Icons.open_in_new,
                    onTap: () => showJobDetailsBottomSheet(context, job),
                  ),
                  const SizedBox(width: 12),
                  _buildCallButton(),
                ] else if (job['status'] == 'Upcoming') ...[
                  _buildGradientButton(
                    "Accept",
                    Icons.check_box,
                    onTap: () => showJobDetailsBottomSheet(context, job),
                  ),
                  const SizedBox(width: 12),
                  _buildCallButton(),
                ] else if (job['status'] == 'Completed') ...[
                  _buildGradientButton(
                    "View Details",
                    Icons.visibility,
                    onTap: () {},
                  ),
                  const SizedBox(width: 12),
                  _buildGradientButton(
                    "Feedback",
                    Icons.rate_review,
                    onTap: () {},
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Reusable gradient button (Open, Accept, View Details, Feedback)
  Widget _buildGradientButton(
    String text,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          width: 95,
          height: 42,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 4),
              Text(
                text,
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
    );
  }

  /// 🔹 Call button (used in Ongoing & Upcoming)
  Widget _buildCallButton() {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: 'user123_worker456', // fixed unique id for both
              currentUserId: 'worker456',
            ),
          ),
        );
      },
      icon: const Icon(Icons.phone),
      label: Text(
        "Call",
        style: TextStyle(
          color: hexToColor("#1A237E"),
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Filter Jobs",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text("All"),
                    leading: Radio<String>(
                      value: 'All',
                      groupValue: filterType,
                      onChanged: (value) => setState(() => filterType = value!),
                    ),
                  ),
                  ListTile(
                    title: const Text("Urgent"),
                    leading: Radio<String>(
                      value: 'Urgent',
                      groupValue: filterType,
                      onChanged: (value) => setState(() => filterType = value!),
                    ),
                  ),
                  ListTile(
                    title: const Text("Non-Urgent"),
                    leading: Radio<String>(
                      value: 'Non-Urgent',
                      groupValue: filterType,
                      onChanged: (value) => setState(() => filterType = value!),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Apply Filter"),
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
