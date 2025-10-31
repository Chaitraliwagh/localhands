import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:localhands_app/admin/admin.dart';
import 'package:localhands_app/view/home_screen.dart';
import 'package:localhands_app/view/splash_chaitrali.dart';
import 'package:lottie/lottie.dart';

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

  static const Color _themeStart = Color(0xFF1D828E);
  static const Color _themeEnd = Color(0xFF33C47F);

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
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ✅ Watermark visible on both pages
          Positioned.fill(
            child: Opacity(
              opacity: 0.10,
              child: Image.asset('assets/logo.jpeg', fit: BoxFit.contain),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.05),

                  // Title
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [hexToColor("#1D828E"), hexToColor("#1A237E")],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      "Welcome to LocalHands",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.085,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.3,
                        color: Colors.white, // gradient fills this text
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03),

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

  // 🌿 Get Started Screen
  Widget _buildGetStartedScreen() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      key: const ValueKey('get_started'),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Centered Animation
        SizedBox(
          height: screenHeight * 0.35,
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

        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
          child: Text(
            _slides[_currentPage]['caption']!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.w500,
              color: _themeStart,
            ),
          ),
        ),

        // Get Started button at bottom
        Padding(
          padding: EdgeInsets.only(bottom: screenHeight * 0.07, top: 40),
          child: SizedBox(
            width: screenWidth * 0.55,
            child: _buildGradientButton("Get Started", () {
              setState(() => _showSignIn = true);
            }),
          ),
        ),
      ],
    );
  }

  // 🌿 Login/Signup Form
  Widget _buildGlassForm({required bool isSignUp}) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      key: ValueKey(isSignUp ? 'signup' : 'signin'),
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
          padding: EdgeInsets.all(screenWidth * 0.07),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3), // ✅ flat white
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: _themeStart, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isSignUp ? "Create Account" : "Sign In",
                style: TextStyle(
                  fontSize: screenWidth * 0.065,
                  fontWeight: FontWeight.bold,
                  color: _themeStart,
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              _buildTabBarLogin(isSignUp: isSignUp),
              SizedBox(height: screenHeight * 0.02),
              RichText(
                text: TextSpan(
                  text: isSignUp
                      ? "Already have an account? "
                      : "Don't have an account? ",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: screenWidth * 0.04,
                  ),
                  children: [
                    TextSpan(
                      text: isSignUp ? "Sign In" : "Sign Up",
                      style: TextStyle(
                        color: _themeStart,
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
        SizedBox(height: screenHeight * 0.04),
      ],
    );
  }

  // 🌿 TabBar
  Widget _buildTabBarLogin({required bool isSignUp}) {
    final screenHeight = MediaQuery.of(context).size.height;

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: _themeStart,
              indicatorWeight: 3,
              labelColor: _themeStart,
              unselectedLabelColor: Colors.black54,
              tabs: const [
                Tab(text: "Admin"),
                Tab(text: "Worker"),
                Tab(text: "User"),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          SizedBox(
            height: screenHeight * 0.42,
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

  // 🌿 Login Form per user type
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Widget _singleLoginForm(String type, {required bool isSignUp}) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _themeStart, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildTextField(
              "$type Email",
              Icons.email,
              controller: _emailController,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              "$type Password",
              Icons.lock,
              controller: _passwordController,
              obscure: true,
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

  // 🌿 Button
  Widget _buildGradientButton(String text, VoidCallback onPressed) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: EdgeInsets.zero,
        elevation: 5,
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
          borderRadius: BorderRadius.circular(30),
        ),
        child: Container(
          alignment: Alignment.center,
          constraints: BoxConstraints(
            minWidth: screenWidth * 0.3,
            minHeight: 50,
          ),
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

  // 🌿 TextField
  Widget _buildTextField(
    String hint,
    IconData icon, {
    bool obscure = false,
    TextEditingController? controller,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
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
          borderSide: const BorderSide(color: _themeStart, width: 2),
        ),
      ),
    );
  }
}
