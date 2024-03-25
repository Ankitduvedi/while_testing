// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:com.example.while_app/data/model/chat_user.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class FireBaseDataProvider with ChangeNotifier {
//   ChatUser user = ChatUser.empty();
//   // get data => _data;
//   getData() async {
//     final auth = FirebaseAuth.instance.currentUser!;
//     final data = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(auth.uid)
//         .get();
//     user = ChatUser.fromJson(data.data()!);
//     notifyListeners();
//     return user;
//   }
// }

// class ApiServices {
//   final auth = FirebaseAuth.instance.currentUser!;
//   Future<ChatUser> getUsers() async {
//     final snapshot = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(auth.uid)
//         .get();
//     if (snapshot.exists) {
//       return ChatUser.fromJson(snapshot.data()!);
//     } else {
//       throw Exception(snapshot.metadata);
//     }
//   }
// }

// final userProvider = Provider<ApiServices>((ref) => ApiServices());
