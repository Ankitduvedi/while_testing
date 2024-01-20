import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:while_app/resources/components/message/models/community_user.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:while_app/resources/components/communities/quiz/answerButton.dart';

class HardQuestionsScreen extends StatefulWidget {
  final CommunityUser user;
  final void Function(String answer, int life, int correctAnswers) onSelectAnswer;
  int correctAnswers;
  int lives;

  HardQuestionsScreen({super.key, required this.user, required this.onSelectAnswer, required this.correctAnswers, required this.lives});

  @override
  _QuestionsScreenState createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<HardQuestionsScreen> {
  late List<Map<String, dynamic>> questions;
  late Future<List<Map<String, dynamic>>> quizzz;


    Future<List<Map<String, dynamic>>> _getQuestions() async {
    const category = 'Hard'; // Set the category as needed
    final querySnapshot = await FirebaseFirestore.instance
        .collection('communities')
        .doc(widget.user.id)
        .collection('quizzes')
        .doc(widget.user.id)
        .collection(category)
        .get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  void initState() {
    super.initState();
    quizzz = _getQuestions();
    startTimer();
  }

  

  @override
  void dispose() {
    super.dispose();
    timer!.cancel();
  }

 var currentQuestionIndex = 0;
  int seconds = 45;
  Timer? timer;

    startTimer(){
    timer = Timer.periodic(Duration(seconds: 1), (timer) { 
      setState(() {
        if (seconds > 0) {
          seconds--;
        }
        else {
          setState(() {
            
          timer!.cancel();
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
      if(selectedAnswers == correctAnswer) {
        //widget.lives++;
        widget.correctAnswers++;

      }
      else {
        widget.lives--;
      }
      currentQuestionIndex = currentQuestionIndex +1;
      timer!.cancel();
      startTimer();
      seconds = 45;
      
    });
    widget.onSelectAnswer(selectedAnswers!, widget.lives, widget.correctAnswers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // appBar: AppBar(
      //   title: const Text('Quiz Questions'),
      //   actions: [
      //     Icon(Icons.arrow_back_ios_new)
      //   ],
      // ),
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
              child: Text('Error: ${snapshot.error},', style: TextStyle(color: Colors.white),),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No questions available.', style: TextStyle(color: Colors.white),),
            );
          }

          questions = snapshot.data!;
          final currentQuestion = questions[currentQuestionIndex];

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                
                children: [
                  SizedBox(
                    
                    height: 60,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.black),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        IconButton(onPressed: () {
                          Navigator.pop(context);
                        }, icon: Icon(CupertinoIcons.back, color: Colors.white, size: 40,)),
                        Stack(
                          alignment: Alignment.center,
                          children:
                          [ Text("$seconds", style: TextStyle(color: Colors.white),),
                          CircularProgressIndicator(
                            value: seconds/45,
                            valueColor: AlwaysStoppedAnimation(Colors.lightGreen),
                          ),
                          ]),
                        SizedBox(
                          child: Row(children: [
                            TextButton.icon(onPressed: () {}, 
                            label: Text("${widget.lives}" ,style: TextStyle(color: Colors.red, fontSize: 20),),
                            icon: Icon(CupertinoIcons.heart_fill, color: Colors.red, size: 35,), 
                            )
                          ],)
                        ),
                      ]),
                    ),
                  ),
                  Divider(thickness: 2, color: Colors.grey.shade800,),
                  SizedBox(height: 200,
            
                  child: Center(child: Text("Question number ${currentQuestionIndex +1}", style: TextStyle(color: Colors.grey.shade100, fontSize: 20),)),
                  ),
                  Text(
                    currentQuestion['question'],
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20,),
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
    return [const Text('Error: Options not available', style: TextStyle(color: Colors.white),)];
  }
}


  
}
