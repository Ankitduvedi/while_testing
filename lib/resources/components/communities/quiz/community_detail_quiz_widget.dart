import 'package:flutter/material.dart';
import 'package:com.example.while_app/resources/components/communities/quiz/add_quiz.dart';
import 'package:com.example.while_app/resources/components/communities/quiz/quiz.dart';
import 'package:com.example.while_app/resources/components/message/models/community_user.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({Key? key, required this.user}) : super(key: key);

  final CommunityUser user;

  void _createQuiz(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddQuestionScreen(user: user),
      ),
    );
  }

  void _startQuiz(BuildContext context, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Quiz(user: user, category: category),
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
      backgroundColor: Colors.black,
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createQuiz(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
