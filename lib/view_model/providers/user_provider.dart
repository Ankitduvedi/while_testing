import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.example.while_app/resources/components/message/models/chat_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserDataProvider with ChangeNotifier {
  ChatUser _userData = ChatUser.empty();
  final auth = FirebaseAuth.instance.currentUser!;

  ChatUser? get userData => _userData;

  UserDataProvider() {
    _initData();
  }

  void _initData() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(auth.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        _userData = ChatUser.fromJson(snapshot.data()!);
        notifyListeners();
      }
    });

    // Listen to changes in the 'following' subcollection
    FirebaseFirestore.instance
        .collection('users')
        .doc(auth.uid)
        .collection('following')
        .snapshots()
        .listen((snapshot) async {
      // If there's a change in the count, update the user data
      if (snapshot.docChanges.isNotEmpty) {
        _userData.following = snapshot.docs.length;
        log('updated following');
        await updateUserData(_userData);
      }
    });

    // Listen to changes in the 'follower' subcollection
    FirebaseFirestore.instance
        .collection('users')
        .doc(auth.uid)
        .collection('follower')
        .snapshots()
        .listen((snapshot) async {
      // If there's a change in the count, update the user data
      if (snapshot.docChanges.isNotEmpty) {
        _userData.follower = snapshot.docs.length;
        await updateUserData(_userData);
      }
    });
  }

  Future<void> updateUserData(ChatUser updatedUser) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(auth.uid)
          .set(updatedUser.toJson());
      _userData = updatedUser; // Update local data
      notifyListeners(); // Notify listeners of the change
    } catch (e) {
      log('Error updating user data: $e');
      // Handle exceptions
    }
  }
}

final userDataProvider = ChangeNotifierProvider<UserDataProvider>((ref) {
  return UserDataProvider();
});
