import 'package:com.while.while_app/core/routes/navigation_const.dart';
import 'package:com.while.while_app/data/model/chat_user.dart';
import 'package:com.while.while_app/data/model/community_user.dart';
import 'package:com.while.while_app/feature/auth/screens/forgot_password_screen.dart';
import 'package:com.while.while_app/feature/auth/screens/login_screen.dart';
import 'package:com.while.while_app/feature/auth/screens/register_screen.dart';
import 'package:com.while.while_app/feature/comingsoon.dart';
import 'package:com.while.while_app/feature/counsellor/screens/counseller_detail_page.dart';
import 'package:com.while.while_app/feature/counsellor/screens/under_review_screen.dart' as counsellor;
import 'package:com.while.while_app/feature/creator/screens/become_creator_screen.dart';
import 'package:com.while.while_app/feature/creator/screens/create_screen.dart';
import 'package:com.while.while_app/feature/creator/screens/main_creator_screen.dart';
import 'package:com.while.while_app/feature/creator/screens/under_review_screen.dart';
import 'package:com.while.while_app/feature/feedscreen/screens/feed_screen.dart';
import 'package:com.while.while_app/feature/intro_screens/intro_page_1.dart';
import 'package:com.while.while_app/feature/intro_screens/intro_page_2.dart';
import 'package:com.while.while_app/feature/intro_screens/intro_page_3.dart';
import 'package:com.while.while_app/feature/intro_screens/intro_page_4.dart';
import 'package:com.while.while_app/feature/intro_screens/intro_page_5.dart';
import 'package:com.while.while_app/feature/intro_screens/onboarding_screen.dart';
import 'package:com.while.while_app/feature/profile/screens/creator_profile_widget%20copy.dart';
import 'package:com.while.while_app/feature/profile/screens/edit_profile_user.dart';
import 'package:com.while.while_app/feature/profile/screens/profile_data_widget2.dart';
import 'package:com.while.while_app/feature/profile/screens/user_leaderboard_screen.dart';
import 'package:com.while.while_app/feature/profile/screens/user_profile_screen2.dart';
import 'package:com.while.while_app/feature/social/screens/chat/message_home_widget.dart';
import 'package:com.while.while_app/feature/social/screens/community/cdetail.dart';
import 'package:com.while.while_app/feature/social/screens/community/community_home_widget.dart';
import 'package:com.while.while_app/feature/social/screens/community/resources/avail_users_dialog.dart';
import 'package:com.while.while_app/feature/social/screens/community/resources/join_request.dart';
import 'package:com.while.while_app/feature/social/screens/social_home_screen.dart';
import 'package:com.while.while_app/feature/social/screens/status/full_screen_status.dart';
import 'package:com.while.while_app/feature/social/screens/status/status_screen.dart';
import 'package:com.while.while_app/feature/splash/screens/splash_view.dart';
import 'package:com.while.while_app/feature/wrapper/scaffold_with_navbar.dart';
import 'package:com.while.while_app/feature/wrapper/update.dart';
import 'package:go_router/go_router.dart';

final goRouter = GoRouter(
  debugLogDiagnostics: true,
  navigatorKey: NavigationService.rootNavigatorKey,
  initialLocation: '/splashScreen',
  routes: <RouteBase>[
    GoRoute(
      path: '/messageHomeWidgetScreen',
      builder: (context, state) => const MessageHomeWidget(),
    ),
    GoRoute(
      path: '/splashScreen',
      builder: (context, state) => const SplashScreen(),
    ),
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
    GoRoute(path: '/onBoardingScreens', builder: (context, state) => const OnBoardingScreen(), routes: [
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
              path: '/creatorScreen',
              builder: (context, state) {
                return const CreateScreen();
              },
              routes: [
                GoRoute(
                  path: 'mainCreatorScreen',
                  builder: (context, state) => const MainCreatorScreen(),
                ),
                GoRoute(
                  path: 'becomeCreatorScreen',
                  builder: (context, state) => const BecomeCreator(),
                ),
                GoRoute(
                  path: 'underReviewCreatorScreen/:type',
                  builder: (context, state) => UnderReviewScreen(type: state.pathParameters['type']!),
                ),
              ]),
          GoRoute(
            path: '/reelsScreen',
            builder: (context, state) => const ComingSoonPage(),
          ),
          GoRoute(path: '/socials', builder: (context, state) => const SocialScreen(), routes: [
            GoRoute(path: 'statusScreen', builder: (context, state) => const StatusScreenState(), routes: [
              GoRoute(
                path: 'fullStatusScreen/:index',
                builder: (context, state) => FullStatusScreen(
                  initialIndex: int.parse(state.pathParameters['index']!),
                  statuses: state.extra as List<Map<String, dynamic>>,
                ),
              ),
            ]),
            GoRoute(path: 'community', builder: (context, state) => const CommunityHomeWidget(), routes: [
              GoRoute(
                path: 'communityUserCard',
                builder: (context, state) => CCommunityDetailScreen(
                  community: state.extra as Community,
                ),
              ),
              GoRoute(
                  path: 'communityAdminUserCard',
                  builder: (context, state) => CreatorProfileVideo(
                        user: state.extra as ChatUser,
                      ),
                  routes: [
                    GoRoute(
                      path: 'openListDialog/:commId',
                      builder: (context, state) => JoinRequestDialog(
                        commId: state.pathParameters['commId']!,
                        list: state.extra as List<ChatUser>,
                      ),
                    ),
                    GoRoute(
                      path: 'openListDialog/:commId',
                      builder: (context, state) => UserListDialog(
                        commId: state.pathParameters['commId']!,
                        list: state.extra as List<ChatUser>,
                      ),
                    ),
                  ]),
            ]),
          ]),
          GoRoute(path: '/account', builder: (context, state) => const ProfileScreen(), routes: [
            GoRoute(
              path: 'userProfileWidget',
              builder: (context, state) => const ProfileDataWidget(),
            ),
            GoRoute(
              path: 'leaderBoard',
              builder: (context, state) => const LeaderboardScreen(),
            ),
            GoRoute(
              path: 'editProfileScreen',
              builder: (context, state) => const EditUserProfileScreen(),
            ),
          ])
        ]),
  ],
);
