import 'dart:async';
import 'dart:developer';
import 'package:com.example.while_app/resources/components/communities/quiz/Screens/results_screen.dart';
import 'package:com.example.while_app/resources/components/communities/quiz/lives.dart';
import 'package:com.example.while_app/resources/components/message/apis.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.example.while_app/resources/components/communities/quiz/answerButton.dart';
import 'package:com.example.while_app/data/model/community_user.dart';

class HardQuestionsScreen extends StatefulWidget {
  final Community user;
  final int hardQuestions;
  final int attemptedHardQuestion;

  const HardQuestionsScreen({
    super.key,
    required this.user,
    required this.attemptedHardQuestion,
    required this.hardQuestions,
  });

  @override
  QuestionsScreenState createState() => QuestionsScreenState();
}

class QuestionsScreenState extends State<HardQuestionsScreen> {
  late List<Map<String, dynamic>> questions;
  late Future<List<Map<String, dynamic>>> quizzz;
  late int lives;
  getlive() async {
    lives = await LivesManager.getLives();
    setState(() {});
  }

  int correctAnswers = 0;
  Future<List<Map<String, dynamic>>> _getQuestions() async {
    const category = 'Hard'; // Set the category as needed
    final querySnapshot = await FirebaseFirestore.instance
        .collection('communities')
        .doc(widget.user.id)
        .collection('quizzes')
        .doc(widget.user.id)
        .collection(category)
        .orderBy('timeStamp', descending: false)
        .get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  late int currentQuestionIndex;
  @override
  void initState() {
    currentQuestionIndex = widget.attemptedHardQuestion;
    super.initState();
    getlive();
    log('//attempted questions');
    log(widget.attemptedHardQuestion.toString());
    quizzz = _getQuestions();
    startTimer();
  }

  @override
  void dispose() {
    super.dispose();
    timer!.cancel();
  }

  int seconds = 45;
  Timer? timer;

  startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (seconds > 0) {
          seconds--;
        } else {
          setState(() {
            answerQuestion(null, 'e');
            startTimer();
            seconds = 45;
          });
        }
      });
    });
  }

  void answerQuestion(String? selectedAnswers, String correctAnswer) {
    setState(() {
      if (selectedAnswers == correctAnswer) {
        correctAnswers++;
      } else {
        lives--;
        LivesManager.decrementLife();
      }
      timer!.cancel();

      if ((questions.length - 1) > currentQuestionIndex && lives > 0) {
        currentQuestionIndex = currentQuestionIndex + 1;
        startTimer();
        seconds = 45;
      } else {
        APIs.updateScore(
            widget.user.id,
            'hardQuestions',
            correctAnswers + widget.hardQuestions,
            correctAnswers + APIs.me.hardQuestions,
            'attemptedHardQuestion',
            (currentQuestionIndex + 1));
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ResultsScreen(
            totalAnswers: currentQuestionIndex,
            correctAnswers: correctAnswers,
            level: 'hardQuestions',
          ),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: quizzz,
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No questions available.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          questions = snapshot.data!;
          final currentQuestion = questions[currentQuestionIndex];
          if (questions.length <= currentQuestionIndex) {
            log('navigated to resultscreen');
          }
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 60,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: Colors.black),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(
                                  CupertinoIcons.back,
                                  color: Colors.white,
                                  size: 40,
                                )),
                            Stack(alignment: Alignment.center, children: [
                              Text(
                                "$seconds",
                                style: const TextStyle(color: Colors.white),
                              ),
                              CircularProgressIndicator(
                                value: seconds / 45,
                                valueColor: const AlwaysStoppedAnimation(
                                    Colors.lightGreen),
                              ),
                            ]),
                            SizedBox(
                                child: Row(
                              children: [
                                TextButton.icon(
                                  onPressed: () {},
                                  label: Text(
                                    "$lives",
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 20),
                                  ),
                                  icon: const Icon(
                                    CupertinoIcons.heart_fill,
                                    color: Colors.red,
                                    size: 35,
                                  ),
                                )
                              ],
                            )),
                          ]),
                    ),
                  ),
                  Divider(
                    thickness: 2,
                    color: Colors.grey.shade800,
                  ),
                  SizedBox(
                    height: 200,
                    child: Center(
                        child: Text(
                      "Question number ${currentQuestionIndex + 1}",
                      style:
                          TextStyle(color: Colors.grey.shade100, fontSize: 20),
                    )),
                  ),
                  Text(
                    currentQuestion['question'],
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ..._buildAnswerButtons(currentQuestion),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildAnswerButtons(Map<String, dynamic> question) {
    final options = question['options'];
    final correctAnswer = question['correctAnswer'];

    if (options is Map<String, dynamic>) {
      return options.keys.map((option) {
        return AnswerButton(
          onTap: () {
            answerQuestion(option, correctAnswer);
          },
          answerText: (options[option]),
        );
      }).toList();
    } else {
      return [
        const Text(
          'Error: Options not available',
          style: TextStyle(color: Colors.white),
        )
      ];
    }
  }
}
