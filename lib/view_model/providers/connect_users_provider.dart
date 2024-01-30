import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.example.while_app/resources/components/message/models/chat_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define your ChatUser model

// ConnectUserDataProvider with ChangeNotifier
class ConnectUserDataProvider with ChangeNotifier {
  ChatUser _userData = ChatUser.empty();
  final auth = FirebaseAuth.instance.currentUser!;

  ChatUser? get userData => _userData;

  ConnectUserDataProvider(String id) {
    _initData(id);
  }

  void _initData(String id) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        _userData = ChatUser.fromJson(snapshot.data()!);
        notifyListeners();
      }
    });
  }

  Stream<ChatUser> userDataStream(String id) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return ChatUser.fromJson(snapshot.data()!);
      } else {
        return ChatUser.empty();
      }
    });
  }

  Future<void> updateUserData(ChatUser updatedUser, String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .set(updatedUser.toJson());
      _userData = updatedUser; // Update local data
      notifyListeners(); // Notify listeners of the change
    } catch (e) {
      log('Error updating user data: $e');
      // Handle exceptions
    }
  }
}

// ChangeNotifierProvider for ConnectUserDataProvider
final connectUserDataProvider =
    ChangeNotifierProvider.family<ConnectUserDataProvider, String>((ref, id) {
  return ConnectUserDataProvider(id);
});

// StreamProvider for real-time updates
final connectUserDataStreamProvider =
    StreamProvider.family<ChatUser, String>((ref, id) {
  final provider = ref.watch(connectUserDataProvider(id));
  return provider.userDataStream(id);
});
