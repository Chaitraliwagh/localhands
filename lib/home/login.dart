import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:localhands_app/admin/admin.dart';
import 'package:localhands_app/view/splash_chaitrali.dart';
import 'package:lottie/lottie.dart';
import 'package:localhands_app/home/home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _showSignUp = false;
  bool _showSignIn = false;

  late TabController _tabController;

  final List<Map<String, String>> _slides = [
    {
      'file': 'assets/electrician.json',
      'caption': 'Find trusted local service providers near you',
    },
    {
      'file': 'assets/painter.json',
      'caption': 'Book professionals instantly — anytime, anywhere',
    },
    {
      'file': 'assets/plumber.json',
      'caption': 'Fast, reliable & affordable services at your doorstep',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.delayed(const Duration(seconds: 3), _autoSlide);
  }

  void _autoSlide() {
    if (!mounted || _showSignUp || _showSignIn) return;
    int nextPage = (_currentPage + 1) % _slides.length;
    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage = nextPage);
    Future.delayed(const Duration(seconds: 3), _autoSlide);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // --- Subtle watermark logo background ---
          Opacity(
            opacity: 0.08,
            child: Center(
              child: Image.asset(
                'assets/logo.jpeg',
                width: screenWidth * 0.9,
                height: screenWidth * 0.9,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // --- Gradient Header with Lottie animations ---
                  Container(
                    width: double.infinity,
                    height: screenHeight * 0.32,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1D828E), Color(0xFF33C47F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background wave animation
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.2,
                            child: Lottie.asset(
                              'assets/Hashtag Loader.json',
                              fit: BoxFit.cover,
                              repeat: true,
                            ),
                          ),
                        ),
                        // Floating animation
                        Positioned(
                          top: screenHeight * 0.05,
                          child: Lottie.asset(
                            'assets/help.json',
                            height: screenHeight * 0.15,
                          ),
                        ),
                        // Welcome text
                        Positioned(
                          bottom: screenHeight * 0.05,
                          child: Column(
                            children: [
                              Text(
                                "Welcome to LocalHands",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.08,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                  color: Colors.white,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black45,
                                      blurRadius: 8,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Text(
                                "Empowering Local Connections 🤝",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  // --- Main Content (Animated Switcher) ---
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: _showSignUp
                        ? _buildGlassForm(isSignUp: true)
                        : _showSignIn
                        ? _buildGlassForm(isSignUp: false)
                        : _buildGetStartedScreen(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- Get Started Screen --------------------
  Widget _buildGetStartedScreen() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      key: const ValueKey('get_started'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: screenHeight * 0.3,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _slides.length,
            itemBuilder: (context, index) => Lottie.asset(
              _slides[index]['file']!,
              key: ValueKey(_slides[index]['file']),
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        Text(
          _slides[_currentPage]['caption']!,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1D828E),
          ),
        ),
        SizedBox(height: screenHeight * 0.04),
        SizedBox(
          width: screenWidth * 0.5,
          child: _buildGradientButton("Get Started", () {
            setState(() {
              _showSignIn = true;
            });
          }),
        ),
      ],
    );
  }

  // -------------------- Glass Form --------------------
  Widget _buildGlassForm({required bool isSignUp}) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: screenHeight * 0.02,
          ),
          child: Container(
            padding: EdgeInsets.all(screenWidth * 0.05),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: const Color(0xFF1D828E), width: 2),
            ),
            constraints: BoxConstraints(
              maxWidth: 500,
              minHeight: screenHeight * 0.35,
              maxHeight: screenHeight * 0.75,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isSignUp ? "Create Account" : "Sign In",
                  style: TextStyle(
                    fontSize: screenWidth * 0.07,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D828E),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                _buildTabBarLogin(isSignUp: isSignUp),
                SizedBox(height: screenHeight * 0.02),
                RichText(
                  text: TextSpan(
                    text: isSignUp
                        ? "Already have an account? "
                        : "Don't have an account? ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: screenWidth * 0.04,
                    ),
                    children: [
                      TextSpan(
                        text: isSignUp ? "Sign In" : "Sign Up",
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            setState(() {
                              _showSignUp = !isSignUp;
                              _showSignIn = isSignUp;
                            });
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------- TabBar --------------------
  Widget _buildTabBarLogin({required bool isSignUp}) {
    final screenHeight = MediaQuery.of(context).size.height;

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF1D828E),
              indicatorWeight: 3,
              labelColor: const Color(0xFF1D828E),
              unselectedLabelColor: Colors.black,
              tabs: const [
                Tab(text: "Admin"),
                Tab(text: "Worker"),
                Tab(text: "User"),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          SizedBox(
            height: screenHeight * 0.35,
            child: TabBarView(
              controller: _tabController,
              children: [
                _singleLoginForm("Admin", isSignUp: isSignUp),
                _singleLoginForm("Worker", isSignUp: isSignUp),
                _singleLoginForm("User", isSignUp: isSignUp),
              ],
            ),
          ),
        ],
      ),
    );
  }

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // -------------------- Single Login Form --------------------
  Widget _singleLoginForm(String type, {required bool isSignUp}) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.04),
        constraints: BoxConstraints(maxHeight: screenHeight * 0.5),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF1D828E), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTextField(
              "$type Email",
              Icons.email,
              controller: _emailController,
              transparent: true,
            ),

            _buildTextField(
              "$type Password",
              Icons.lock,
              controller: _passwordController,
              obscure: true,
              transparent: true,
            ),

            SizedBox(height: screenHeight * 0.02),
            _buildGradientButton(
              isSignUp ? "Sign Up" : "Sign In as $type",
              () async {
                try {
                  final email = _emailController.text.trim();
                  final password = _passwordController.text.trim();

                  if (email.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please fill in all fields"),
                      ),
                    );
                    return;
                  }

                  if (isSignUp) {
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                  } else {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                  }

                  // Navigate after successful login/signup
                  if (type == "Admin") {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LocalHandsAdminApp(),
                      ),
                    );
                  } else if (type == "User") {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  } else if (type == "Worker") {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SplashScreen(),
                      ),
                    );
                  }
                } on FirebaseAuthException catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.message ?? "Authentication failed"),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- Gradient Button --------------------
  Widget _buildGradientButton(String text, VoidCallback onPressed) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ElevatedButton(
      onPressed: onPressed,
      style:
          ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              vertical: screenWidth * 0.04,
              horizontal: screenWidth * 0.1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 5,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.black45,
          ).copyWith(
            backgroundColor: MaterialStateProperty.resolveWith<Color?>(
              (states) => null,
            ),
          ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1D828E), Color(0xFF33C47F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Container(
          alignment: Alignment.center,
          constraints: BoxConstraints(minWidth: screenWidth * 0.3),
          child: Text(
            text,
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // -------------------- TextField --------------------
  Widget _buildTextField(
    String hint,
    IconData icon, {
    bool obscure = false,
    bool transparent = false,
    TextEditingController? controller,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: transparent
            ? Colors.transparent
            : Colors.grey[100]?.withOpacity(0.8),
        prefixIcon: Icon(icon, color: Colors.grey[700]),
        contentPadding: EdgeInsets.symmetric(
          vertical: screenWidth * 0.04,
          horizontal: screenWidth * 0.04,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1D828E), width: 2),
        ),
      ),
    );
  }
}

// -------------------- AdminApp --------------------
class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Admin Dashboard')));
  }
}
