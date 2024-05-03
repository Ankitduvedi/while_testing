import 'dart:developer';
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
    _controller = TabController(length: 4, vsync: this, initialIndex: 1);
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
  @override
  Widget build(BuildContext context) {
    var toogleSearch = ref.watch(toggleSearchStateProvider);
    var searchValue = ref.watch(searchQueryProvider.notifier);
    log('toggleSearchStateProvider');

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
            tabs: const [
              Tab(
                text: 'Connect   ',
              ),
              Tab(
                text: 'Chats  ',
              ),
              Tab(
                text: 'Community',
              ),
              Tab(
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
