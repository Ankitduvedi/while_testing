import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:com.example.while_app/resources/components/message/apis.dart';
import 'package:com.example.while_app/data/model/chat_user.dart';
// import 'package:while_app/utils/snackbar.dart';
import '../utils/utils.dart';

class FirebaseAuthMethods {
  final FirebaseAuth _auth;
  FirebaseAuthMethods(this._auth);

  User get user => _auth.currentUser!;
  ChatUser newUser = ChatUser.empty();

  Stream<User?> get authState => FirebaseAuth.instance.authStateChanges();

  Future<bool> signInWithEmailAndPassword(
      String email, String password, String name, BuildContext context) async {
    try {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) async {
        newUser.email = email;
        newUser.name = name;
        newUser.about = 'Hey I My name is $name , connect me at $email';
        log('/////as////${_auth.currentUser!.uid}');
        //await _auth.currentUser!.sendEmailVerification();
        //Utils.snackBar("Verification mail sent", context);
        await APIs.createNewUser(newUser);
        return true;
      });
      return true;
    } on FirebaseAuthException catch (e) {
      Utils.snackBar(e.message!, context);
      return false;
    }
  }

  Future loginInWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      if (!_auth.currentUser!.emailVerified) {
        Utils.snackBar("User not verified mail", context);
        //await _auth.currentUser!.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      Utils.snackBar(e.message!, context);
    }
  }

  Future signout(BuildContext context) async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      Utils.snackBar(e.message!, context);
    }
  }
  Future deleteAccount(BuildContext context) async
  {
    try {
      await _auth.currentUser!.delete();
    } catch (error) {
      print("Error deleting account: $error");
      
    }
  }

  Future<DocumentSnapshot> getSnapshot() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .get();
    return snapshot;
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Sign out to force account selection prompt
      await GoogleSignIn().signOut();
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      if (googleAuth?.accessToken != null && googleAuth?.idToken != null) {
        final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);

        UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        if (userCredential.user != null) {
          if (userCredential.additionalUserInfo!.isNewUser) {
            newUser.email = userCredential.user!.email!;
            newUser.name = userCredential.user!.displayName!;
            newUser.about =
                'Hey I My name is ${newUser.name} , connect me at ${newUser.email}';
            log('/////as////${_auth.currentUser!.uid}');
            APIs.createNewUser(newUser);
          }
        }
      }
    } catch (e) {}
  }
}
