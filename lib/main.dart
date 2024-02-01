import 'dart:developer';
import 'package:com.example.while_app/resources/components/message/apis.dart';
import 'package:com.example.while_app/view/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
import 'package:com.example.while_app/utils/routes/routes_name.dart';
import 'package:com.example.while_app/view_model/providers/providers_list.dart';
import 'package:com.example.while_app/view_model/wrapper/wrapper.dart';
import 'firebase_options.dart';
import 'utils/routes/routes.dart';
import 'package:get/get.dart';

late Size mq;

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Provider.debugCheckInvalidValueType = null;
  await _initializeFirebase();
  runApp(const river.ProviderScope(child: MyApp()));
}

Future<void> _initializeFirebase() async {
  var result = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'For showing notification',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'WHILE',
  );
  // Optionally print the result
  // print(result);
  await initDynamicLinks();
}

Future<void> initDynamicLinks() async {
  log('Initializing Dynamic Links');

  // Handle dynamic links when the app is already running
  FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
    _handleDynamicLink(dynamicLinkData);
  });

  // Handle dynamic links when the app is not running
  final PendingDynamicLinkData? initialLink =
      await FirebaseDynamicLinks.instance.getInitialLink();
  if (initialLink != null) {
    APIs.getSelfInfo();
    _handleDynamicLink(initialLink);
  }
}

void _handleDynamicLink(PendingDynamicLinkData dynamicLinkData) {
  final Uri deepLink = dynamicLinkData.link;
  final route = deepLink.queryParameters['screen'];
  final url = deepLink.queryParameters['url'];

  if (route != null) {
    log('Navigating to $route with parameter: $url');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.toNamed(
        route,
        //arguments: url ?? '', // Ensure you pass the parameters
      );
    });
  } else {
    log('Invalid dynamic link');
  }
}

class MyApp extends river.ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, river.WidgetRef ref) {
    mq = MediaQuery.of(context).size;
    SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);

    return MultiProvider(
      providers: providersList,
      child: GetMaterialApp(
        routes: {
          '/profile': (BuildContext context) => const HomeScreen(),
          // Add other routes as needed
        },
        title: 'While',
        debugShowCheckedModeBanner: false,
        initialRoute: RoutesName.splash,
        onGenerateRoute: Routes.generateRoute,
        home: const Wrapper(),
      ),
    );
  }
}
