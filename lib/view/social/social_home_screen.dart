import 'dart:developer';
import 'package:com.example.while_app/main.dart';
import 'package:com.example.while_app/resources/components/communities/add_community_widget.dart';
import 'package:com.example.while_app/resources/components/message/apis.dart';
import 'package:com.example.while_app/resources/components/message/message_home_widget.dart';
import 'package:com.example.while_app/view/social/connect_screen.dart';
import 'package:com.example.while_app/view/social/notification.dart';
import 'package:com.example.while_app/view/social/status_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../resources/components/communities/community_home_screen.dart';

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
  bool isSearching = false;
  bool isSearchingHasValue = false;
  var value = '';

  late final FirebaseMessaging _messaging;
  late final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
    _messaging = FirebaseMessaging.instance;
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeNotification();
    _requestPermission();
    _handleForegroundNotifications();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      // Navigate to desired screen based on message
    });

    _checkInitialMessage();
    // listUsersFollowers();
    // refreshFunc();

    _controller = TabController(length: 4, vsync: this, initialIndex: 1);
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        //backgroundColor: Colors.blue,

        appBar: AppBar(
          toolbarHeight: 30,
          backgroundColor: Colors.black,
          title: isSearching
              ? TextField(
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Name, Email, ...',
                      hintStyle: TextStyle(
                        color: Color.fromARGB(142, 73, 73, 73),
                      )),
                  autofocus: true,
                  style: const TextStyle(
                      fontSize: 17, letterSpacing: 0.5, color: Colors.white),
                  //when search text changes then updated search list
                  onChanged: (val) {
                    //search logic
                    setState(() {
                      value = val;
                      isSearchingHasValue = isSearching;
                    });
                  },
                )
              : const Text(
                  'Social',
                  style: TextStyle(color: Colors.white),
                ),
          actions: [
            IconButton(
                onPressed: () {
                  AddCommunityScreen().addCommunityDialog(context);
                },
                icon: const Icon(
                  Icons.group_add,
                  color: Colors.white,
                )),
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => const NotificationScreen()));
                },
                icon: const Icon(
                  Icons.notifications,
                  color: Colors.white,
                )),
            IconButton(
                onPressed: () {
                  // Navigator.of(context)
                  //   .push(MaterialPageRoute(builder: (ctx) => SearchPage()));
                  setState(() {
                    isSearching = !isSearching;
                  });
                },
                icon: const Icon(
                  Icons.search,
                  color: Colors.white,
                )),
            PopupMenuButton(
                color: Colors.white,
                elevation: 10,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(15),
                  ),
                ),
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem(
                      textStyle: TextStyle(color: Colors.white),
                      value: "newgroup",
                      child: Text('New Group',
                          style: TextStyle(
                            color: Colors.black,
                          )),
                    ),
                    PopupMenuItem(
                      child: const Text('New community',
                          style: TextStyle(color: Colors.black)),
                      onTap: () {
                        log('pop up button pressed');
                        AddCommunityScreen().addCommunityDialog(context);
                      },
                    ),
                    const PopupMenuItem(
                        child: Text(
                      'New Group',
                      style: TextStyle(color: Colors.black),
                    )),
                    const PopupMenuItem(
                        child: Text(
                      'New Group',
                      style: TextStyle(color: Colors.black),
                    )),
                  ];
                })
          ],
          bottom: TabBar(
            dividerColor: Colors.transparent,
            controller: _controller,
            tabAlignment: TabAlignment.center,
            indicatorColor: Colors.white,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
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
            CommunityScreenFinal(
              isSearching: false,
              value: 'value',
            ),
            StatusScreenn(),
          ],
        ),
      ),
    );
  }
}
