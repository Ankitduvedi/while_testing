import 'dart:developer';
import 'package:com.example.while_app/view_model/providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:com.example.while_app/resources/colors.dart';
import 'package:com.example.while_app/resources/components/round_button.dart';
import 'package:com.example.while_app/resources/components/text_container_widget.dart';
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
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                height: 420,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 10,
                      offset: Offset(-4, -4),
                    ),
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(4, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: w / 2,
                      height: h / 12,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/while_transparent.png"),
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                    const SizedBox(),
                    TextContainerWidget(
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      prefixIcon: Icons.email,
                    ),
                    TextContainerWidget(
                      hintText: 'Password',
                      keyboardType: TextInputType.visiblePassword,
                      controller: _passwordController,
                      prefixIcon: Icons.lock,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, RoutesName.forgot);
                        },
                        child: Text(
                          "Forgot Password?",
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: AppColors.theme1Color,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),
                    ),
                    RoundButton(
                      loading: false,
                      title: 'Login',
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
                          context
                              .read<FirebaseAuthMethods>()
                              .loginInWithEmailAndPassword(
                                _emailController.text.toString(),
                                _passwordController.text.toString(),
                                context,
                              );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "OR",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      // color: AppColors.theme1Color,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 164,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 10,
                      offset: Offset(-4, -4),
                    ),
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(4, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(height: 10),
                    RoundButton(
                      loading: false,
                      title: 'Signup with Google',
                      onPress: () {
                        handleSignIn();
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    // color: AppColors.theme1Color,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        TextButton(
                          onPressed: () {
                            //Navigator.pushNamed(context, RoutesName.signUp);
                            ref.read(toggleStateProvider.notifier).state = 2;
                          },
                          style: const ButtonStyle(
                            padding: MaterialStatePropertyAll(EdgeInsets.zero),
                          ),
                          child: Text(
                            "Signup",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color: AppColors.theme1Color,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
