import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/model/chat_user.dart';
import '../feature/auth/controller/auth_controller.dart';
import 'draft_method.dart';

class UserDataProvider with ChangeNotifier {
  String UsersTable = 'users';
  String coluid = 'uid';
  final Ref ref;

  // late final StreamSubscription<DocumentSnapshot> _userSubscription;
  // late final StreamSubscription<QuerySnapshot> _followingSubscription;
  // late final StreamSubscription<QuerySnapshot> _followerSubscription;
  bool _isDisposed = false;

  UserDataProvider(this.ref) {
    _initData();
  }

  ChatUser _userData = ChatUser.empty();

  ChatUser? get userData => _userData;

  Future<void> _initData() async {
    log('userdataprovider init function called');

    final auth = FirebaseAuth.instance.currentUser;

    if (auth != null) {
      try {
        print("called");
        ChatUser user = await fetchUser(auth.uid);
        print("userdata is ${user.toJson()}");
        if (user.id == null || user.id == '') {
          print("entered");
          user = await fetchUserFirebase();
          _userData = user;
          ref.read(userProvider.notifier).update((state) => user);
          setUserData(user);
        } else {
          _userData = user;
          ref.read(userProvider.notifier).update((state) => user);
        }
        ;
      } catch (e) {
        print(" error is ${e.toString()}");
      }
    }
  }

  Future<ChatUser> fetchUserFirebase() async {
    final auth = FirebaseAuth.instance.currentUser;
    ChatUser user = ChatUser.empty();
    final docRef =
        FirebaseFirestore.instance.collection("users").doc(auth?.uid);
    docRef.get().then((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      user = ChatUser.fromJson(data);
    });

    _userData = user;
    return user;
  }

  void _userUpdateListener(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.exists && !_isDisposed) {
      _userData = ChatUser.fromJson(snapshot.data()!);
      _safeNotifyListeners();
    }
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    // _userSubscription.cancel();
    // _followingSubscription.cancel();
    // _followerSubscription.cancel();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> getUserMap() async {
    var result;
    try {
      final database1 = await DatabaseHelper().database;
      result = await database1!.query(
        UsersTable,
      );

      notifyListeners();
    } catch (e) {
      print("err is ${e.toString()}");
    }
    return result;
  }

  Future<ChatUser> fetchUser(String uid) async {
    var noteMapList = await getUserMap();
    int count = noteMapList.length;
    ChatUser user = ChatUser.empty();

    for (int i = 0; i < count; i++) {
      if (noteMapList[i]['id'] == uid) user = ChatUser.fromJson(noteMapList[i]);
    }
    _userData = user;
    return user;
  }

  Future<ChatUser> setUserData(ChatUser newUser) async {
    final db = await DatabaseHelper().database;
    await db!.insert(
      UsersTable,
      newUser.toJson(),
    );
    _userData = newUser;
    return newUser;
  }

  Future<void> updateUserData(ChatUser updatedUser) async {
    final auth = FirebaseAuth.instance.currentUser;
    if (auth != null) {
      try {
        final db = await DatabaseHelper().database;
        int result = await db!.update(
          UsersTable,
          updatedUser.toJson(),
          where: 'id = ?',
          whereArgs: [updatedUser.id],
        );

        ref.read(userProvider.notifier).update((state) => updatedUser);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(auth.uid)
            .update(updatedUser.toJson());

        _userData = updatedUser;
        _safeNotifyListeners();
      } catch (e) {
        log('Error updating user data: $e');
      }
    } else {
      print("enter");
    }
  }
}

final userDataProvider =
    ChangeNotifierProvider.autoDispose<UserDataProvider>((ref) {
  log('userDataProvider');
  return UserDataProvider(ref);
});
