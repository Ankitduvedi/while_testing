import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final fireStoreProvider = Provider((ref) => FirebaseFirestore.instance);
final authProvider = Provider((ref) => FirebaseAuth.instance);
final googleSignInProvier = Provider((ref) => GoogleSignIn());
final firebaseStorageProvider = Provider((ref) => FirebaseStorage.instance);
final firebaseMessagingProvider = Provider((ref) => FirebaseMessaging.instance);