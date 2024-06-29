import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/route_manager.dart';
import 'package:com.while.while_app/core/routes/routes_name.dart';
import 'package:com.while.while_app/feature/wrapper/wrapper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'core/routes/routes.dart';
import 'package:get/get.dart';

late Size mq;
String? activeChatUserId;

activechatid(WidgetRef ref, String id) {
  log('activechatid $id');
  FirebaseFirestore.instance
      .collection('users')
      .doc(id)
      .update({'isChattingWith': 'activeChatUserId'});
}

final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.light,
    seedColor: const Color.fromARGB(255, 131, 57, 0),
  ),
  textTheme: GoogleFonts.latoTextTheme(),
);

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _initializeFirebase();
  runApp(const ProviderScope(child: MyApp()));
}

Future<void> _initializeFirebase() async {
  var result = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'For showing notification',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'WHILE',
  );
  // Optionally print the result
  await initDynamicLinks();
}

Future<void> initDynamicLinks() async {
  log('Initializing Dynamic Links in main dart');

  // Handle dynamic links when the app is already running
  FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
    _handleDynamicLink(dynamicLinkData);
  });

  // Handle dynamic links when the app is not running
  final PendingDynamicLinkData? initialLink =
      await FirebaseDynamicLinks.instance.getInitialLink();
  if (initialLink != null) {
    _handleDynamicLink(initialLink);
  }
}

Future<void> updateReferralPoints(String userId) async {
  final CollectionReference referralCollection =
      FirebaseFirestore.instance.collection('referral');

  await referralCollection.doc(userId).set({
    'points': FieldValue.increment(1),
  }, SetOptions(merge: true));
}

void _handleDynamicLink(PendingDynamicLinkData dynamicLinkData) {
  final Uri deepLink = dynamicLinkData.link;
  log('Dynamic link: $deepLink');
  final route = deepLink.queryParameters['screen'];
  final url = deepLink.queryParameters['url'];
  final String? referralCode = deepLink.queryParameters['referralCode'];
  if (referralCode != null) {
    updateReferralPoints(referralCode);
    return;
  }

  if (route != null) {
    log('Navigating to $route with parameter: $url');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.toNamed(
        route,
      );
    });
  } else {
    log('Invalid dynamic link');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
        systemStatusBarContrastEnforced: false);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);

    return MaterialApp(
      theme: theme,
      routes: {
        '/profile': (BuildContext context) => const HomeScreen(),
      },
      title: 'While',
      debugShowCheckedModeBanner: false,
      initialRoute: RoutesName.wrapper,
      onGenerateRoute: Routes.generateRoute,
      home: const Wrapper(),
    );
  }
}
