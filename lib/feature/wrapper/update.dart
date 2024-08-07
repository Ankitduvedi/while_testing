import 'dart:io';
 import 'package:flutter/material.dart';
 import 'package:url_launcher/url_launcher.dart';

class UpdateAppScreen extends StatefulWidget {
  const UpdateAppScreen({super.key});

  @override
  State<UpdateAppScreen> createState() => _UpdateAppScreenState();
}

class _UpdateAppScreenState extends State<UpdateAppScreen> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFF15181e),
      body: SafeArea(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.downloading_rounded,
              color: Colors.white,
              size: screenHeight * 0.2,
            ),
            SizedBox(
              height: screenHeight * 0.02,
            ),
            Text(
              "Update",
              style:
                  TextStyle(color: Colors.white, fontSize: screenHeight * 0.05),
            ),
            Text(
              "available!",
              style:
                  TextStyle(color: Colors.white, fontSize: screenHeight * 0.05),
            ),
            SizedBox(
              height: screenHeight * 0.01,
            ),
            Text(
                "New version of app is available, please\n              update your application!",
                style: TextStyle(
                    color: Colors.white, fontSize: screenHeight * 0.018)),
            SizedBox(
              height: screenHeight * 0.025,
            ),
            TextButton(
                style: ButtonStyle(
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(
                    screenHeight * 0.05,
                  ),
                ))),
                onPressed: () {
                  if (Platform.isIOS) {
                  } else {
                    launchUrl(Uri.parse(
                        "https://play.google.com/store/apps/details?id=com.while.while_app&hl=en&gl=US"));
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                  child: Text(
                    "Update Now",
                    style: TextStyle(
                        fontSize: screenHeight * 0.025, color: Colors.white),
                  ),
                ))
          ],
        ),
      )),
    );
  }
}
