import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class UnderReviewScreen extends ConsumerStatefulWidget {
  const UnderReviewScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UnderReviewScreenState();
}

class _UnderReviewScreenState extends ConsumerState<UnderReviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your request is under review',
              style: GoogleFonts.ptSans(
                  color: Colors.lightBlueAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              "Thank you for submitting your request to become a counsellor. We're currently reviewing your submission and will notify you once the process is complete.",
              style: GoogleFonts.ptSans(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
