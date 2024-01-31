import 'package:com.example.while_app/view/onboarding_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:com.example.while_app/view/home_screen.dart';
import 'package:com.example.while_app/view/auth/login_screen.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();
    if (firebaseUser != null) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
      //return const OnBoardingScreen();
    }
  }
}
