import 'dart:developer';
import 'package:com.while.while_app/data/model/chat_user.dart';
import 'package:com.while.while_app/feature/profile/screens/creator_profile_widget%20copy.dart';
import 'package:com.while.while_app/feature/profile/app_tour_profile.dart';
import 'package:com.while.while_app/providers/user_provider%20copy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:com.while.while_app/feature/profile/screens/bottom_options_sheet.dart';
import 'package:com.while.while_app/feature/profile/screens/user_leaderboard_screen.dart';
import 'package:com.while.while_app/feature/profile/screens/creator_profile_widget.dart';
import 'package:com.while.while_app/feature/profile/screens/profile_data_widget2.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../core/constant.dart';
import '../../../providers/user_provider.dart';
import '../../auth/controller/auth_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  final photosKey = GlobalKey();
  final profileKey = GlobalKey();
  final statsKey = GlobalKey();

  late TutorialCoachMark tutorialCoachMark;

  void initAppTour() {
    final targets = addProfileSiteTargetPage(
        photosKey: photosKey, profileKey: profileKey, statsKey: statsKey);
    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.blueAccent,
      hideSkip: false,
      textSkip: 'SKIP',
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () {
        log('finish');
      },
      onClickTarget: (target) {
        log(target.toString());
      },
    );
    setState(() {
      isEntered = true;
    });
  }

  void _showTutorial(ChatUser user) {
    Future.delayed(const Duration(seconds: 1), () {
      tutorialCoachMark.show(context: context);
    });
    user.tourPage = user.tourPage + "${tourMap['UserProfileScreen2']}";
    ref.read(userDataProvider).updateUserData(user);
  }

  bool isEntered = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userDataProvider).userData;
    print("user id1: ${user?.id}");

    // ref.watch(userDataProvider);
    print("containing ${user?.name}");
    bool isNewUser = ref.read(isNewUserProvider);

    print("containing ${user!.tourPage} $isNewUser $isEntered");
    print("home screen2 $isNewUser");
    if (user?.id != null &&
        user?.id != "" &&
        (!user!.tourPage.contains("${tourMap['UserProfileScreen2']}")) &&
        !isEntered) {
      log("enteredprofile ${user?.tourPage}  $isNewUser $isEntered");
      initAppTour();
      _showTutorial(user);
    }

    log(user.id);

    var tabBarIcons = [
      Tab(
        key: photosKey,
        icon: Icon(
          Icons.photo_outlined,
          color: Colors.blueGrey,
          size: 30,
        ),
      ),
      Tab(
        key: profileKey,
        icon: Icon(
          Icons.person,
          color: Colors.blueGrey,
          size: 30,
        ),
      ),
      Tab(
        key: statsKey,
        icon: Icon(
          Icons.brush,
          color: Colors.blueGrey,
          size: 30,
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Text(
          user.name,
          style: GoogleFonts.ptSans(color: Colors.black),
        ),
        actions: [
          IconButton(
            iconSize: 35,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return const MoreOptions();
                },
              );
            },
            icon: const Icon(
              Icons.more_vert,
              color: Colors.black,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverList(
              delegate: SliverChildListDelegate(
                [const ProfileDataWidget()],
              ),
            ),
          ],
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Material(
                color: Colors.white,
                child: TabBar(
                  padding: EdgeInsets.all(0),
                  indicatorColor: Colors.black,
                  tabs: tabBarIcons,
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    Center(
                        child: CreatorProfile(
                      user: user,
                    )),
                    Center(
                        child: CreatorProfileVideo(
                      user: user,
                    )),
                    const Center(child: LeaderboardScreen()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
