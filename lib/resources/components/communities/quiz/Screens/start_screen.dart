import 'package:flutter/material.dart';

// import 'package:quiz_app/quiz.dart';

// import 'package:quiz_app/questions_screen.dart';


class StartScreen extends StatelessWidget {
  const StartScreen(this.startQuiz ,{super.key});
  final void Function() startQuiz;


  @override
  Widget build(context) {

     Size screenSize = MediaQuery.of(context).size;

    // Access width and height
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;


    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset('assets/quiz.png', 
            width: screenWidth,
            height: screenHeight,
           // fit: BoxFit.cover,
            
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(screenWidth*0.2, screenHeight*0.82, screenWidth*0.2, screenHeight*0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                fixedSize: Size(screenWidth*0.8, screenHeight*0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
              ),
              onPressed: startQuiz,
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 28,),
              label: const Text(style: TextStyle(fontSize: 30), 'Start Quiz'),
            ),
          ),
          // TextButton(
          //   onPressed: () {},
          //   child: const Text(style: TextStyle(fontSize: 20),'start quiz'),
          // ),
        ],
      ),
    );
  }
}
