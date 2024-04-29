import 'package:com.while.while_app/feature/creator/screens/become_creator_screen.dart';
import 'package:com.while.while_app/feature/creator/screens/main_creator_screen.dart';
import 'package:com.while.while_app/feature/creator/screens/under_review_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;

import '../../../providers/user_provider.dart';

class CreateScreen extends river.ConsumerStatefulWidget {
  const CreateScreen({Key? key}) : super(key: key);

  @override
  river.ConsumerState<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends river.ConsumerState<CreateScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userDataProvider).userData;

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          centerTitle: false,
          title: Text(
            'Studio',
            style:
                TextStyle(color: Colors.blue[400], fontWeight: FontWeight.w800),
          ),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            child: (user!.isContentCreator == 0 && user.isApproved == 0)
                ? const BecomeCreator()
                : (user.isContentCreator == 0 && user.isApproved == 1)
                    ? const UnderReviewScreen(
                        type: "Creator",
                      )
                    : const MainCreatorScreen()));
  }
}
