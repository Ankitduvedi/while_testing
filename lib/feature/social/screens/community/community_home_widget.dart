import 'dart:developer';
import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
import 'package:com.while.while_app/feature/social/screens/community/add_community_widget.dart';
import 'package:com.while.while_app/feature/social/screens/community/community_user_card.dart';
import 'package:com.while.while_app/providers/connect_community_provider.dart';
import 'package:com.while.while_app/providers/connect_users_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class CommunityHomeWidget extends ConsumerWidget {
  const CommunityHomeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allCommunityAsyncValue = ref.watch(allCommunitiesProvider);
    final myCommunityAsyncValue = ref.watch(myCommunityUidsProvider);
    var toogleSearch = ref.watch(toggleSearchStateProvider);
    final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
    return Scaffold(
        backgroundColor: Colors.white,
        body: allCommunityAsyncValue.when(
          data: (allCommunities) => myCommunityAsyncValue.when(
            data: (joinedCommunity) {
              final notJoinedCommunity = allCommunities
                  .where((community) => joinedCommunity.contains(community.id))
                  .toList();
              var communityList = toogleSearch == 3
                  ? notJoinedCommunity
                      .where((user) =>
                          user.name.toLowerCase().contains(searchQuery))
                      .toList()
                  : notJoinedCommunity;

              log("Community length ${communityList.length}");
              if (communityList.isEmpty) {
                return Center(
                  child: Text(
                    'Join a Community',
                    style: GoogleFonts.ptSans(color: Colors.black),
                  ),
                );
              }
              return ListView.builder(
                itemCount: communityList.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ChatCommunityCard(user: communityList[index]),
                      Divider(
                        color: Colors.grey.shade300,
                        thickness: 1,
                        height: 0,
                      ),
                    ],
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: () {
            AddCommunityScreen().addCommunityDialog(context, ref);
          },
          child: const Icon(
            Icons.group_add_rounded,
            color: Colors.black,
          ),
        ));
  }
}
