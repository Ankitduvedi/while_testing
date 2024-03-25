import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class IntroPage1 extends StatelessWidget {
  const IntroPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
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
                  'Seize every second !',
                  style: GoogleFonts.ptSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Make your day count with our expert guided journey .',
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
    );
  }
}
