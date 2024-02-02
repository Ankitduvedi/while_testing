import 'package:com.example.while_app/data/model/auth_user.dart';
import 'package:com.example.while_app/resources/components/header_widget.dart';
import 'package:com.example.while_app/resources/components/password_container_widget.dart';
import 'package:com.example.while_app/view/home_screen.dart';
import 'package:com.example.while_app/view_model/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:com.example.while_app/resources/colors.dart';
import 'package:com.example.while_app/resources/components/round_button.dart';
import 'package:com.example.while_app/resources/components/text_container_widget.dart';
import 'package:com.example.while_app/utils/utils.dart';
import 'package:com.example.while_app/view/auth/login_screen.dart';
import '../../repository/firebase_repository.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  SignUpScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double verticalPadding = screenSize.height * 0.02;
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(screenSize.width * 0.05),
            child: Column(
              children: <Widget>[
                SizedBox(height: verticalPadding),
                Text(
                  'Welcome user!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: verticalPadding * 1.2),
                Image.asset(
                  'assets/loginPicture1.png',
                  width: screenSize.width * 0.9, // Dynamic width for the image
                  height: screenSize.height * 0.3,
                ), // Placeholder for the image
                SizedBox(height: verticalPadding),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //Textbutton(ontap: () {}, text: "signIn"),
                    //Textbutton(ontap: () {}, text: "Register"),
                    TextButton(
                      onPressed: () {
                        ref.read(toggleStateProvider.notifier).state = 1;
                      },
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.blue, // This changes the text color
                        ),
                      ),
                      style: TextButton.styleFrom(
                        minimumSize: Size(150, 50),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Implement your on-tap functionality here
                      },
                      child: Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.blue, // This changes the text color
                        ),
                      ),
                      style: TextButton.styleFrom(
                        minimumSize: Size(150, 50),
                      ),
                    )
                  ],
                ),
                SizedBox(height: verticalPadding),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Enter Email',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                ),
                SizedBox(height: verticalPadding),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Enter Username',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                  ),
                  controller: _nameController,
                ),
                SizedBox(height: verticalPadding),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                  ),
                  //obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  controller: _passwordController,
                ),
                SizedBox(height: verticalPadding),
                ElevatedButton(
                  onPressed: () async {
                    if (_emailController.text.isEmpty) {
                            Utils.flushBarErrorMessage(
                                'Please enter email', context);
                          } else if (_passwordController.text.isEmpty) {
                            Utils.flushBarErrorMessage(
                                'Please enter password', context);
                          } else if (_passwordController.text.length < 6) {
                            Utils.flushBarErrorMessage(
                                'Please enter at least 6-digit password',
                                context);
                          } else {
                            // Show loading indicator if needed
                            final signUpSuccess = await context
                                .read<FirebaseAuthMethods>()
                                .signInWithEmailAndPassword(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                  _nameController.text.trim(),
                                  context,
                                );
                            // Hide loading indicator
                            if (signUpSuccess) {
                              //final firebaseUser = context.watch<User?>();
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomeScreen()));
                              Utils.toastMessage('Sign up successful ');
                              // Navigate to the next screen if needed
                            } else {
                              Utils.toastMessage('Sign up failed');
                            }
                          }
                  },
                  child: Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 20),
                  ),
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      )),
                ),

                SizedBox(height: verticalPadding * 1.2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
