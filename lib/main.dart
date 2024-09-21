import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:yolo/screens/bottom_navigation_screen/bottom_nav_bar.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyDBnWfHSVqVRmbWBfmYelW_8jjeLp80cBI',
      appId: '1:191360340248:android:20c06a5e62d5dd0cf8ce6d',
      messagingSenderId: '191360340248',
      projectId: 'roadcheck2024-eccb6',
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BottomNavigationScreen(),
    );
  }
}



