import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final toggleStateProvider = StateProvider<int>((ref) {
  return 0; // Initial value is false
});
final toggleSearchStateProvider = StateProvider<int>((ref) {
  log('toggleSearchStateProvider');
  return 0; // Initial value is false
});

final currentUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});
