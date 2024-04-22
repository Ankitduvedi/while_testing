import 'package:com.while.while_app/feature/counsellor/screens/become_counsellor_screen.dart';
import 'package:com.while.while_app/feature/creator/screens/main_creator_screen.dart';
import 'package:com.while.while_app/feature/creator/screens/under_review_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:google_fonts/google_fonts.dart';

import '../../../providers/user_provider.dart';

class CounsellorScreen extends river.ConsumerStatefulWidget {
  const CounsellorScreen({Key? key}) : super(key: key);

  @override
  river.ConsumerState<CounsellorScreen> createState() =>
      _CounsellorScreenState();
}

class _CounsellorScreenState extends river.ConsumerState<CounsellorScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userDataProvider).userData;

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          centerTitle: false,
          title: Text('Welcome',
              style: GoogleFonts.ptSans(color: Colors.lightBlueAccent)),
        ),
        backgroundColor: Colors.white,
        body: (!user!.isCounsellor && !user.isCounsellorVerified)
            ? const BecomeCounsellor()
            : (!user.isCounsellor && user.isCounsellorVerified)
                ? const UnderReviewScreen(type: "Counsellor",)
                : const MainCreatorScreen());
  }
}
