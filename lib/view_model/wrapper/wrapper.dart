import 'dart:developer';
import 'package:com.example.while_app/feature/auth/controller/auth_controller.dart';
import 'package:com.example.while_app/data/model/chat_user.dart';
import 'package:com.example.while_app/feature/auth/screens/login_screen.dart';
import 'package:com.example.while_app/feature/auth/screens/register_screen.dart';
import 'package:com.example.while_app/view/home_screen.dart';
import 'package:com.example.while_app/view/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Import other necessary packages and files

class Wrapper extends ConsumerStatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  ConsumerState<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends ConsumerState<Wrapper> {
  ChatUser? userModel;

  void getData(User data) async {
    userModel = await ref
        .read(authControllerProvider.notifier)
        .getUserData(data.uid)
        .first;
    log(userModel!.email);
    ref.read(userProvider.notifier).update((state) => userModel);
    //so that ui rebuilds
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    log("wrapper");
    // check AuthState of user
    final firebaseUser = ref.watch(authStateChangeProvider);
    // toggle for onboard on login screen
    final toggle = ref.watch(toggleStateProvider);
    final user = ref.read(userProvider);
    // Directly return the widget from firebaseUser.when
    return firebaseUser.when(
      data: (firedata) {
        //user firebase data
        if (firedata != null) {
          //user provider data
          if (user != null) {
            return const HomeScreen();
          } else {
            //function that will trigger provider update
            getData(firedata);
          }
        }
        return toggle == 0
            ? const OnBoardingScreen()
            : toggle == 1
                ? const LoginScreen()
                : const SignUpScreen();
      },
      error: (error, stackTrace) {
        log("error: $error");
        return Scaffold(
          body: Center(child: Text('Error: $error')),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
