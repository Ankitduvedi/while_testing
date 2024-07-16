import 'dart:developer';
import 'dart:io';
import 'dart:math' as maths;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/route_manager.dart';
import 'package:com.while.while_app/core/routes/routes_name.dart';
import 'package:com.while.while_app/feature/wrapper/wrapper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart';
import 'chatfiledb.dart';
import 'firebase_options.dart';
import 'core/routes/routes.dart';
import 'package:get/get.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async' as async;

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
  print("called main");
  DatabaseHelper db = DatabaseHelper();
  await db.requestPermissions();

  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );
  Workmanager().registerPeriodicTask(
    "1",
    "fetchAndBackupTask",
    frequency: Duration(minutes: 15), // Adjust the frequency as needed
  );
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
  // log('Initializing Dynamic Links in main dart');
  //
  // // Handle dynamic links when the app is already running
  // FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
  //   _handleDynamicLink(dynamicLinkData);
  // });

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

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
    } catch (e) {
      print("error is $e");
    }
    async.Timer _timer = async.Timer.periodic(Duration(seconds: 1), (timer) {
      print("called periodic ${timer.tick}");
      String title =
          timer.tick == 100 ? 'Backup Completed' : 'Backup in Progress';
      String body = timer.tick == 100
          ? 'Your messages have been backed up successfully.'
          : 'Your messages are being backed up. Progress: ${timer.tick}%';
      print("called fetchAndBackupTask1");
      showNotification(title, body, timer.tick);
      if (timer.tick == 100) {
        timer.cancel();
      }
    });
    print("called fetchAndBackupTask");

    return Future.value(true);
  });
}


Future<void> backupDatabase() async {
  String basepath = "/storage/emulated/0/Download/";
  String dbPath = join(basepath, 'messages.db');

  String backupPath = join(basepath, 'backup.db');
  try {
    File dbFile = File(dbPath);
    await dbFile.copy(backupPath);
  } catch (e) {
    print("err is $e");
  }
}

Future<void> showNotification(String title, String body, int progress) async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  try {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      maths.Random.secure().nextInt(100000).toString(),
      "High Importance",
      importance: Importance.max,
    );
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channel.id,
      channel.name,
      onlyAlertOnce: true,
      channelDescription: "My Channel",
      showProgress: true,
      progress: progress,
      importance: Importance.high,
      priority: Priority.high,
      ticker: "ticker",
      icon: "launcher_icon",
      showWhen: false,
      maxProgress: 100,
    );

    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    Future.delayed(Duration.zero, () async {
      await flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        platformChannelSpecifics,
        payload: 'item x',
      );
    });
    if (progress == 100) {
      async.Future.delayed(const Duration(seconds: 5), () async {
        await flutterLocalNotificationsPlugin.cancel(0);
        await flutterLocalNotificationsPlugin.cancelAll();
      });
    }
  } catch (e) {
    print("error show show is $e");
  }
}
