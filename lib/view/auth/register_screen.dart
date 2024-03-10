import 'package:com.example.while_app/view/home_screen.dart';
import 'package:com.example.while_app/view_model/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:com.example.while_app/utils/utils.dart';
import '../../repository/firebase_repository.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _nameController = TextEditingController();

  bool _obscureText = true; // Initially password is obscure

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
                  style: GoogleFonts.ptSans(
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
                      style: TextButton.styleFrom(
                        minimumSize: const Size(150, 50),
                      ),
                      child: Text(
                        'Sign In',
                        style: GoogleFonts.ptSans(
                          color: Colors.blue, // This changes the text color
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Implement your on-tap functionality here
                      },
                      style: TextButton.styleFrom(
                        minimumSize: const Size(150, 50),
                      ),
                      child: Text(
                        'Register',
                        style: GoogleFonts.ptSans(
                          color: Colors.blue, // This changes the text color
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: verticalPadding),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Enter Email',
                    labelStyle: GoogleFonts.ptSans(),
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
                    labelText: 'Enter Username',
                    labelStyle: GoogleFonts.ptSans(),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                  ),
                  controller: _nameController,
                ),
                SizedBox(height: verticalPadding),
                TextField(
                  controller: _passwordController,
                  obscureText:
                      _obscureText, // Toggle this boolean to show/hide password
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: GoogleFonts.ptSans(),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    // Added suffixIcon to toggle password visibility
                    suffixIcon: IconButton(
                      icon: Icon(
                        // Change the icon based on the state of _obscureText
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        // Update the state to toggle password visibility
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
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
                                builder: (context) => const HomeScreen()));
                        Utils.toastMessage('Sign up successful ');
                        // Navigate to the next screen if needed
                      } else {
                        Utils.toastMessage('Sign up failed');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      )),
                  child: Text(
                    'Sign Up',
                    style: GoogleFonts.ptSans(fontSize: 20),
                  ),
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
