import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/core/enums/firebase_providers.dart';
import 'package:com.while.while_app/data/model/failure.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:com.while.while_app/providers/apis.dart';
import 'package:com.while.while_app/data/model/chat_user.dart';
import 'package:fpdart/fpdart.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
      firestore: ref.read(fireStoreProvider),
      auth: ref.read(authProvider),
      googleSignIn: ref.read(googleSignInProvier),
      ref: ref);
});

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final Ref _ref;
  AuthRepository(
      {required FirebaseFirestore firestore,
      required FirebaseAuth auth,
      required GoogleSignIn googleSignIn,
      required Ref ref})
      : _firestore = firestore,
        _auth = auth,
        _googleSignIn = googleSignIn,
        _ref = ref;

  Future<Either<Failure, ChatUser>> signInWithEmailAndPassword(
      String email, String password, String name, BuildContext context) async {
    try {
      log("registering with email and password");

      final creds = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      log("uid is ${creds.user!.uid}");
      final time = DateTime.now().millisecondsSinceEpoch.toString();
      ChatUser userModel;
      userModel = ChatUser(
          lives: 0,
          easyQuestions: 0,
          id: creds.user!.uid,
          hardQuestions: 0,
          mediumQuestions: 0,
          name: name,
          email: email.toString(),
          about: '',
          image:
              'https://firebasestorage.googleapis.com/v0/b/while-2.appspot.com/o/profile_pictures%2FKIHEXrUQrzcWT7aw15E2ho6BNhc2.jpg?alt=media&token=1316edc6-b215-4655-ae0d-20df15555e34',
          createdAt: time,
          isOnline: 1,
          lastActive: time,
          pushToken: '',
          dateOfBirth: '',
          gender: '',
          phoneNumber: '',
          place: '',
          profession: '',
          designation: 'Member',
          follower: 0,
          following: 0,
          isContentCreator: 0,
          isApproved: 0,
          isCounsellor: 0,
          isCounsellorVerified: 0);
      log('/////as////${_auth.currentUser!.uid}');
      await createNewUser(userModel);
      return right(userModel);
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  Future<Either<Failure, ChatUser>> loginWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      // Attempt to log in.
      log("logging with email and password");
      final credentials = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      // Get UID of the logged-in user.
      final String uid = credentials.user!.uid;

      // Fetch user data from Firestore using UID.
      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        return left(Failure(message: "No account exists for this user."));
      } else {
        final ChatUser user =
            ChatUser.fromJson(userDoc.data() as Map<String, dynamic>);
        return right(user);
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Auth exceptions.
      log(e.toString());
      return left(
          Failure(message: e.message ?? "An error occurred during login."));
    } catch (e) {
      // Handle any other exceptions.
      return left(Failure(message: e.toString()));
    }
  }

  Future<Either<Failure, String>> signout() async {
    try {
      _ref.read(apisProvider).updateActiveStatus(false);
      await _googleSignIn.signOut();
      await _auth.signOut();
      return right(r"Successfully signed out.");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        log("Network error: ${e.toString()}");
        return left(Failure(message: "No internet connection available."));
      } else {
        log("FirebaseAuth error: ${e.toString()}");
        return left(Failure(message: "Authentication error: ${e.message}"));
      }
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  Future<Either<Failure, String>> deleteAccount() async {
    try {
      _ref.read(apisProvider).updateActiveStatus(false);
      await _auth.currentUser!.delete();
      return right("Account deleted successfully");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        log("Network error: ${e.toString()}");
        return left(Failure(message: "No internet connection available."));
      } else {
        log("FirebaseAuth error: ${e.toString()}");
        return left(Failure(message: "Authentication error: ${e.message}"));
      }
    } catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  Future<DocumentSnapshot> getSnapshot() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .get();
    return snapshot;
  }

  Future<Either<Failure, ChatUser>> signInWithGoogle() async {
    try {
      // Assumed _googleSignIn and _auth are initialized
      await GoogleSignIn().signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      if (googleAuth?.accessToken != null && googleAuth?.idToken != null) {
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );

        UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        log("sign in successfully");

        if (userCredential.user != null) {
          final User newUser = userCredential.user!;
          ChatUser userModel;

          if (userCredential.additionalUserInfo!.isNewUser) {
            log("new user");
            // Define userModel for a new user
            final time = DateTime.now().millisecondsSinceEpoch.toString();
            userModel = ChatUser(
                lives: 0,
                easyQuestions: 0,
                id: newUser.uid,
                hardQuestions: 0,
                mediumQuestions: 0,
                name: newUser.displayName.toString(),
                email: newUser.email.toString(),
                about: 'Hey I am ${newUser.displayName}',
                image:
                    'https://firebasestorage.googleapis.com/v0/b/while-2.appspot.com/o/profile_pictures%2FKIHEXrUQrzcWT7aw15E2ho6BNhc2.jpg?alt=media&token=1316edc6-b215-4655-ae0d-20df15555e34',
                createdAt: time,
                isOnline: 1,
                lastActive: time,
                pushToken: '',
                dateOfBirth: '',
                gender: '',
                phoneNumber: '',
                place: '',
                profession: '',
                designation: 'Member',
                follower: 0,
                following: 0,
                isContentCreator: 0,
                isApproved: 0,
                isCounsellor: 0,
                isCounsellorVerified: 0);
            await createNewUser(
                userModel); // Ensure this is awaited if asynchronous
            log("success new user");
          } else {
            userModel = await getUserData(newUser.uid)
                .first; // Assume this fetches the user correctly
            log("existing user");
          }
          return right(userModel); // Return userModel instead of newUser
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        log("Network error: ${e.toString()}");
        return left(Failure(message: "No internet connection available."));
      } else {
        log("FirebaseAuth error: ${e.toString()}");
        return left(Failure(message: "Authentication error: ${e.message}"));
      }
    } catch (e) {
      log(e.toString());
      // Log any other exceptions
      if (e is PlatformException) {
        return left(Failure(message: "Try checking your network connection"));
      } else {
        return left(Failure(message: "Error  $e"));
      }
    }
    // Handle case where Google sign-in was cancelled or failed before returning
    return left(Failure(message: "Google sign-in failed."));
  }

  Future<void> createNewUser(ChatUser newUser) async {
    log(' users given id is /: ${newUser.name}');
    log(newUser.id);
    await _firestore.collection('users').doc(newUser.id).set(newUser.toJson());
  }

  Stream<ChatUser> getUserData(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map(
        (event) => ChatUser.fromJson(event.data() as Map<String, dynamic>));
  }

  Stream<User?> get authStateChange =>
      _ref.read(authProvider).authStateChanges();
}
