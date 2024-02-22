import 'dart:developer';

import 'package:com.example.while_app/resources/components/communities/quiz/Screens/timer.dart';
import 'package:com.example.while_app/resources/components/communities/quiz/lives.dart';
import 'package:flutter/material.dart';
import 'package:com.example.while_app/resources/components/communities/quiz/add_quiz.dart';
import 'package:com.example.while_app/resources/components/communities/quiz/quiz.dart';
import 'package:com.example.while_app/data/model/community_user.dart';

class QuizScreen extends StatefulWidget {
  QuizScreen({Key? key, required this.user}) : super(key: key);
  final Community user;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late int lives;

  late DateTime? time;
  late Duration timePassed;
  renewLive() async {
    lives = await LivesManager.getLives();
    time = await LivesManager.getLastRenewalTime();
    DateTime? lastRenewalTime = await LivesManager.getLastRenewalTime();
    log('time');
    log(lastRenewalTime.toString());
    // Check if 24 hours have passed since the last renewal
    if (lastRenewalTime != null) {
      timePassed = DateTime.now().difference(lastRenewalTime);
      log(timePassed.inSeconds.toString());

      if (timePassed.inMinutes >= 5) {
        await LivesManager.renewLives(); // Renew lives if 24 hours have passed
      }
    } else {
      await LivesManager.renewLives();
    }
  }

  @override
  void initState() {
    renewLive();
    super.initState();
  }

  void _createQuiz(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddQuestionScreen(user: widget.user),
      ),
    );
  }

  void _startQuiz(BuildContext context, String category) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => lives > 0
            ? Quiz(user: widget.user, category: category)
            : TimerDialog(timePassed: timePassed),
      ),
    );
  }

  Widget _buildQuizCard(
      BuildContext context, String level, List<Color> gradientColors) {
    int starCount;

    switch (level.toLowerCase()) {
      case 'easy':
        starCount = 1;
        break;
      case 'medium':
        starCount = 2;
        break;
      case 'hard':
        starCount = 3;
        break;
      default:
        starCount = 0;
    }

    return GestureDetector(
      onTap: () => _startQuiz(context, level),
      child: Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < starCount; i++)
                    const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 40.0,
                    ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                level,
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildQuizCard(context, 'Easy', [
              const Color.fromARGB(255, 87, 208, 235),
              const Color.fromARGB(255, 107, 233, 112),
            ]),
            _buildQuizCard(context, 'Medium', [
              const Color.fromARGB(255, 231, 198, 152),
              Colors.yellow,
            ]),
            _buildQuizCard(context, 'Hard', [
              const Color.fromARGB(255, 238, 148, 142),
              const Color.fromARGB(255, 227, 16, 16),
            ]),
            _buildQuizCard(context, 'Dashboard', [
              const Color.fromARGB(255, 75, 0, 130),
              const Color.fromARGB(255, 123, 104, 238),
            ]),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlueAccent,
        onPressed: () => _createQuiz(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
