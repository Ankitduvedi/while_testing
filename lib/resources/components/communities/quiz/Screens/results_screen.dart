import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen(
      {super.key,
      required this.totalAnswers,
      required this.correctAnswers,
      required this.level});

  final int totalAnswers;
  final int correctAnswers;
  final String level;

  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        margin: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('You answered $correctAnswers questions correctly!',
                style: const TextStyle(fontSize: 25, color: Colors.white),
                textAlign: TextAlign.center),
            const SizedBox(height: 40),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.cached_outlined),
                label: const Text(
                    style: TextStyle(fontSize: 20), 'Back to Community'))
          ],
        ),
      ),
    );
  }
}
