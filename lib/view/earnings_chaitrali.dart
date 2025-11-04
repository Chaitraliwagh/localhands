import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:localhands_app/view/not_chaitrali.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  final Color bgColor = const Color(0xFFFCFAF8);
  final Color primaryColor = const Color(0xFF1D828E);
  final Color secondaryColor = const Color(0xFFFEAC5D);
  final Color textColor = const Color(0xFF140F1F);

  final List<Map<String, dynamic>> earningsHistory = [
    {
      "title": "AC Repair",
      "amount": 450,
      "date": DateTime(2025, 10, 6),
      "client": "Mr. Sharma",
      "status": "Paid",
    },
    {
      "title": "Plumbing",
      "amount": 300,
      "date": DateTime(2025, 10, 5),
      "client": "Ms. Desai",
      "status": "Pending",
    },
    {
      "title": "Washing Machine Fix",
      "amount": 600,
      "date": DateTime(2025, 10, 4),
      "client": "Mr. Reddy",
      "status": "Paid",
    },
  ];

  // Sample service breakdown
  final Map<String, double> serviceBreakdown = {
    "AC Repair": 5200,
    "Plumbing": 3400,
    "Washing Machine": 2700,
  };

  // Sample client earnings
  final Map<String, double> clientBreakdown = {
    "Mr. Sharma": 5200,
    "Ms. Desai": 3400,
    "Mr. Reddy": 2700,
  };

  // Filters

  // Selected filters
  String selectedFilter = "All"; // Payment status
  String selectedServiceFilter = "All Services"; // Service type
  String selectedDateFilter =
      "All Time"; // Date filter (Today, Week, Month, Custom)

  Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // add alpha value if missing
    }
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    double totalEarnings = earningsHistory.fold(
      0,
      (sum, item) => sum + (item["amount"] as int),
    );
    double lastWeekEarnings = 2800; // Replace with actual previous week
    double growthPercent = ((3200 - lastWeekEarnings) / lastWeekEarnings) * 100;

    double todayEarnings = earningsHistory
        .where(
          (item) =>
              item["date"].day == DateTime.now().day &&
              item["date"].month == DateTime.now().month,
        )
        .fold(0, (sum, item) => sum + (item["amount"] as int));

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          "Earnings",
          style: GoogleFonts.poppins(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1D828E).withOpacity(0.8),
                    Color.fromARGB(255, 50, 189, 117).withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Earnings",
                    style: GoogleFonts.poppins(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: totalEarnings),
                    duration: const Duration(seconds: 1),
                    builder: (context, value, child) => Text(
                      "₹${value.toInt()}",
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Today ₹$todayEarnings | This Week ₹3,200",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),

                  // Calculate weekly growth (example)
                  Row(
                    children: [
                      Icon(
                        growthPercent >= 0
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: growthPercent >= 0 ? Colors.green : Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${growthPercent.abs().toStringAsFixed(1)}% vs last week",
                        style: GoogleFonts.poppins(
                          color: growthPercent >= 0 ? Colors.green : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  // Quick actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Export Button (styled like "Accept")
                      Expanded(
                        child: Container(
                          height: 40,
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
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              splashColor: Colors.white.withOpacity(0.3),
                              highlightColor: Colors.white.withOpacity(0.1),
                              onTap: () async {
                                await exportEarningsPdf();

                                await NotificationService.addNotification(
                                  NotificationItem(
                                    title: "PDF Generated Successfully",
                                    desc:
                                        "Your task report PDF has been created and saved in Downloads.",
                                    time: "Just now",
                                    icon: "check_circle",
                                    typeColor: "0xFF4CAF50", // Green
                                  ),
                                );
                              },

                              child: Center(
                                child: Text(
                                  'Export',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Withdraw Button (styled like "Accept")
                      Expanded(
                        child: Container(
                          height: 40,
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
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              splashColor: Colors.white.withOpacity(0.3),
                              highlightColor: Colors.white.withOpacity(0.1),
                              onTap: () async {
                                // Replace with your real UPI ID and details
                                final upiUri = Uri.parse(
                                  "upi://pay?pa=yourupiid@upi&pn=YourName&tn=Payment&am=1&cu=INR",
                                );

                                try {
                                  await launchUrl(
                                    upiUri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                } catch (e) {
                                  // If failed, try redirecting to PhonePe app or Play Store
                                  final phonePeUri = Uri.parse("phonepe://");
                                  final playStoreUri = Uri.parse(
                                    "https://play.google.com/store/apps/details?id=com.phonepe.app",
                                  );

                                  if (await canLaunchUrl(phonePeUri)) {
                                    await launchUrl(phonePeUri);
                                  } else {
                                    await launchUrl(
                                      playStoreUri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                }
                                // Amount Withdrawn Successfully
                                await NotificationService.addNotification(
                                  NotificationItem(
                                    title: "Amount Withdrawn Successfully",
                                    desc:
                                        "₹1,200 has been transferred to your linked bank account.",
                                    time: "Just now",
                                    icon: "wallet",
                                    typeColor: "0xFF4CAF50", // Green
                                  ),
                                );
                              },

                              child: Center(
                                child: Text(
                                  'Withdraw',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /*onTap: () async {
      // Replace these with your actual account details
      final upiId = "yourupiid@upi";  // Your UPI ID
      final name = "Your Name";        // Name linked to UPI ID
      final note = "Payment Withdrawal"; 
      final amount = 1.0;              // Amount to send

      final upiUri = Uri.parse(
        "upi://pay?pa=$upiId&pn=$name&tn=$note&am=$amount&cu=INR",
      );

      try {
        await launchUrl(
          upiUri,
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        // If PhonePe doesn't respond, fallback to Play Store
        final phonePeUri = Uri.parse("phonepe://");
        final playStoreUri = Uri.parse(
          "https://play.google.com/store/apps/details?id=com.phonepe.app",
        );

        if (await canLaunchUrl(phonePeUri)) {
          await launchUrl(phonePeUri);
        } else {
          await launchUrl(
            playStoreUri,
            mode: LaunchMode.externalApplication,
          );
        }
      }
    },*/
            const SizedBox(height: 24),
            // Earnings Graph
            Container(
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
                  Text(
                    "Earnings Trend",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        backgroundColor: Colors.transparent,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey.withOpacity(0.1),
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 24,

                              getTitlesWidget: (value, meta) {
                                final days = [
                                  "Mon",
                                  "Tue",
                                  "Wed",
                                  "Thu",
                                  "Fri",
                                  "Sat",
                                  "Sun",
                                ];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 9),

                                  child: Text(
                                    days[value.toInt() % 7],
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 38,
                              getTitlesWidget: (value, meta) => Text(
                                "₹${value.toInt()}",
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 300),
                              FlSpot(1, 450),
                              FlSpot(2, 500),
                              FlSpot(3, 400),
                              FlSpot(4, 600),
                              FlSpot(5, 550),
                              //FlSpot(6, 650),
                            ],
                            isCurved: true,
                            color: primaryColor,
                            barWidth: 4,
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor.withOpacity(0.4),
                                  primaryColor.withOpacity(0.05),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) =>
                                  FlDotCirclePainter(
                                    radius: 4,
                                    color: Colors.white,
                                    strokeWidth: 2,
                                    strokeColor: primaryColor,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Service Breakdown Pie Chart
            Container(
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
                  Text(
                    "Earnings by Service",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            centerSpaceRadius: 45,
                            sectionsSpace: 2,
                            startDegreeOffset: -90,
                            sections: serviceBreakdown.entries.map((e) {
                              final index = serviceBreakdown.keys
                                  .toList()
                                  .indexOf(e.key);
                              return PieChartSectionData(
                                color: Colors
                                    .primaries[index % Colors.primaries.length]
                                    .withOpacity(0.85),
                                value: e.value,
                                radius: 60,
                                title: "₹${e.value.toInt()}",
                                titleStyle: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Total",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              "₹${serviceBreakdown.values.reduce((a, b) => a + b).toInt()}",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: serviceBreakdown.keys.map((service) {
                      final index = serviceBreakdown.keys.toList().indexOf(
                        service,
                      );
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors
                                  .primaries[index % Colors.primaries.length]
                                  .withOpacity(0.85),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            service,
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pending / Completed Filters
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Date Filter
                Expanded(
                  child: InkWell(
                    onTap: _showDateFilterSheet,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Date",
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  selectedDateFilter,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              const Icon(Icons.arrow_drop_down, size: 18),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Payment Status Filter
                Expanded(
                  child: InkWell(
                    onTap: _showPaymentFilterSheet,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Payment",
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  selectedFilter,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              const Icon(Icons.arrow_drop_down, size: 18),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Service Filter
                Expanded(
                  child: InkWell(
                    onTap: _showServiceFilterSheet,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Service",
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  selectedServiceFilter,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down, size: 18),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Earnings History List
            Column(
              children: earningsHistory
                  .where((item) {
                    // Payment Status filter
                    bool paymentCheck =
                        selectedFilter == "All" ||
                        item["status"] == selectedFilter;
                    // Service filter
                    bool serviceCheck =
                        selectedServiceFilter == "All Services" ||
                        item["title"] == selectedServiceFilter;
                    // Date filter
                    bool dateCheck = true;
                    if (selectedDateFilter == "Today") {
                      DateTime now = DateTime.now();
                      dateCheck =
                          item["date"].day == now.day &&
                          item["date"].month == now.month &&
                          item["date"].year == now.year;
                    } else if (selectedDateFilter == "This Week") {
                      DateTime now = DateTime.now();
                      DateTime startOfWeek = now.subtract(
                        Duration(days: now.weekday - 1),
                      );
                      DateTime endOfWeek = startOfWeek.add(Duration(days: 6));
                      dateCheck =
                          item["date"].isAfter(
                            startOfWeek.subtract(Duration(days: 1)),
                          ) &&
                          item["date"].isBefore(
                            endOfWeek.add(Duration(days: 1)),
                          );
                    } else if (selectedDateFilter == "This Month") {
                      DateTime now = DateTime.now();
                      dateCheck =
                          item["date"].month == now.month &&
                          item["date"].year == now.year;
                    }
                    return paymentCheck && serviceCheck && dateCheck;
                  })
                  .map(
                    (item) => Padding(
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item["title"],
                                  style: GoogleFonts.poppins(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${item["date"].day}-${item["date"].month}-${item["date"].year} | ${item["client"]}",
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                    horizontal: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: item["status"] == "Paid"
                                        ? Colors.green[200]
                                        : Colors.orange[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    item["status"],
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "₹${item["amount"]}",
                              style: GoogleFonts.poppins(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> exportEarningsPdf() async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (pw.Context context) {
            return [
              pw.Center(
                child: pw.Text(
                  "Earnings Statement",
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.teal700,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text(
                "Generated on: ${DateTime.now().toString().split('.')[0]}",
                style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ["Service", "Client", "Date", "Status", "Amount (₹)"],
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF1D828E),
                ),
                border: pw.TableBorder.all(
                  width: 0.5,
                  color: PdfColors.grey400,
                ),
                cellAlignment: pw.Alignment.centerLeft,
                data: earningsHistory.map((item) {
                  final date = item["date"] as DateTime;
                  return [
                    item["title"],
                    item["client"],
                    "${date.day}-${date.month}-${date.year}",
                    item["status"],
                    item["amount"].toString(),
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "Total Earnings: ₹${earningsHistory.fold(0, (sum, item) => sum + item['amount'] as int)}",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                    color: PdfColors.black,
                  ),
                ),
              ),
            ];
          },
        ),
      );

      // Show print/share dialog
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to export PDF: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDateFilterSheet() {
    _buildFilterSheet(
      title: "Filter by Date",
      options: ["All Time", "Today", "This Week", "This Month", "Custom Range"],
      selectedOption: selectedDateFilter,
      onSelect: (value) {
        setState(() => selectedDateFilter = value);
      },
    );
  }

  void _showPaymentFilterSheet() {
    _buildFilterSheet(
      title: "Filter by Payment Status",
      options: ["All", "Paid", "Pending"],
      selectedOption: selectedFilter,
      onSelect: (value) {
        setState(() => selectedFilter = value);
      },
    );
  }

  void _showServiceFilterSheet() {
    _buildFilterSheet(
      title: "Filter by Service",
      options: ["All Services", "AC Repair", "Plumbing", "Washing Machine"],
      selectedOption: selectedServiceFilter,
      onSelect: (value) {
        setState(() => selectedServiceFilter = value);
      },
    );
  }

  /// 💡 Universal stylish filter sheet builder
  void _buildFilterSheet({
    required String title,
    required List<String> options,
    required String selectedOption,
    required ValueChanged<String> onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Gradient handle
                  Container(
                    width: 50,
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1D828E),
                          Color.fromARGB(255, 50, 189, 117),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1D828E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(thickness: 0.5, height: 1),

                  // Scrollable list of options
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: options.length,
                      padding: const EdgeInsets.only(top: 12),
                      itemBuilder: (context, index) {
                        final option = options[index];
                        final bool isSelected = option == selectedOption;

                        // Example icons based on filter type (customize as needed)
                        IconData icon;
                        if (title.contains("Date")) {
                          icon = Icons.calendar_today_outlined;
                        } else if (title.contains("Payment")) {
                          icon = option == "Paid"
                              ? Icons.check_circle
                              : Icons.schedule;
                        } else {
                          icon = Icons.miscellaneous_services;
                        }

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          transform: isSelected
                              ? (Matrix4.identity()..scale(1.03))
                              : Matrix4.identity(),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF1D828E),
                                      Color.fromARGB(255, 50, 189, 117),
                                    ],
                                  )
                                : null,
                            color: isSelected ? null : Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: isSelected ? 12 : 6,
                                offset: Offset(0, isSelected ? 4 : 3),
                              ),
                            ],
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF1D828E)
                                  : Colors.grey.shade300,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              onSelect(option);
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 16,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        icon,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey[700],
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        option,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
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
