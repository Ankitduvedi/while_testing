// import 'dart:developer';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:com.while.while_app/core/secure_storage/saving_data.dart';
// import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
// import 'package:com.while.while_app/data/model/chat_user.dart';
// import 'package:com.while.while_app/feature/auth/screens/login_screen.dart';
// import 'package:com.while.while_app/feature/auth/screens/register_screen.dart';
// import 'package:com.while.while_app/feature/intro_screens/onboarding_screen.dart';
// import 'package:com.while.while_app/providers/apis.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:go_router/go_router.dart';

// import '../../core/constant.dart';
// // Import other necessary packages and files

// class Wrapper extends ConsumerStatefulWidget {
//   const Wrapper({Key? key}) : super(key: key);

//   @override
//   ConsumerState<Wrapper> createState() => _WrapperState();
// }

// class _WrapperState extends ConsumerState<Wrapper> {
//   ChatUser? userModel;

//   void getData(User data) async {
//     userModel = ref.read(authControllerProvider.notifier).getUserData(data.uid);
//     log(userModel!.email);
//     // ref.read(userProvider.notifier).update((state) => userModel);
//     //so that ui rebuilds
//     log("setting the state");
//     // setState(() {});
//   }

//   @override
//   void initState() {
//     intializeWhile();
//     super.initState();
//   }

//  

 
// 