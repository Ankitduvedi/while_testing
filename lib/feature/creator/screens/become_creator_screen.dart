import 'dart:developer';

import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
import 'package:com.while.while_app/feature/creator/controller/creator_contoller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class BecomeCreator extends ConsumerStatefulWidget {
  const BecomeCreator({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BecomeCreatorState();
}

class _BecomeCreatorState extends ConsumerState<BecomeCreator> {
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _youtubeController = TextEditingController();

  @override
  void dispose() {
    _instagramController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log('become creator screen');
    final isLoading = ref.watch(creatorControllerProvider);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Become Creator',
            style: GoogleFonts.ptSans(
                color: Colors.blue[400],
                fontSize: 24,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _instagramController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Instagram Link',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _youtubeController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'YouTube Link',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              // Check if the text fields are empty
              if (_instagramController.text.trim().isEmpty ||
                  _youtubeController.text.trim().isEmpty) {
                // Show an error message if any field is empty
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all fields.'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                // Proceed with submitting the form
                ref
                    .watch(creatorControllerProvider.notifier)
                    .submitCreatorRequest(
                        ref.read(userProvider)!.id,
                        _instagramController.text.trim(),
                        _youtubeController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue[400], // Text and icon color if used
              shadowColor: Colors.blue[200], // Shadow color
              elevation: 10, // Shadow elevation
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // Rounded corners
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 30, vertical: 15), // Button padding
            ),
            child: isLoading
                ? const CircularProgressIndicator()
                : const Text(
                    'Submit',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
          ),
        ],
      ),
    );
  }
}
