import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
import 'package:com.while.while_app/data/model/chat_user.dart';
import 'package:com.while.while_app/feature/auth/screens/login_screen.dart';
import 'package:com.while.while_app/feature/auth/screens/register_screen.dart';
import 'package:com.while.while_app/feature/wrapper/update.dart';
import 'package:com.while.while_app/home_screen.dart';
import 'package:com.while.while_app/feature/intro_screens/onboarding_screen.dart';
import 'package:com.while.while_app/providers/apis.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/constant.dart';
// Import other necessary packages and files

class Wrapper extends ConsumerStatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  ConsumerState<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends ConsumerState<Wrapper> {
  ChatUser? userModel;

  void getData(User data) async {
    userModel =
        await ref.read(authControllerProvider.notifier).getUserData(data.uid);
    log(userModel!.email);
    ref.read(userProvider.notifier).update((state) => userModel);
    //so that ui rebuilds
    setState(() {});
  }

  @override
  void initState() {
    // final firebaseUser1 = ref.watch(authStateChangeProvider);
    // TODO: implement initState
    intializeWhile();
    super.initState();
  }

  intializeWhile() async {
    final versionNumber = await getAppVersion();
    final reviewVersionNumber = await getAppReviewVersion();
    print(
        "version number is $versionNumber and review version number is $reviewVersionNumber");
    if (versionNumber != version && reviewVersionNumber != version) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => UpdateAppScreen()));
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    log("wrapper");
    // check AuthState of user
    final firebaseUser = ref.watch(authStateChangeProvider);
    // toggle for onboard on login screen
    final toggle = ref.watch(toggleStateProvider);
    print("toggle is $toggle");
    final user = ref.read(userProvider);
    // Directly return the widget from firebaseUser.when

    // Logger().d(versionNumber);

    return firebaseUser.when(
      data: (firedata) {
        //user firebase data

        if (firedata != null) {
          //user provider data
          if (user != null) {
            print("user is ${user.name}");
            ref.watch(apisProvider).getFirebaseMessagingToken(user.id);
            return const HomeScreen();
          } else {
            //function that will trigger provider update
            getData(firedata);
          }
        }
        // Future.delayed(Duration(seconds: 2), () {
        return toggle == 0
            ? const OnBoardingScreen()
            : toggle == 1
                ? const LoginScreen()
                : const SignUpScreen();
        // });
        return Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
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

Future<String> getAppVersion() async {
  try {
    final firestore = FirebaseFirestore.instance;
    final data = firestore
        .collection("versions")
        .doc(Platform.isAndroid ? "Android" : "iOS");
    final document = await data.get();
    //print(document);
    return document["version"].toString();
  } catch (e) {
    return version;
  }
}

Future<String> getAppReviewVersion() async {
  try {
    final firestore = FirebaseFirestore.instance;
    final platform = (Platform.isAndroid ? "Android" : "iOS");
    final data = firestore.collection("review_version").doc(platform);
    final document = await data.get();

    if (document.exists) {
      return document.data()!["version"].toString();
    } else {
      throw Exception("Document not found");
    }
  } catch (e) {
    // Handle exceptions gracefully

    return "Unknown"; // Return a default value in case of error
  }
}
