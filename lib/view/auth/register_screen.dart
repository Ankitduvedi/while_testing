import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:com.example.while_app/resources/colors.dart';
import 'package:com.example.while_app/resources/components/round_button.dart';
import 'package:com.example.while_app/resources/components/text_container_widget.dart';
import 'package:com.example.while_app/utils/utils.dart';
import 'package:com.example.while_app/view/auth/login_screen.dart';
import '../../repository/firebase_repository.dart';

class SignUpScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: Center(
          child: Container(
            height: 450,
            margin: const EdgeInsets.all(24),
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
                  hintText: 'Name',
                  keyboardType: TextInputType.text,
                  controller: _nameController,
                  prefixIcon: Icons.person,
                ),
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
                const SizedBox(height: 10),
                RoundButton(
                  loading: false,
                  title: 'SignUp',
                  onPress: () {
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
                          .signInWithEmailAndPassword(
                            _emailController.text.toString(),
                            _passwordController.text.toString(),
                            _nameController.text.toString(),
                            context,
                          );
                      Utils.toastMessage('Response submitted');
                    }
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            // color: AppColors.theme1Color,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      style: const ButtonStyle(
                        padding: MaterialStatePropertyAll(EdgeInsets.zero),
                      ),
                      child: Text(
                        "Login",
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
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
        ),
      ),
    );

    // return Scaffold(
    //   body: Stack(
    //     children: [
    //       Container(
    //         height: h,
    //         width: w,
    //         decoration: const BoxDecoration(
    //           gradient: LinearGradient(
    //             colors: [AppColors.theme1Color, AppColors.buttonColor],
    //           ),
    //         ),
    //       ),
    //       Container(
    //         height: h / 1.2,
    //         width: w,
    //         decoration: const BoxDecoration(
    //           color: Colors.black,
    //           boxShadow: [
    //             BoxShadow(
    //               color: Colors.black87,
    //               offset: Offset(0.0, 1.0),
    //               blurRadius: 6.0,
    //             ),
    //           ],
    //           borderRadius: BorderRadius.only(
    //             bottomLeft: Radius.circular(30),
    //             bottomRight: Radius.circular(30),
    //           ),
    //         ),
    //         child: SingleChildScrollView(
    //           child: Container(
    //             padding:
    //                 const EdgeInsets.symmetric(horizontal: 22, vertical: 32),
    //             child: Column(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               crossAxisAlignment: CrossAxisAlignment.center,
    //               children: [
    //                 const HeaderWidget(title: 'Register'),
    //                 Container(
    //                   height: h / 6,
    //                   width: w / 1.4,
    //                   decoration: const BoxDecoration(
    //                     image: DecorationImage(
    //                       image: AssetImage("assets/while_transparent.png"),
    //                       fit: BoxFit.fill,
    //                     ),
    //                   ),
    //                 ),
    //                 const SizedBox(height: 15),
    //                 TextContainerWidget(
    //                   color: Colors.white,
    //                   controller: _nameController,
    //                   prefixIcon: Icons.person,
    //                   hintText: 'Name',
    //                 ),
    //                 const SizedBox(height: 10),
    //                 TextContainerWidget(
    //                   color: Colors.white,
    //                   keyboardType: TextInputType.emailAddress,
    //                   controller: _emailController,
    //                   prefixIcon: Icons.email,
    //                   hintText: 'Email',
    //                 ),
    //                 const SizedBox(height: 10),
    //                 TextPasswordContainerWidget(
    //                   keyboardType: TextInputType.visiblePassword,
    //                   controller: _passwordController,
    //                   prefixIcon: Icons.lock,
    //                   hintText: 'Password',
    //                 ),
    //                 SizedBox(
    //                   height: h * 0.045,
    //                 ),
    // RoundButton(
    //   loading: false,
    //   title: 'SignUp',
    //   onPress: () {
    //     if (_emailController.text.isEmpty) {
    //       Utils.flushBarErrorMessage(
    //           'Please enter email', context);
    //     } else if (_passwordController.text.isEmpty) {
    //       Utils.flushBarErrorMessage(
    //           'Please enter password', context);
    //     } else if (_passwordController.text.length < 6) {
    //       Utils.flushBarErrorMessage(
    //           'Please enter at least 6-digit password',
    //           context);
    //     } else {
    //       context
    //           .read<FirebaseAuthMethods>()
    //           .signInWithEmailAndPassword(
    //             _emailController.text.toString(),
    //             _passwordController.text.toString(),
    //             _nameController.text.toString(),
    //             context,
    //           );
    //       // Navigator.of(context).pop();
    //       Utils.toastMessage('Response submitted');
    //     }
    //   },
    // ),
    //                 SizedBox(
    //                   height: h * 0.02,
    //                 ),
    //                 Row(
    //                   children: [
    //                     const Text(
    //                       "Already have an account? ",
    //                       style: TextStyle(color: Colors.white),
    //                     ),
    //                     SizedBox(
    //                       width: h * 0.01,
    //                     ),
    //                     InkWell(
    //                       onTap: () {
    //                         Navigator.push(
    //                             context,
    //                             MaterialPageRoute(
    //                               builder: (context) => const LoginScreen(),
    //                             ));
    //                         // Navigator.of(context).pop();
    //                       },
    //                       child: const Text("Login",
    //                           style: TextStyle(
    //                             color: AppColors.theme1Color,
    //                           )),
    //                     ),
    //                   ],
    //                 )
    //               ],
    //             ),
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}
