import 'dart:developer';

import 'package:com.while.while_app/core/utils/utils.dart';

import 'package:com.while.while_app/data/model/chat_user.dart';
import 'package:com.while.while_app/feature/auth/repository/firebase_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

//user data provider
final userProvider = StateProvider<ChatUser?>((ref) {
  return null;
});
final isNewUserProvider = StateProvider<bool>((ref) {
  return false; // Initial value is false
});
//user authStateProvider
final authControllerProvider =
    StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(
      authRepository: ref.watch(authRepositoryProvider), ref: ref);
});

final toggleStateProvider = StateProvider<int>((ref) {
  return 0; // Initial value is false
});

final toggleSearchStateProvider = StateProvider<int>((ref) {
  return 0; // Initial value is false
});

final authStateChangeProvider = StreamProvider((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.authStateChange;
});
final getUserDataProvider = StreamProvider.family((ref, String uid) {
  final authController = ref.watch(authControllerProvider.notifier);

  // Create a StreamController to convert the Future into a Stream
  final controller = StreamController<ChatUser>();

  // Call getUserData and add the result to the stream
  final userData = authController.getUserData(uid);
  controller.add(userData);
  controller.close(); // Close the stream after adding the data

  return controller.stream;
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;
  AuthController({required AuthRepository authRepository, required Ref ref})
      : _authRepository = authRepository,
        _ref = ref,
        super(false); // to tell isLoading state

  Stream<User?> get authStateChange => _authRepository.authStateChange;
  ChatUser getUserData(String uid) => _authRepository.getUserData(uid);

  void signInWithGoogle(BuildContext context) async {
    state = true;
    // final isNewuser = await _authRepository.checkisNewuser();
    final user = await _authRepository.signInWithGoogle(_ref);
    state = false;
    log("setting user data to userProv");
    user.fold((l) => Utils.snackBar(l.message, context),
        (r) => _ref.read(userProvider.notifier).update((state) => r));
    ChatUser? userdata = _ref.read(userProvider.notifier).state;
    _ref
        .read(isNewUserProvider.notifier)
        .update((state) => userdata!.isnewUser ?? false);
    _ref
        .read(isNewUserProvider.notifier)
        .update((state) => userdata!.isnewUser ?? false);
  }

  void signOut(BuildContext context) async {
    state = true;
    final response = await _authRepository.signout();
    state = false;
    response.fold((l) => Utils.snackBar(l.message, context), (r) => null);
  }

  void deleteAccount(BuildContext context) async {
    state = true;
    final response = await _authRepository.deleteAccount();
    state = false;
    response.fold((l) => Utils.snackBar(l.message, context), (r) => null);
  }

  void getSnapshot() {
    _authRepository.getSnapshot();
  }

  void loginWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    state = true;
    final user = await _authRepository.loginWithEmailAndPassword(
        email, password, context);
    user.fold((l) => Utils.snackBar(l.message, context),
        (r) => _ref.read(userProvider.notifier).update((state) => r));
    state = false;
  }

  void signInWithEmailAndPassword(
      String email, String password, String name, BuildContext context) async {
    state = true;
    final response = await _authRepository.signInWithEmailAndPassword(
        email, password, name, context);

    response.fold((l) => Utils.snackBar(l.message, context),
        (r) => _ref.read(userProvider.notifier).update((state) => r));

    state = false;
  }

  void updateUserProfile(ChatUser user) {
    _ref.read(userProvider.notifier).update((state) => user);
  }
}
