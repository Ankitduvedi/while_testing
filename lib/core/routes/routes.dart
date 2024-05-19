import 'package:com.while.while_app/feature/auth/screens/register_screen.dart';
import 'package:com.while.while_app/feature/others/create_menu_screen.dart';
import 'package:com.while.while_app/feature/upload/screens/add_video.dart';
import 'package:flutter/material.dart';
import 'package:com.while.while_app/core/routes/routes_name.dart';
import 'package:com.while.while_app/feature/auth/screens/forgot_password_screen.dart';
import 'package:com.while.while_app/feature/upload/screens/add_reel.dart';
import 'package:com.while.while_app/home_screen.dart';
import 'package:com.while.while_app/feature/splash/screens/splash_view.dart';
import 'package:com.while.while_app/feature/wrapper/wrapper.dart';
import 'package:image_picker/image_picker.dart';
import '../../feature/auth/screens/login_screen.dart';
import '../../feature/profile/screens/user_profile_screen2.dart';
import '../../feature/settings/settings_page.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final arguments = settings.arguments;
    switch (settings.name) {
      case RoutesName.home:
        return MaterialPageRoute(
            builder: (BuildContext context) => const HomeScreen());
      case RoutesName.login:
        return MaterialPageRoute(
            builder: (BuildContext context) => const LoginScreen());
      case RoutesName.signUp:
        return MaterialPageRoute(
            builder: (BuildContext context) => const SignUpScreen());
      case RoutesName.splash:
        return MaterialPageRoute(
            builder: (BuildContext context) => const SplashScreen());
      case RoutesName.wrapper:
        return MaterialPageRoute(
            builder: (BuildContext context) => const Wrapper());
      case RoutesName.forgot:
        return MaterialPageRoute(
            builder: (BuildContext context) => const ForgotPasswordPage());
      case RoutesName.profile:
        return MaterialPageRoute(
          builder: (BuildContext context) => const ProfileScreen(),
        );
      case RoutesName.verify:
      case RoutesName.settings:
        return MaterialPageRoute(
            builder: (BuildContext context) => const Settings());
      case RoutesName.createMenu:
        return MaterialPageRoute(
            builder: (BuildContext context) => const CreateMenuScreen());
      case RoutesName.addReel:
        if (arguments is XFile) {
          return MaterialPageRoute(
              builder: (BuildContext context) => AddReel(
                    video: arguments,
                  ));
        } else {
          return MaterialPageRoute(builder: (_) {
            return const Scaffold(
              body: Center(
                child: Text('No route defined'),
              ),
            );
          });
        }
      case RoutesName.addVideo:
        if (arguments is XFile) {
          return MaterialPageRoute(
              builder: (BuildContext context) => AddVideo(
                    video: arguments,
                  ));
        } else {
          return MaterialPageRoute(builder: (_) {
            return const Scaffold(
              body: Center(
                child: Text('No route defined'),
              ),
            );
          });
        }
      default:
        return MaterialPageRoute(builder: (_) {
          return const Scaffold(
            body: Center(
              child: Text('No route defined'),
            ),
          );
        });
    }
  }
}
