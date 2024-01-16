import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:provider/provider.dart';
import 'package:while_app/resources/components/message/apis.dart';
import 'package:while_app/utils/routes/routes_name.dart';
import 'package:while_app/view_model/providers/providers_list.dart';
import 'package:while_app/view_model/wrapper/wrapper.dart';
import 'firebase_options.dart';
import 'utils/routes/routes.dart';

final userProvider = river.StreamProvider((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(APIs.me.id)
      .snapshots();
});
late Size mq;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  _initializeFirebase();
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
      child: const MaterialApp(
        title: 'While',
        debugShowCheckedModeBanner: false,
        initialRoute: RoutesName.splash,
        onGenerateRoute: Routes.generateRoute,
        home: Wrapper(),
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
