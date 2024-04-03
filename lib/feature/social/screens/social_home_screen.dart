import 'dart:developer';
import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
import 'package:com.while.while_app/main.dart';
import 'package:com.while.while_app/feature/social/screens/community/community_home_widget.dart';
import 'package:com.while.while_app/feature/social/screens/chat/message_home_widget.dart';
import 'package:com.while.while_app/feature/social/screens/connect/connect_screen.dart';
import 'package:com.while.while_app/feature/social/screens/status/status_screen.dart';
import 'package:com.while.while_app/feature/social/controller/connect_users_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class SocialScreen extends ConsumerStatefulWidget {
  const SocialScreen({super.key});

  @override
  ConsumerState<SocialScreen> createState() {
    return _SocialScreenState();
  }
}

class _SocialScreenState extends ConsumerState<SocialScreen>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  late final FirebaseMessaging _messaging;
  late final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();

    _messaging = FirebaseMessaging.instance;
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeNotification();
    _requestPermission();
    _handleForegroundNotifications();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('A new onMessageOpenedApp event was published!');
      // Navigate to desired screen based on message
    });

    _checkInitialMessage();
    _controller = TabController(length: 4, vsync: this, initialIndex: 1);
    _controller.addListener(() {
      // Check if the controller index is changing, if you need this check
      if (!_controller.indexIsChanging) {
        updateSearchToggleBasedOnTab(_controller.index);
      }
    });
  }

  void updateSearchToggleBasedOnTab(int index) {
    // Logic to update searchToggle based on the tab index
    // For example, you might want to disable search on certain tabs
    if (ref.watch(toggleSearchStateProvider.notifier).state != 0) {
      // Assuming you want the search toggle active on the second tab
      ref.read(toggleSearchStateProvider.notifier).state = index + 1;
    }
    // else {
    //   ref.read(toggleSearchStateProvider.notifier).state = 0;
    //   ref.read(searchQueryProvider.notifier).state =
    //       ''; // Optionally clear search query
    // }
  }

  void _checkInitialMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

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

  @override
  Widget build(BuildContext context) {
    var toogleSearch = ref.watch(toggleSearchStateProvider);
    var searchValue = ref.watch(searchQueryProvider.notifier);
    log('toggleSearchStateProvider');

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 45,
          backgroundColor: Colors.white,
          title: toogleSearch != 0
              ? TextField(
                  onChanged: (value) => searchValue.state = value,
                  decoration: InputDecoration(
                      labelText: 'Search', labelStyle: GoogleFonts.ptSans()
                      //suffixIcon: Icon(Icons.search),
                      ),
                  style: GoogleFonts.ptSans(color: Colors.black),
                )
              : Text(
                  '',
                  style: GoogleFonts.ptSans(color: Colors.black),
                ),
          actions: [
            IconButton(
              onPressed: () {
                final currentToggleSearch = ref.read(toggleSearchStateProvider);
                if (currentToggleSearch != 0) {
                  ref.read(searchQueryProvider.notifier).state =
                      ''; // Clear search query
                  ref.read(toggleSearchStateProvider.notifier).state =
                      0; // Disable search
                } else {
                  ref.read(toggleSearchStateProvider.notifier).state =
                      _controller.index + 1; // Enable search
                }
              },
              icon: Icon(
                toogleSearch != 0 ? CupertinoIcons.xmark : Icons.search_rounded,
                color: Colors.black,
              ),
            ),
          ],
          bottom: TabBar(
            dividerColor: Colors.transparent,
            controller: _controller,
            tabAlignment: TabAlignment.center,
            indicatorColor: Colors.black,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.black,
            labelStyle:
                GoogleFonts.ptSans(fontWeight: FontWeight.bold, fontSize: 15),
            tabs: const [
              Tab(
                text: 'Connect   ',
              ),
              Tab(
                text: 'Chats  ',
              ),
              Tab(
                text: 'Community',
              ),
              Tab(
                text: '    Status',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _controller,
          children: const [
            ConnectScreen(),
            MessageHomeWidget(),
            CommunityHomeWidget(),
            StatusScreenState(),
          ],
        ),
      ),
    );
  }
}
