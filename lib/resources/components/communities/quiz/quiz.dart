//WWW

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
  int lives = 3;
  int correctAnswers = 0;

  @override
  void initState() {
    activeScreeen = StartScreen(switchScreen);
    super.initState();
  }

  void switchScreen() {
    setState(
      () {
        if (widget.category == 'Easy') {
          activeScreeen = EasyQuestionsScreen(
            user: widget.user,
            lives: lives,
          );
        }
        if (widget.category == 'Medium') {
          activeScreeen = MediumQuestionsScreen(
            lives: lives,
            onSelectAnswer: chooseAnswer,
            user: widget.user,
            correctAnswers: correctAnswers,
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
