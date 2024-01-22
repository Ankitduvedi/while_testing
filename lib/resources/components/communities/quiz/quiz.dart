import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.example.while_app/resources/components/communities/quiz/lives.dart';
import 'package:com.example.while_app/resources/components/message/apis.dart';
import 'package:flutter/material.dart';
import 'package:com.example.while_app/resources/components/communities/quiz/Screens/easy_questions_screen.dart';
import 'package:com.example.while_app/resources/components/communities/quiz/Screens/hard_questions_screen.dart';
import 'package:com.example.while_app/resources/components/communities/quiz/Screens/medium_questions_screen.dart';
import 'package:com.example.while_app/resources/components/communities/quiz/Screens/results_screen.dart';
import 'package:com.example.while_app/resources/components/communities/quiz/Screens/start_screen.dart';
import 'package:com.example.while_app/resources/components/message/models/community_user.dart';

class Quiz extends StatefulWidget {
  const Quiz({super.key, required this.user, required this.category});
  final CommunityUser user;
  final String category;

  @override
  State<Quiz> createState() {
    return _QuizState();
  }
}

class _QuizState extends State<Quiz> {
  List<String> selectedAnswers = [];
  Widget? activeScreeen;
  // int lives = 3;
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

  renewLive() async {
    lives = await LivesManager.getLives();
    time = await LivesManager.getLastRenewalTime();
    DateTime? lastRenewalTime = await LivesManager.getLastRenewalTime();
    print(lastRenewalTime);
    log('time');

    log(lastRenewalTime.toString());

    // Check if 24 hours have passed since the last renewal
    if (lastRenewalTime != null) {
      Duration timePassed = DateTime.now().difference(lastRenewalTime);
      if (timePassed.inMinutes >= 5) {
        await LivesManager.renewLives(); // Renew lives if 24 hours have passed
        print('Lives renewed!');
      }
    } else {
      await LivesManager.renewLives();
    }
  }

  @override
  void initState() {
    activeScreeen = StartScreen(switchScreen);
    renewLive();
    participantsData();
    super.initState();
  }

  void switchScreen() {
    setState(
      () {
        if (widget.category == 'Easy' &&
            lives > 0 &&
            widget.user.easyQuestions > attemptedEasyQuestion) {
          activeScreeen = EasyQuestionsScreen(
            user: widget.user,
            attemptedEasyQuestion: attemptedEasyQuestion,
            easyQuestions: easyQuestions,
          );
        }
        if (widget.category == 'Medium') {
          activeScreeen = MediumQuestionsScreen(
            user: widget.user,
            attemptedMediumQuestion: attemptedMediumQuestion,
            mediumQuestions: mediumQuestions,
          );
        }
        if (widget.category == 'Hard') {
          activeScreeen = HardQuestionsScreen(
            onSelectAnswer: chooseAnswer,
            user: widget.user,
            correctAnswers: correctAnswers,
            lives: lives,
          );
        }
      },
    );
  }

  void restartQuiz() {
    setState(() {
      Navigator.pop(context);
      //activeScreeen = QuizScreen(user: widget.user);
      selectedAnswers = [];
    });
  }

  void chooseAnswer(String answer, int lives, int correctAnswers) {
    selectedAnswers.add(answer);

    if (selectedAnswers.length == 10 || lives == 0) {
      setState(() {
        activeScreeen = ResultsScreen(
          level: '',
          totalAnswers: 0,
          correctAnswers: correctAnswers,
        );
      });
    }
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
