// ignore: file_names
import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/model/chat_user.dart';

class UserDataProvider with ChangeNotifier {
  final Ref ref;
  late final StreamSubscription<DocumentSnapshot> _userSubscription;
  late final StreamSubscription<QuerySnapshot> _followingSubscription;
  late final StreamSubscription<QuerySnapshot> _followerSubscription;
  bool _isDisposed = false;

  UserDataProvider(this.ref) {
    _initData();
  }

  ChatUser _userData = ChatUser.empty();
  ChatUser? get userData => _userData;

  void _initData() {
    final auth = FirebaseAuth.instance.currentUser;
    if (auth != null) {
      // User data subscription
      _userSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(auth.uid)
          .snapshots()
          .listen((snapshot) {
        _userUpdateListener(snapshot);
      });

      // Following subscription
      _followingSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(auth.uid)
          .collection('following')
          .snapshots()
          .listen(_followingUpdateListener);

      // Follower subscription
      _followerSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(auth.uid)
          .collection('follower')
          .snapshots()
          .listen(_followerUpdateListener);
    }
  }

  void _userUpdateListener(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.exists && !_isDisposed) {
      _userData = ChatUser.fromJson(snapshot.data()!);
      _safeNotifyListeners();
    }
  }

  void _followingUpdateListener(QuerySnapshot snapshot) {
    if (!_isDisposed) {
      int newFollowingCount = snapshot.docs.length;
      if (_userData.following != newFollowingCount) {
        _userData.following = newFollowingCount;
        _safeNotifyListeners();
        updateUserData(
            _userData); // Call updateUserData when following count changes
      }
    }
  }

  void _followerUpdateListener(QuerySnapshot snapshot) {
    if (!_isDisposed) {
      int newFollowerCount = snapshot.docs.length;
      if (_userData.follower != newFollowerCount) {
        _userData.follower = newFollowerCount;
        _safeNotifyListeners();
        updateUserData(
            _userData); // Call updateUserData when following count changes
      }
    }
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _userSubscription.cancel();
    _followingSubscription.cancel();
    _followerSubscription.cancel();
    super.dispose();
  }

  Future<void> updateUserData(ChatUser updatedUser) async {
    final auth = FirebaseAuth.instance.currentUser;
    if (auth != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(auth.uid)
            .update(updatedUser.toJson());
        _userData = updatedUser;
        _safeNotifyListeners();
      } catch (e) {
        log('Error updating user data: $e');
      }
    }
  }

  fetchUserList() {}
}

final userDataProvider =
    ChangeNotifierProvider.autoDispose<UserDataProvider>((ref) {
  log('userDataProvider');
  return UserDataProvider(ref);
});
