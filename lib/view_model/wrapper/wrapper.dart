import 'package:com.example.while_app/view/auth/register_screen.dart';
import 'package:com.example.while_app/view/onboarding_screen.dart';
import 'package:com.example.while_app/view_model/providers/auth_provider.dart';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:com.example.while_app/view/home_screen.dart';
import 'package:com.example.while_app/view/auth/login_screen.dart';

class Wrapper extends ConsumerWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseUser = context.watch<User?>();
    final toggle = ref.watch(toggleStateProvider);
    log('login // $toggle');
    if (firebaseUser != null) {
      log('home');
      return const HomeScreen();
    } else {
      log('login');
      //return const LoginScreen();
      return toggle == 0
          ? const OnBoardingScreen()
          : toggle == 1
              ? const LoginScreen()
              : SignUpScreen();
      //return const OnBoardingScreen();
    }
  }
}
