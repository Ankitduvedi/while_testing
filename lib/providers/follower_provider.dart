import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/data/model/chat_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FollowerProvider with ChangeNotifier {
  ChatUser _userData = ChatUser.empty();
  final auth = FirebaseAuth.instance.currentUser!;

  ChatUser? get userData => _userData;

  FollowerProvider(String userId) {
    _initData(userId);
  }

  void _initData(String userId) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        _userData = ChatUser.fromJson(snapshot.data()!);
        notifyListeners();
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

final userDataProvider = ChangeNotifierProvider<FollowerProvider>((ref) {
  return FollowerProvider('');
});