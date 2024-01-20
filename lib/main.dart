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
        routes: {'/profile': (BuildContext context) => const ProfileScreen()},
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
  log('////initDyanamic ');
  FirebaseDynamicLinks.instance.onLink.listen(
    (pendingDynamicLinkData) {
      // Set up the `onLink` event listener next as it may be received here
      final route =
          pendingDynamicLinkData.link.queryParameters['screen'].toString();
      final url = pendingDynamicLinkData.link.queryParameters['url'].toString();
      if (route != null) {
        log(route);
        log(url);
        log('////initDyanamic ');
        // Example of using the dynamic link to push the user to a different screen
        Get.toNamed(route);
      }
    },
  );
}
