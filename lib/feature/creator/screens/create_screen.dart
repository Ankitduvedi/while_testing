import 'package:com.while.while_app/feature/creator/controller/creator_contoller.dart';
import 'package:com.while.while_app/feature/creator/screens/become_creator_screen.dart';
import 'package:com.while.while_app/feature/creator/screens/main_creator_screen.dart';
import 'package:com.while.while_app/feature/creator/screens/under_review_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateScreen extends river.ConsumerStatefulWidget {
  const CreateScreen({Key? key}) : super(key: key);

  @override
  river.ConsumerState<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends river.ConsumerState<CreateScreen> {
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
    final userStream = ref.watch(getUserStreamProvider);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text('Studio',
            style: GoogleFonts.ptSans(color: Colors.lightBlueAccent)),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: userStream.when(
          data: (DocumentSnapshot snapshot) {
            Map<String, dynamic> userData =
                snapshot.data() as Map<String, dynamic>;
            bool isContentCreator = userData['isContentCreator'] ?? false;
            bool isApproved = userData['isApproved'] ?? false;
            if (!isContentCreator && !isApproved) {
              return BecomeCreator(
                instagramController: _instagramController,
                youtubeController: _youtubeController,
              );
            } else if (!isContentCreator && isApproved) {
              return const UnderReviewScreen();
            } else {
              return const MainCreatorScreen();
            }
          },
          error: (error, stackTrace) => Text(error.toString()),
          loading: () => const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
