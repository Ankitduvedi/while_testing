import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroPage5 extends StatelessWidget {
  const IntroPage5({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 150, 0, 0),
              child: Image.asset(
                'assets/Picture1.png', // Replace with your image asset name
                width: MediaQuery.of(context).size.width,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 200),
              child: Column(
                children: <Widget>[
                  Text(
                    'The Future of Social Engagement',
                    style: GoogleFonts.ptSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Revolutionizing the way you interact, share, and discover.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ptSans(
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
