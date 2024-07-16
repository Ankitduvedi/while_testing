import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class UnderReviewScreen extends ConsumerStatefulWidget {
  final String type;
  const UnderReviewScreen({super.key, required this.type});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UnderReviewScreenState();
}

class _UnderReviewScreenState extends ConsumerState<UnderReviewScreen> {
  @override
  Widget build(BuildContext context) {
    log('under review screen');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 130,
            ),
            Image.asset('assets/under_review.png',
                width: 280 // Dynamic width for the image
                ),
            SizedBox(
              width: 270,
              child: Text(
                'Congratulation',
                style: GoogleFonts.spaceGrotesk(
                    color: const Color.fromARGB(255, 218, 76, 250),
                    fontSize: 36,
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 270,
              child: Text(
                "Thank you for submitting your request. We're currently reviewing your submission and will notify you once the process is complete.",
                style: GoogleFonts.spaceGrotesk(
                    color: const Color.fromARGB(255, 128, 128, 128),
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
