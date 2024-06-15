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
import '../../auth/controller/auth_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final photosKey = GlobalKey();
  final profileKey = GlobalKey();
  final statsKey = GlobalKey();

  late TutorialCoachMark tutorialCoachMark;

  void initAppTour() {
    final targets = addProfileSiteTargetPage(
        photosKey: photosKey, profileKey: profileKey, statsKey: statsKey);
    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: const Color.fromARGB(255, 44, 121, 255),
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

    // ref.watch(userDataProvider);
<<<<<<< HEAD
    print("containing ${user?.name}");

    log("uid ${user?.id} ");

=======
    bool isNewUser = ref.read(isNewUserProvider);

>>>>>>> ac7aa5dc6505b46ea8468c7ae336332b2956f954
    if (user?.id != null &&
        user?.id != "" &&
        (!user!.tourPage.contains("${tourMap['UserProfileScreen2']}")) &&
        !isEntered) {
<<<<<<< HEAD
=======
      log("enteredprofile ${user.tourPage}  $isNewUser $isEntered");
>>>>>>> ac7aa5dc6505b46ea8468c7ae336332b2956f954
      initAppTour();
      _showTutorial(user);
    }

    var tabBarIcons = [
      Tab(
        key: photosKey,
        text: 'Loops',
      ),
      Tab(
        key: profileKey,
        text: 'Videos',
      ),
      Tab(
        key: statsKey,
        text: 'Dashboard',
      ),
    ];

    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   automaticallyImplyLeading: false,
        //   backgroundColor: Colors.white,
        //   title: Text(
        //     user!.name,
        //     style: GoogleFonts.ptSans(color: Colors.black),
        //   ),
        //   actions: [
        //     IconButton(
        //       iconSize: 25,
        //       onPressed: () {
        //         showModalBottomSheet(
        //           context: context,
        //           builder: (context) {
        //             return const MoreOptions();
        //           },
        //         );
        //       },
        //       icon: const Icon(
        //         Icons.settings,
        //         color: Colors.black,
        //       ),
        //     ),
        //   ],
        // ),
        backgroundColor: Colors.white,
<<<<<<< HEAD
        title: Text(
          user?.name ?? "",
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
                      user: user!,
                    )),
                    Center(
                        child: CreatorProfileVideo(
                      user: user!,
                    )),
                    const Center(child: LeaderboardScreen()),
                  ],
=======
        body: DefaultTabController(
          length: 3,
          child: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverList(
                delegate: SliverChildListDelegate(
                  [const ProfileDataWidget()],
>>>>>>> ac7aa5dc6505b46ea8468c7ae336332b2956f954
                ),
              ),
            ],
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Material(
                  color: Colors.white,
                  child: TabBar(
                      padding: const EdgeInsets.all(0),
                      //indicatorColor: const Color.fromARGB(255, 131, 85, 205),
                      labelColor: const Color.fromARGB(255, 196, 68, 216),
                      unselectedLabelColor: Colors.black,
                      labelStyle: GoogleFonts.urbanist(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                      unselectedLabelStyle: GoogleFonts.urbanist(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                      tabs: tabBarIcons,
                      indicator: CurvedGradientTabIndicator(
                          gradient: const LinearGradient(
                        colors: [
                          Color.fromRGBO(230, 77, 255, 1),
                          Color.fromRGBO(123, 68, 212, 1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ))),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      Center(
                          child: CreatorProfile(
                        user: user!,
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
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  final String text;
  final Gradient gradient;
  final TextStyle style;

  const GradientText({
    required this.text,
    required this.gradient,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: GoogleFonts.urbanist(
            fontWeight: FontWeight.w600, fontSize: 20, color: Colors.white),
      ),
    );
  }
}

class CurvedGradientTabIndicator extends Decoration {
  final BoxPainter _painter;

  CurvedGradientTabIndicator({required Gradient gradient})
      : _painter = _CurvedGradientPainter(gradient);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _painter;
}

class _CurvedGradientPainter extends BoxPainter {
  final Gradient gradient;

  _CurvedGradientPainter(this.gradient);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Paint paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(
          offset.dx,
          configuration.size!.height - 4, // Increased height
          configuration.size!.width * 1.4, // Reduced width
          12, // Increased height
        ),
      );
    final Rect rect = Offset(
          offset.dx + (configuration.size!.width * -.2), // Centered
          offset.dy + configuration.size!.height - 4, // Adjusted height
        ) &
        Size(configuration.size!.width * 1.4, 4); // Adjusted size
    final RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(16));
    canvas.drawRRect(rrect, paint);
  }
}
