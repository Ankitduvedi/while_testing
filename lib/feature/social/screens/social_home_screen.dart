import 'dart:developer';
import 'package:com.while.while_app/core/constant.dart';
import 'package:com.while.while_app/feature/social/screens/app_tour_chat.dart';
import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';

import 'package:com.while.while_app/feature/social/screens/community/community_home_widget.dart';
import 'package:com.while.while_app/feature/social/screens/chat/message_home_widget.dart';
import 'package:com.while.while_app/feature/social/screens/connect/connect_screen.dart';
import 'package:com.while.while_app/feature/social/screens/status/status_screen.dart';
import 'package:com.while.while_app/providers/connect_users_provider.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../data/model/chat_user.dart';
import '../../../providers/user_provider copy.dart';

class SocialScreen extends ConsumerStatefulWidget {
  const SocialScreen({super.key});

  @override
  ConsumerState<SocialScreen> createState() {
    return _SocialScreenState();
  }
}

class _SocialScreenState extends ConsumerState<SocialScreen>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 4, vsync: this, initialIndex: 0);
    _controller.addListener(() {
      // Check if the controller index is changing, if you need this check
      if (!_controller.indexIsChanging) {
        updateSearchToggleBasedOnTab(_controller.index);
      }
    });
  }

  void updateSearchToggleBasedOnTab(int index) {
    // Logic to update searchToggle based on the tab index
    // For example, you might want to disable search on certain tabs
    if (ref.watch(toggleSearchStateProvider.notifier).state != 0) {
      // Assuming you want the search toggle active on the second tab
      ref.read(toggleSearchStateProvider.notifier).state = index + 1;
    }
    // else {
    //   ref.read(toggleSearchStateProvider.notifier).state = 0;
    //   ref.read(searchQueryProvider.notifier).state =
    //       ''; // Optionally clear search query
    // }
  }

  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final connectKey = GlobalKey();
  final chatsKey = GlobalKey();
  final communityKey = GlobalKey();
  final statusKey = GlobalKey();

  late TutorialCoachMark tutorialCoachMark;

  void initAppTour() {
    final targets = addChatsSiteTargetPage(
      connectKey: connectKey,
      chatsKey: chatsKey,
      communityKey: communityKey,
      statusKey: statusKey,
    );
    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.blueAccent,
      hideSkip: false,
      textSkip: 'SKIP',
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () {
        log('finish');
      },
      onClickTarget: (target) {
        log(target.toString());
      },
    );
  }

  void _showTutorial(ChatUser user) {
    Future.delayed(const Duration(seconds: 1), () {
      tutorialCoachMark.show(context: context);
    });
    user.tourPage = user.tourPage + "${tourMap['SocialScreen']}";
    ref.read(userDataProvider).updateUserData(user);
  }

  @override
  Widget build(BuildContext context) {
    var toogleSearch = ref.watch(toggleSearchStateProvider);
    var searchValue = ref.watch(searchQueryProvider.notifier);
    log('toggleSearchStateProvider');
    bool isNewUser = ref.read(isNewUserProvider);
    print("home screen2 $isNewUser");

    var user = ref.watch(userDataProvider).userData!;
    print("user id1: ${user.id}");

    // ref.watch(userDataProvider);
    print("containing ${user.name}");
    if (isNewUser || !user!.tourPage.contains("${tourMap['SocialScreen']}")) {
      initAppTour();
      _showTutorial(user);
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 45,
          backgroundColor: Colors.white,
          title: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                onTap: () {
                  final currentToggleSearch =
                      ref.read(toggleSearchStateProvider);
                  if (currentToggleSearch == 0) {
                    ref.read(toggleSearchStateProvider.notifier).state =
                        _controller.index + 1; // Enable search
                  }
                },
                onChanged: (value) {
                  searchValue.state = value;
                },
                decoration: InputDecoration(
                  hintText: "Type to search...",
                  labelText: 'Search',
                  labelStyle: GoogleFonts.ptSans(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  suffixIcon: IconButton(
                    onPressed: () {
                      final currentToggleSearch =
                          ref.read(toggleSearchStateProvider);
                      if (currentToggleSearch != 0) {
                        ref.read(searchQueryProvider.notifier).state =
                            ''; // Clear search query
                        ref.read(toggleSearchStateProvider.notifier).state =
                            0; // Disable search
                        _textController.clear();
                        FocusScope.of(context).requestFocus(FocusNode());
                      } else {
                        ref.read(toggleSearchStateProvider.notifier).state =
                            _controller.index + 1; // Enable search
                        FocusScope.of(context).requestFocus(_focusNode);
                      }
                    },
                    icon: Icon(
                      toogleSearch != 0
                          ? CupertinoIcons.xmark
                          : Icons.search_rounded,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                style: GoogleFonts.ptSans(color: Colors.black),
              )),
          bottom: TabBar(
            dividerColor: Colors.transparent,
            controller: _controller,
            tabAlignment: TabAlignment.center,
            indicatorColor: Colors.black,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.black,
            labelStyle:
                GoogleFonts.ptSans(fontWeight: FontWeight.bold, fontSize: 15),
            tabs: [
              Tab(
                key: connectKey,
                text: 'Connect   ',
              ),
              Tab(
                key: chatsKey,
                text: 'Chats  ',
              ),
              Tab(
                key: communityKey,
                text: 'Community',
              ),
              Tab(
                key: statusKey,
                text: '    Status',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _controller,
          children: const [
            ConnectScreen(),
            MessageHomeWidget(),
            CommunityHomeWidget(),
            StatusScreenState(),
          ],
        ),
      ),
    );
  }
}
