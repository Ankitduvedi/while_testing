import 'dart:developer';

import 'package:com.while.while_app/core/utils/buttons/round_button.dart';
import 'package:com.while.while_app/core/utils/containers_widgets/header_widget.dart';
import 'package:com.while.while_app/core/utils/containers_widgets/text_container_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:com.while.while_app/core/resource_files/colors.dart';
import 'package:com.while.while_app/core/utils/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class CosumerStatefulWidget {}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 32),
            child: Column(
              children: [
                const SizedBox(
                  height: 25,
                ),
                const HeaderWidget(title: "Forgot Password"),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                    "Don't worry! Just fill in your email and While App will send you a link to rest your password"),
                const SizedBox(
                  height: 20,
                ),
                TextContainerWidget(
                  controller: _emailController,
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(
                  height: 20,
                ),
                RoundButton(
                  loading: false,
                  title: "Send Password Reset Email",
                  onPress: resetPassword,
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    const Text(
                      "Remember the account information?  ",
                    ),
                    InkWell(
                      child: const Text(
                        "Login",
                        style: TextStyle(color: AppColors.theme1Color),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              ],
            )),
      ),
    ));
  }

  Future resetPassword() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()));
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      // ignore: use_build_context_synchronously
      Utils.snackBar('Password reset email sent', context);
    } on FirebaseAuthException catch (e) {
      // print(e);
      log(e.toString()); // Utils.flushBarErrorMessage(e.message!, context);
    }
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
  }
}
