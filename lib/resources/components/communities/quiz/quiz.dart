import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.example.while_app/resources/components/message/apis.dart';
import 'package:flutter/material.dart';
import 'package:com.example.while_app/resources/components/communities/quiz/Screens/easy_questions_screen.dart';
import 'package:com.example.while_app/resources/components/communities/quiz/Screens/hard_questions_screen.dart';
import 'package:com.example.while_app/resources/components/communities/quiz/Screens/medium_questions_screen.dart';
import 'package:com.example.while_app/resources/components/communities/quiz/Screens/start_screen.dart';
import 'package:com.example.while_app/resources/components/message/models/community_user.dart';

class Quiz extends StatefulWidget {
  const Quiz({super.key, required this.user, required this.category});
  final Community user;
  final String category;

  @override
  State<Quiz> createState() {
    return _QuizState();
  }
}

class _QuizState extends State<Quiz> {
  List<String> selectedAnswers = [];
  Widget? activeScreeen;
  int correctAnswers = 0;
  late int lives;
  late DateTime? time;
  late int easyQuestions;
  late int attemptedEasyQuestion;
  late int mediumQuestions;
  late int attemptedMediumQuestion;
  late int hardQuestions;
  late int attemptedHardQuestion;

  participantsData() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('communities')
        .doc(widget.user.id)
        .collection('participants')
        .doc(APIs.me.id)
        .get();
    easyQuestions = await querySnapshot.data()!['easyQuestions'];
    attemptedEasyQuestion =
        await querySnapshot.data()!['attemptedEasyQuestion'];
    mediumQuestions = await querySnapshot.data()!['mediumQuestions'];
    attemptedMediumQuestion =
        await querySnapshot.data()!['attemptedMediumQuestion'];
    hardQuestions = await querySnapshot.data()!['hardQuestions'];
    attemptedHardQuestion =
        await querySnapshot.data()!['attemptedHardQuestion'];

    setState(() {});
  }

  @override
  void initState() {
    participantsData();
    activeScreeen = StartScreen(switchScreen);
    super.initState();
  }

  void switchScreen() {
    setState(
      () {
        if (widget.category == 'Easy' &&
            widget.user.easyQuestions > attemptedEasyQuestion) {
          log('easy');
          activeScreeen = EasyQuestionsScreen(
            user: widget.user,
            attemptedEasyQuestion: attemptedEasyQuestion,
            easyQuestions: easyQuestions,
          );
        }
        if (widget.category == 'Medium' &&
            widget.user.mediumQuestions > attemptedMediumQuestion) {
          log('medium');
          activeScreeen = MediumQuestionsScreen(
            user: widget.user,
            attemptedMediumQuestion: attemptedMediumQuestion,
            mediumQuestions: mediumQuestions,
          );
        }
        if (widget.category == 'Hard' &&
            widget.user.hardQuestions > attemptedHardQuestion) {
          activeScreeen = HardQuestionsScreen(
            attemptedHardQuestion: attemptedHardQuestion,
            hardQuestions: hardQuestions,
            user: widget.user,
          );
        }
      },
    );
  }

  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.lightBlue, Colors.tealAccent],
          ),
        ),
        child: Center(child: activeScreeen),
      ),
    );
  }
}
