import 'package:flutter/material.dart';
import 'package:localhands_app/view/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyB_5Skgeb4VnsT4DjzxPOcSjKLLXlive74",
      appId: "1:589199031079:android:7eedbadd14ea3935368702",
      messagingSenderId: "589199031079",
      projectId: "localhands-6a37a",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LocalHands',
      theme: ThemeData(primarySwatch: Colors.brown),
      home: const SplashScreen(),
    );
  }
}
