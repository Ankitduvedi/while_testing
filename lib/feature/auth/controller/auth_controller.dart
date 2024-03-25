import 'dart:developer';

import 'package:com.example.while_app/data/model/chat_user.dart';
import 'package:com.example.while_app/feature/auth/repository/firebase_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

//user data provider
final userProvider = StateProvider<ChatUser?>((ref) {
  return null;
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
  return authController.getUserData(uid);
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;
  AuthController({required AuthRepository authRepository, required Ref ref})
      : _authRepository = authRepository,
        _ref = ref,
        super(false); // to tell isLoading state

  Stream<User?> get authStateChange => _authRepository.authStateChange;

  Stream<ChatUser> getUserData(String uid) => _authRepository.getUserData(uid);

  void signInWithGoogle(BuildContext context) async {
    state = true;
    final user = await _authRepository.signInWithGoogle();
    state = false;
    log("setting user data to userProv");
    user.fold((l) => SnackBar(content: Text(l.message)),
        (r) => _ref.read(userProvider.notifier).update((state) => r));
  }

  void signOut() {
    _authRepository.signout();
  }

  void deleteAccount() {
    _authRepository.deleteAccount();
  }

  void getSnapshot() {
    _authRepository.getSnapshot();
  }

  void loginWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    state = true;
    final user = await _authRepository.loginWithEmailAndPassword(
        email, password, context);
    user.fold((l) => SnackBar(content: Text(l.message)),
        (r) => _ref.read(userProvider.notifier).update((state) => r));
    state = false;
  }

  void signInWithEmailAndPassword(
      String email, String password, String name, BuildContext context) async {
    state = true;
    final response = await _authRepository.signInWithEmailAndPassword(
        email, password, name, context);
    response.fold((l) => SnackBar(content: Text(l.message)),
        (r) => const SnackBar(content: Text("Successfully signed in")));
    state = false;
  }
}
