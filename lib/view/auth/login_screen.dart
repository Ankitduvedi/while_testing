import 'dart:developer';
import 'package:com.example.while_app/view_model/providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:com.example.while_app/utils/routes/routes_name.dart';
import 'package:com.example.while_app/utils/utils.dart';
import '../../repository/firebase_repository.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly'
]);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return LoginScreenState();
  }
}

class LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late GoogleSignInAccount currentUser;
  @override
  void initState() {
    super.initState();
  }

  Future<void> handleSignIn() async {
    try {
      await FirebaseAuthMethods(FirebaseAuth.instance)
          .signInWithGoogle(context);
    } catch (error) {
      log("Sign in error$error");
    }
  }

  Future<void> handleSignOut() => _googleSignIn.disconnect();

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double verticalPadding = screenSize.height * 0.02;

    return Scaffold(
      //backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(screenSize.width * 0.05),
            child: Column(
              children: <Widget>[
                SizedBox(height: verticalPadding),
                const Text(
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
                        // Implement your on-tap functionality here
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.blue, // This changes the text color
                        ),
                      ),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(150, 50),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(toggleStateProvider.notifier).state = 2;
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.blue, // This changes the text color
                        ),
                      ),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(150, 50),
                      ),
                    )
                  ],
                ),
                SizedBox(height: verticalPadding),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Enter Email',
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                ),
                SizedBox(height: verticalPadding),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                  ),
                  //obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  controller: _passwordController,
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, RoutesName.forgot);
                    },
                    child: const Text(
                      'Recover Password ?',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(height: verticalPadding),
                ElevatedButton(
                  onPressed: () async {
                    if (_emailController.text.isEmpty) {
                      Utils.flushBarErrorMessage('Please enter email', context);
                    } else if (_passwordController.text.isEmpty) {
                      Utils.flushBarErrorMessage(
                          'Please enter password', context);
                    } else if (_passwordController.text.length < 6) {
                      Utils.flushBarErrorMessage(
                          'Please enter at least 6-digit password', context);
                    } else {
                      context
                          .read<FirebaseAuthMethods>()
                          .loginInWithEmailAndPassword(
                            _emailController.text.toString(),
                            _passwordController.text.toString(),
                            context,
                          );
                    }
                  },
                  child: Text(
                    'Sign In',
                    style: TextStyle(fontSize: 20),
                  ),
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      )),
                ),

                SizedBox(height: verticalPadding * 1.2),
                const Row(
                  children: <Widget>[
                    Expanded(
                      child: Divider(
                        thickness:
                            1, // Set the thickness of the divider as needed
                        color: Colors
                            .grey, // Set the color of the divider as needed
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('OR'),
                    ),
                    Expanded(
                      child: Divider(
                        thickness:
                            1, // Set the thickness of the divider as needed
                        color: Colors
                            .grey, // Set the color of the divider as needed
                      ),
                    ),
                  ],
                ),
                SizedBox(height: verticalPadding * 1.4),
                ElevatedButton(
                  onPressed: () {
                    handleSignIn();
                  },
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity,
                          50), // ensures the button stretches to fill the width
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // rounded corners
                      ),
                      backgroundColor: Colors.grey.shade400),
                  child: Row(
                    mainAxisSize: MainAxisSize
                        .min, // Use MainAxisSize.min to keep the row compact
                    children: <Widget>[
                      Image.asset('assets/google_logo2.png',
                          width: 40, height: 40),
                      const SizedBox(
                          width:
                              30), // Increase width to increase the distance between the logo and the text
                      const Text('Login with Google',
                          style: TextStyle(fontSize: 20)),
                    ],
                  ),
                ),

                // RoundButton(

                //   loading: false,
                //   title: 'Signup with Google',
                //   onPress: () {
                //     handleSignIn();
                //   },
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
