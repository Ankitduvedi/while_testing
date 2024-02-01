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
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: h,
            width: w,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.theme1Color, AppColors.buttonColor],
              ),
            ),
          ),
          Container(
            height: h / 1.2,
            width: w,
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black87,
                  offset: Offset(0.0, 1.0),
                  blurRadius: 6.0,
                ),
              ],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SingleChildScrollView(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const HeaderWidget(title: 'Register'),
                    Container(
                      height: h / 6,
                      width: w / 1.4,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/while_transparent.png"),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextContainerWidget(
                      color: Colors.white,
                      controller: _nameController,
                      prefixIcon: Icons.person,
                      hintText: 'Name',
                    ),
                    const SizedBox(height: 10),
                    TextContainerWidget(
                      color: Colors.white,
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      prefixIcon: Icons.email,
                      hintText: 'Email',
                    ),
                    const SizedBox(height: 10),
                    TextPasswordContainerWidget(
                      keyboardType: TextInputType.visiblePassword,
                      controller: _passwordController,
                      prefixIcon: Icons.lock,
                      hintText: 'Password',
                    ),
                    SizedBox(
                      height: h * 0.045,
                    ),
                    RoundButton(
                      loading: false,
                      title: 'SignUp',
                      onPress: () async {
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
                    ),
                    SizedBox(
                      height: h * 0.02,
                    ),
                    Row(
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          width: h * 0.01,
                        ),
                        InkWell(
                          onTap: () {
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (context) => const LoginScreen(),
                            //     ));
                            // Navigator.of(context).pop();
                            ref.read(toggleStateProvider.notifier).state = 1;
                          },
                          child: const Text("Login",
                              style: TextStyle(
                                color: AppColors.theme1Color,
                              )),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
