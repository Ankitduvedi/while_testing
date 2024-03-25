import 'package:com.example.while_app/resources/components/message/helper/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.example.while_app/resources/components/communities/quiz/quiz_model.dart';
import 'package:com.example.while_app/data/model/community_user.dart';

const uuid = Uuid();

final FirebaseFirestore firestore = FirebaseFirestore.instance;

class AddQuestionScreen extends StatefulWidget {
  const AddQuestionScreen({Key? key, required this.user}) : super(key: key);
  final Community user;

  @override
  AddQuestionScreenState createState() => AddQuestionScreenState();
}

class AddQuestionScreenState extends State<AddQuestionScreen> {
  TextEditingController questionController = TextEditingController();
  TextEditingController option1Controller = TextEditingController();
  TextEditingController option2Controller = TextEditingController();
  TextEditingController option3Controller = TextEditingController();
  TextEditingController option4Controller = TextEditingController();

  String correctAnswer = 'A';
  String selectedOption = 'A';
  List<Map<String, dynamic>> questions = [];
  List<String> options = ['A', 'B', 'C', 'D'];
  List<String> categories = ['Easy', 'Medium', 'Hard'];
  String selectedCategory = 'Easy';
  String typeOfQuestion = 'easyQuestions';

  void _saveQuestion() async {
    int numberOfQuestions = widget.user.easyQuestions + 1;
    if (selectedCategory == 'Medium') {
      typeOfQuestion = 'mediumQuestions';
      numberOfQuestions = widget.user.mediumQuestions + 1;
    }
    if (selectedCategory == 'Hard') {
      typeOfQuestion = 'hardQuestions';
      numberOfQuestions = widget.user.hardQuestions + 1;
    }

    if (_validateFields()) {
      final newQuestion = Questions(
        id: uuid.v4(),
        question: questionController.text,
        options: {
          'A': option1Controller.text,
          'B': option2Controller.text,
          'C': option3Controller.text,
          'D': option4Controller.text,
        },
        correctAnswer: selectedOption,
      );

      FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.user.id)
          .collection('quizzes')
          .doc(widget.user.id)
          .collection(selectedCategory)
          .doc(newQuestion.id)
          .set({
        'question': newQuestion.question,
        'options': newQuestion.options,
        'correctAnswer': newQuestion.correctAnswer,
        'id': newQuestion.id,
        'timeStamp': FieldValue.serverTimestamp()
      }).then((_) {
        FirebaseFirestore.instance
            .collection('communities')
            .doc(widget.user.id)
            .update({typeOfQuestion: numberOfQuestions});
        _clearFields();
      });
      Navigator.pop(context);
    }
  }

  bool _validateFields() {
    if (questionController.text.isEmpty ||
        option1Controller.text.isEmpty ||
        option2Controller.text.isEmpty ||
        option3Controller.text.isEmpty ||
        option4Controller.text.isEmpty) {
      Dialogs.showSnackbar(context, 'Enter the values');
      return false;
    }
    return true;
  }

  void _clearFields() {
    questionController.clear();
    option1Controller.clear();
    option2Controller.clear();
    option3Controller.clear();
    option4Controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: Colors.lightBlueAccent,)),
        backgroundColor: Colors.white,
        title: const Text('Add Question', style: TextStyle(color: Colors.black),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField('Question', questionController),
              const SizedBox(height: 10),
              _buildTextField('Option 1', option1Controller),
              const SizedBox(height: 10),
              _buildTextField('Option 2', option2Controller),
              const SizedBox(height: 10),
              _buildTextField('Option 3', option3Controller),
              const SizedBox(height: 10),
              _buildTextField('Option 4', option4Controller),
              const SizedBox(height: 10),
              _buildDropDown('Correct Answer', selectedOption, options,
                  (String? value) {
                setState(() {
                  selectedOption = value!;
                });
              }),
              const SizedBox(height: 10),
              _buildDropDown('Category', selectedCategory, categories,
                  (String? value) {
                setState(() {
                  selectedCategory = value!;
                });
              }),
              const SizedBox(height: 20),
              SizedBox(
                width: 60,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    _saveQuestion();
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 4,
                    backgroundColor:  Colors.lightBlueAccent, // Change button color here
                  ),
                  child: const Text('Add Question', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      maxLines: null,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDropDown(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return Row(
      children: [
        Text(label),
        const SizedBox(width: 10),
        DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }
}
