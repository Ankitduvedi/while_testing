import 'package:com.while.while_app/feature/creator/screens/become_creator_screen.dart';
import 'package:com.while.while_app/feature/creator/screens/main_creator_screen.dart';
import 'package:com.while.while_app/feature/creator/screens/under_review_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:google_fonts/google_fonts.dart';

import '../../../providers/user_provider.dart';

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
    final user = ref.watch(userDataProvider).userData;

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          centerTitle: false,
          title: Text('Studio',
              style: GoogleFonts.ptSans(color: Colors.lightBlueAccent)),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            child: (!user!.isContentCreator && !user.isApproved)
                ? BecomeCreator(
                    instagramController: _instagramController,
                    youtubeController: _youtubeController,
                  )
                : (!user.isContentCreator && user.isApproved)
                    ? const UnderReviewScreen()
                    : const MainCreatorScreen()));
  }
}
