import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
import 'package:com.while.while_app/feature/creator/controller/creator_contoller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class BecomeCreator extends ConsumerStatefulWidget {
  final TextEditingController instagramController;
  final TextEditingController youtubeController;
  const BecomeCreator(
      {super.key,
      required this.instagramController,
      required this.youtubeController});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BecomeCreatorState();
}

class _BecomeCreatorState extends ConsumerState<BecomeCreator> {
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(creatorControllerProvider);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Become Creator',
            style: GoogleFonts.ptSans(
                color: Colors.lightBlueAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: widget.instagramController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Instagram Link',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: widget.youtubeController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'YouTube Link',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              // Add your submission logic here
              ref
                  .watch(creatorControllerProvider.notifier)
                  .submitCreatorRequest(
                      ref.read(userProvider)!.id,
                      widget.instagramController.text.trim(),
                      widget.youtubeController.text.trim());
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent),
            child: isLoading
                ? const CircularProgressIndicator()
                : const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
