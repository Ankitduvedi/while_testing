import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
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
import 'view/profile/user_profile_screen.dart';
import 'package:get/get.dart';

// final userProvider = river.StreamProvider((ref) {
//   return FirebaseFirestore.instance
//       .collection('users')
//       .doc(APIs.me.id)
//       .snapshots();
// });
late Size mq;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  _initializeFirebase();
  initDynamicLinks();
  Provider.debugCheckInvalidValueType = null;
  runApp(const river.ProviderScope(child: MyApp()));
}

class MyApp extends river.ConsumerWidget {
  //final DeepLinkHandler _deepLinkHandler = DeepLinkHandler();
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
//     Get.config(
//   defaultTransition: Transition.fade,
//   defaultGlobalState: true,
//   defaultOpaqueRoute: Get.isOpaqueRouteDefault,
//   defaultPopGesture: Get.isPopGestureEnable,
//   defaultDurationTransition: Get.defaultDurationTransition,
//   defaultGlobalStateManagement: Get.defaultGlobalStateManagement,
//   defaultPreventAnimation: Get.isPreventAnimationDefault,
// );
    return MultiProvider(
      providers: providersList,
      child: GetMaterialApp(
        routes: {'/screen': (BuildContext context) => const ProfileScreen()},
        title: 'While',
        debugShowCheckedModeBanner: false,
        initialRoute: RoutesName.splash,
        onGenerateRoute: Routes.generateRoute,
        home: const Wrapper(),
      ),
    );
  }
}

_initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  var result = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'For showing notification',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'WHILE',
  );
  // print(result);
}

void initDynamicLinks() async {
  // FirebaseDynamicLinks.instance.onLink(
  //   onSuccess: (PendingDynamicLinkData? dynamicLink) async {
  //     final Uri? deeplink = dynamicLink?.link;
  //     if (deeplink != null) {
  //       Get.toNamed(deeplink.queryParameters.values.first);
  //       // print("deeplink");
  //     }
  //   },
  //   onError: (OnLinkErrorException e) async {
  //     print(e.message);
  //   },
  // );
  log('////initDyanamic ');
  FirebaseDynamicLinks.instance
      .getInitialLink()
      .then((PendingDynamicLinkData? dynamicLink) {
    final Uri? deepLink = dynamicLink?.link;
    if (deepLink != null) {
      //Get.toNamed(deepLink.queryParameters.values.first);
      Get.toNamed(deepLink.queryParameters['screen'] ?? '/');
      log(deepLink.toString());
      print(deepLink.toString());
      // Handle the initial deep link as needed
    }
  });
}
