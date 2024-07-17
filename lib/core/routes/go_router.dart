import 'package:com.while.while_app/core/routes/navigation_const.dart';
import 'package:com.while.while_app/data/model/chat_user.dart';
import 'package:com.while.while_app/feature/auth/screens/forgot_password_screen.dart';
import 'package:com.while.while_app/feature/auth/screens/login_screen.dart';
import 'package:com.while.while_app/feature/auth/screens/register_screen.dart';
import 'package:com.while.while_app/feature/comingsoon.dart';
import 'package:com.while.while_app/feature/creator/screens/create_screen.dart';
import 'package:com.while.while_app/feature/feedscreen/screens/feed_screen.dart';
import 'package:com.while.while_app/feature/intro_screens/intro_page_1.dart';
import 'package:com.while.while_app/feature/intro_screens/intro_page_2.dart';
import 'package:com.while.while_app/feature/intro_screens/intro_page_3.dart';
import 'package:com.while.while_app/feature/intro_screens/intro_page_4.dart';
import 'package:com.while.while_app/feature/intro_screens/intro_page_5.dart';
import 'package:com.while.while_app/feature/intro_screens/onboarding_screen.dart';
import 'package:com.while.while_app/feature/profile/screens/user_profile_screen2.dart';
import 'package:com.while.while_app/feature/social/screens/social_home_screen.dart';
import 'package:com.while.while_app/feature/splash/screens/splash_view.dart';
import 'package:com.while.while_app/feature/wrapper/scaffold_with_navbar.dart';
import 'package:com.while.while_app/feature/wrapper/update.dart';
import 'package:com.while.while_app/feature/wrapper/wrapper.dart';
import 'package:go_router/go_router.dart';

final goRouter = GoRouter(
  debugLogDiagnostics: true,
  navigatorKey: NavigationService.rootNavigatorKey,
  initialLocation: '/splashScreen',
  routes: <RouteBase>[
    GoRoute(
      path: '/splashScreen',
      builder: (context, state) => const SplashScreen(),
    ),
    // GoRoute(
    //   path: '/wrapper',
    //   builder: (context, state) => const Wrapper(),
    // ),
    GoRoute(
      path: '/updateAppScreen',
      builder: (context, state) => const UpdateAppScreen(),
    ),
    GoRoute(
      path: '/loginScreen',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signUpScreen',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/forgotPasswordScreen',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
        path: '/onBoardingScreens',
        builder: (context, state) => const OnBoardingScreen(),
        routes: [
          GoRoute(
            path: 'introductionScreen1',
            builder: (context, state) => const IntroPage1(),
          ),
          GoRoute(
            path: 'introductionScreen2',
            builder: (context, state) => const IntroPage2(),
          ),
          GoRoute(
            path: 'introductionScreen3',
            builder: (context, state) => const IntroPage3(),
          ),
          GoRoute(
            path: 'introductionScreen4',
            builder: (context, state) => const IntroPage4(),
          ),
          GoRoute(
            path: 'introductionScreen5',
            builder: (context, state) => const IntroPage5(),
          ),
        ]),
    ShellRoute(
        navigatorKey: NavigationService.shellNavigatorKey,
        builder: (context, state, child) => ScaffoldWithNavBar(
              childScreen: child,
            ),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const FeedScreen(),
          ),
          GoRoute(
              path: '/creatorScreen/:user',
              builder: (context, state) {
                return CreateScreen(user: state.extra as ChatUser);
              }),
          GoRoute(
            path: '/reelsScreen',
            builder: (context, state) => const ComingSoonPage(),
          ),
          GoRoute(
            path: '/socials',
            builder: (context, state) => const SocialScreen(),
          ),
          GoRoute(
            path: '/account',
            builder: (context, state) => const ProfileScreen(),
          )
        ]),
  ],
);
