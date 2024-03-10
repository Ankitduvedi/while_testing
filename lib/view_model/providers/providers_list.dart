import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:com.example.while_app/repository/firebase_repository.dart';
import 'package:com.example.while_app/view_model/current_user_provider.dart';
import 'package:com.example.while_app/view_model/firebasedata.dart';
import 'package:com.example.while_app/view_model/post_provider.dart';
import 'package:com.example.while_app/view_model/profile_controller.dart';
import 'package:com.example.while_app/view_model/providers/data_provider.dart';
import 'package:com.example.while_app/view_model/reel_controller.dart';
import 'package:provider/provider.dart';

final providersList = [
  Provider(
    create: (_) => PostProvider(),
  ),
  Provider<FirebaseAuthMethods>(
    create: (_) => FirebaseAuthMethods(FirebaseAuth.instance),
  ),
  Provider<ReelController>(
    create: (_) => ReelController(),
  ),
  StreamProvider(
    create: (context) => context.read<FirebaseAuthMethods>().authState,
    initialData: null,
  ),
  ChangeNotifierProvider(
    create: (_) => ProfileController(),
  ),
  Provider(
    create: (_) => CurrentUserProvider(),
  ),
  // Provider(
  //   create: (_) => UserDataProvider(ref),
  // ),
  Provider(
    create: (_) => FireBaseDataProvider(),
  ),
  ChangeNotifierProvider(
    create: (context) => DataProvider(),
  )
];
