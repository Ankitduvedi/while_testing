import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroPage4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0, 150, 0, 0),
              child: Image.asset(
                'assets/Picture4.png', // Replace with your image asset name
                width: MediaQuery.of(context).size.width,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 200),
              child: Column(
                children: <Widget>[
                  Text(
                    'Stay undistracted !',
                    style:  GoogleFonts.ptSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Achieve Laser - like Focus with a dedicated learning Oasis .',
                    textAlign: TextAlign.center,
                    style:  GoogleFonts.ptSans(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
