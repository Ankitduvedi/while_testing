import 'dart:developer';
import 'package:com.while.while_app/feature/social/screens/chat/message_home_widget.dart';
import 'package:com.while.while_app/main.dart';
import 'package:com.while.while_app/providers/apis.dart';
import 'package:com.while.while_app/providers/user_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavBar extends ConsumerStatefulWidget {
  final Widget childScreen;
  const ScaffoldWithNavBar({required this.childScreen, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends ConsumerState<ScaffoldWithNavBar> with TickerProviderStateMixin {
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/');
      case 1:
        GoRouter.of(context).go('/creatorScreen/:user');
      case 2:
        GoRouter.of(context).go('/reelsScreen');
      case 3:
        GoRouter.of(context).go('/socials');
      case 4:
        GoRouter.of(context).go('/account');
    }
  }

  bool blackColor = false;
  TabController? _controller;
  FirebaseMessaging? _messaging;
  FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;

  @override
  void initState() {
    final fireSevice = ref.read(apisProvider);
    _checkInitialMessage();
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
      context.push('/messageHomeWidgetScreen');
    });
  }

  void _checkInitialMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      // Navigate to desired screen based on initialMessage
    }
  }

  void _initializeNotification() async {
    const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher'); // Set your app icon here
    //const IOSInitializationSettings iosInitializationSettings = IOSInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      //iOS: iosInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin!.initialize(initializationSettings);
  }

  void _requestPermission() {
    _messaging!.requestPermission(
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
        _flutterLocalNotificationsPlugin!.show(
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

  @override
  Widget build(BuildContext context) {
    ref.watch(userDataProvider).userData!;

    return Scaffold(
      body: SafeArea(bottom: false, child: widget.childScreen),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.only(bottom: 2),
        color: !blackColor ? Colors.white : Colors.black,
        height: 50,
        child: TabBar(
          controller: _controller,
          indicatorColor: Colors.transparent,
          onTap: (index) {
            _onItemTapped(index, context);
            if (index == 2) {
              blackColor = true;
            } else {
              blackColor = false;
            }
            setState(() {});
          },
          tabs: [
            Tab(
              // key: homeKey,
              icon: Icon(
                _controller!.index == 0 ? FluentIcons.home_20_filled : FluentIcons.home_20_regular,
                size: 30,
                color: !blackColor ? Colors.black : Colors.white,
              ),
            ),
            Tab(
              // key: videoKey,
              icon: Icon(
                _controller!.index == 1 ? FluentIcons.video_add_20_filled : FluentIcons.video_add_20_regular,
                size: 30,
                color: !blackColor ? Colors.black : Colors.white,
              ),
            ),
            Tab(
                // key: playKey,
                icon: Image.asset(
              'assets/while_icon.png',
              width: 70,
              height: 27, // Dynamic width for the image
            )),
            Tab(
              // key: chatKey,
              icon: Icon(
                _controller!.index == 3 ? FluentIcons.chat_20_filled : FluentIcons.chat_20_regular,
                size: 30,
                color: !blackColor ? Colors.black : Colors.white,
              ),
            ),
            Tab(
              // key: profileKey,
              icon: Icon(
                _controller!.index == 4 ? FluentIcons.person_20_filled : FluentIcons.person_20_regular,
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
