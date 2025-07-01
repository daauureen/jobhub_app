// lib/screens/common/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  Future<void> checkAuth() async {
  User? user = FirebaseAuth.instance.currentUser;

  await Future.delayed(Duration(milliseconds: 100)); // (опционально)

  if (user != null) {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!userDoc.exists || userDoc['role'] == '') {
        Navigator.pushReplacementNamed(context, '/select_role');
      } else if (userDoc['role'] == 'jobseeker') {
        Navigator.pushReplacementNamed(context, '/jobseeker_home');
      } else if (userDoc['role'] == 'employer') {
        Navigator.pushReplacementNamed(context, '/employer_home');
      }
    });
  } else {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
