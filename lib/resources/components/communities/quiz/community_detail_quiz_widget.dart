import 'package:flutter/material.dart';
import 'package:while_app/resources/components/communities/quiz/add_quiz.dart';
import 'package:while_app/resources/components/communities/quiz/quiz.dart';
import 'package:while_app/resources/components/message/models/community_user.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key, required this.user});

  final CommunityUser user;

  _createQuiz(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => AddQuestionScreen(user: user,)),
  );
}



void _easyQuiz(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => Quiz(user: user, category: 'Easy'),),
  );
}

void _mediumQuiz(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => Quiz(user: user, category: 'Medium'),),
  );
}

void _hardQuiz(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => Quiz(user: user, category: 'Hard'),),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          GestureDetector(
            onTap: () => _easyQuiz(context),
            child: const QuizTile(level: 'Easy', gradientColors: [Color.fromARGB(255, 87, 208, 235), Color.fromARGB(255, 107, 233, 112)])),
          GestureDetector(
            onTap: () => _mediumQuiz(context),
            child: const QuizTile(level: 'Medium', gradientColors: [Color.fromARGB(255, 231, 198, 152), Colors.yellow])),
          GestureDetector(
            onTap: () => _hardQuiz(context),
            child: const QuizTile(level: 'Hard', gradientColors: [Color.fromARGB(255, 238, 148, 142), Color.fromARGB(255, 227, 16, 16)])),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createQuiz(context),
        child: const Icon(Icons.add),
    ),
      );
  }
}

class QuizTile extends StatelessWidget {
  final String level;
  final List<Color> gradientColors;

  const QuizTile({super.key, required this.level, required this.gradientColors});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          level,
          style: const TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
