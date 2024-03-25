// ignore_for_file: unused_field

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.example.while_app/core/enums/firebase_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepository(firestore: ref.read(fireStoreProvider), auth: ref.read(authProvider), ref: ref);
});
class FeedRepository
{
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Ref _ref;

  FeedRepository({required FirebaseFirestore firestore, required FirebaseAuth auth, required Ref ref}) : _firestore = firestore, _auth = auth, _ref = ref;

  


}