import 'dart:developer';

import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:com.while.while_app/core/utils/utils.dart';
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
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    log("signup screen");
    final Size screenSize = MediaQuery.of(context).size;
    final double verticalPadding = screenSize.height * 0.02;
    final loading = ref.read(authControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(screenSize.width * 0.05),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Image.asset(
                    'assets/while_logo.png',
                    width:
                        screenSize.width * 0.9, // Dynamic width for the image
                    height: screenSize.height * 0.3,
                  ), // Placeholder for the image
                  SizedBox(height: verticalPadding),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter an email address';
                      } else if (!RegExp(
                              r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null; // Return null if the input is valid
                    },
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
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) => value!.length < 3
                        ? "Name length must be more than 3 characters"
                        : null,
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
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) => value!.length < 8
                        ? "Password must be at least 8 characters"
                        : null,
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
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
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
                      if (_formKey.currentState!.validate()) {
                        ref.read(userProvider.notifier).update((state) => null);
                        ref
                            .read(authControllerProvider.notifier)
                            .signInWithEmailAndPassword(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                              _nameController.text.trim(),
                              context,
                            );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.blue[800],
                      backgroundColor:
                          Colors.white, // Icon color taken from the logo
                      minimumSize:
                          const Size(double.infinity, 50), // Button size
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12), // Inner padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            24), // Rounded corners to match logo style
                        side: BorderSide(
                            color: Colors.blue[
                                800]!), // Border color taken from the logo
                      ),
                      elevation:
                          0, // No shadow for a flat design similar to the logo
                    ),
                    child: loading
                        ? const CircularProgressIndicator()
                        : Text(
                            'Sign Up',
                            style: GoogleFonts.ptSans(fontSize: 20),
                          ),
                  ),

                  SizedBox(height: verticalPadding * 1.2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account?'),
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
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
