import 'dart:developer';
import 'package:com.while.while_app/data/model/chat_user.dart';
import 'package:com.while.while_app/feature/comingsoon.dart';
import 'package:com.while.while_app/feature/reels/screens/reels_screen.dart';
import 'package:com.while.while_app/feature/social/screens/chat/message_home_widget.dart';
import 'package:com.while.while_app/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:com.while.while_app/providers/apis.dart';
import 'package:com.while.while_app/feature/creator/screens/create_screen.dart';
import 'package:com.while.while_app/feature/feedscreen/screens/feed_screen.dart';
import 'package:com.while.while_app/feature/profile/screens/user_profile_screen2.dart';
import 'package:com.while.while_app/feature/social/screens/social_home_screen.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'app_info_home.dart';
import 'core/constant.dart';
import 'feature/auth/controller/auth_controller.dart';
import 'providers/user_provider copy.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool blackColor = false;
  late TabController _controller;
  late final FirebaseMessaging _messaging;
  late final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  @override
  void initState() {
    final fireSevice = ref.read(apisProvider);
    _checkInitialMessage();

    log("initState called");
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (fireSevice.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          fireSevice.updateActiveStatus(1);
        }
        if (message.toString().contains('pause')) {
          fireSevice.updateActiveStatus(0);
        }
      }
      return Future.value(message);
    });
    super.initState();
    _controller = TabController(length: 5, vsync: this, initialIndex: 0);

    _messaging = FirebaseMessaging.instance;
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeNotification();
    _requestPermission();
    _handleForegroundNotifications();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('A new onMessageOpenedApp event was published!');
      // Navigate to desired screen based on message
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MessageHomeWidget(),
          ));
    });
  }

  void _checkInitialMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    log('initial message');

    if (initialMessage != null) {
      // Navigate to desired screen based on initialMessage
    }
  }

  void _initializeNotification() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings(
            '@mipmap/ic_launcher'); // Set your app icon here
    //const IOSInitializationSettings iosInitializationSettings = IOSInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      //iOS: iosInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _requestPermission() {
    _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  void _handleForegroundNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        _flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'channel_id',
              'channel_name',
              channelDescription: 'channel_description',
              icon: android.smallIcon,
              // other properties...
            ),
          ),
        );
      }
    });
  }

  final homeKey = GlobalKey();
  final videoKey = GlobalKey();
  final playKey = GlobalKey();
  final chatKey = GlobalKey();
  final profileKey = GlobalKey();

  late TutorialCoachMark tutorialCoachMark;

  void initAppTour() {
    final targets = addSiteTargetPage(
        homeKey: homeKey,
        videoKey: videoKey,
        playKey: playKey,
        chatKey: chatKey,
        profileKey: profileKey);
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
  }

  void _showTutorial(ChatUser user) {
    Future.delayed(const Duration(seconds: 1), () {
      tutorialCoachMark.show(context: context);
    });
    user.tourPage = user.tourPage + "${tourMap['HomeScreen']}";
    ref.read(userDataProvider).updateUserData(user);
  }

  @override
  Widget build(BuildContext context) {
    final ChatUser user = ref.watch(userDataProvider).userData!;
    bool isNewUser = ref.read(isNewUserProvider);
    Future.delayed(const Duration(seconds: 6), () {
      print("user id1: ${user.id}");

      // ref.watch(userDataProvider);
      print(
          "containing1 ${user.tourPage} $isNewUser ${user.tourPage.contains("${tourMap['HomeScreen']}")}");
      if (isNewUser || !user!.tourPage.contains("${tourMap['HomeScreen']}")) {
        print("entered");
        initAppTour();
        _showTutorial(user);
      }
    });

    return Scaffold(
      body: TabBarView(
        controller: _controller,
        children: [
          const FeedScreen(),
          CreateScreen(
            user: user,
          ),
          const ComingSoonPage(),
          //const ReelsScreentest(),
          const SocialScreen(),
          const ProfileScreen()
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.only(bottom: 2),
        color: !blackColor ? Colors.white : Colors.black,
        height: 50,
        child: TabBar(
          controller: _controller,
          indicatorColor: Colors.transparent,
          onTap: (index) {
            if (index == 2) {
              blackColor = true;
            } else {
              blackColor = false;
            }
            setState(() {});
          },
          tabs: [
            Tab(
              key: homeKey,
              icon: Icon(
                _controller.index == 0
                    ? FluentIcons.home_20_filled
                    : FluentIcons.home_20_regular,
                size: 30,
                color: !blackColor ? Colors.black : Colors.white,
              ),
            ),
            Tab(
              key: videoKey,
              icon: Icon(
                _controller.index == 1
                    ? FluentIcons.video_add_20_filled
                    : FluentIcons.video_add_20_regular,
                size: 30,
                color: !blackColor ? Colors.black : Colors.white,
              ),
            ),
            Tab(
                key: playKey,
                icon: Image.asset(
                  'assets/while_icon.png',
                  width: 70,
                  height: 27, // Dynamic width for the image
                )

                // Icon(
                //   _controller.index == 2
                //       ? FluentIcons.play_20_filled
                //       : FluentIcons.play_20_regular,
                //   size: 30,
                //   color: Colors.black,
                // ),
                ),
            Tab(
              key: chatKey,
              icon: Icon(
                _controller.index == 3
                    ? FluentIcons.chat_20_filled
                    : FluentIcons.chat_20_regular,
                size: 30,
                color: !blackColor ? Colors.black : Colors.white,
              ),
            ),
            Tab(
              key: profileKey,
              icon: Icon(
                _controller.index == 4
                    ? FluentIcons.person_20_filled
                    : FluentIcons.person_20_regular,
                size: 30,
                color: !blackColor ? Colors.black : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
