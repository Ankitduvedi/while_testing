import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/core/initialisations/app_initialisations.dart';
import 'package:com.while.while_app/core/utils/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:com.while.while_app/core/routes/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';

final sizeProvider = StateProvider<Size>(
  (ref) => const Size(0, 0),
);
String? activeChatUserId;
activechatid(WidgetRef ref, String id) {
  log('activechatid $id');
  FirebaseFirestore.instance.collection('users').doc(id).update({'isChattingWith': 'activeChatUserId'});
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
  AppInitializations().initializeFirebaseServices;
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(MyAppThemes.systemUiOverlayStyle);
    return MaterialApp.router(
      themeMode: ThemeMode.system,
      theme: isDarkMode ? MyAppThemes.darkTheme : MyAppThemes.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: goRouter,
    );
  }
}
