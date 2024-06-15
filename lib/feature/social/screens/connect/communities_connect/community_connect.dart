import 'dart:developer';
import 'package:com.while.while_app/providers/connect_community_provider.dart';
import 'package:com.while.while_app/providers/user_provider%20copy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class CommunityConnect extends ConsumerWidget {
  const CommunityConnect({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = FirebaseAuth
        .instance.currentUser!.uid; // Assume the current user ID is available
    final allCommunitiesAsyncValue = ref.watch(allCommunitiesProvider);
    final joinedCommunitiesAsyncValue =
        ref.watch(joinedCommuntiesProvider(userId));

    return Scaffold(
      body: allCommunitiesAsyncValue.when(
        data: (allCommunities) => joinedCommunitiesAsyncValue.when(
          data: (followingUsers) {
            final nonJoinedCommunities = allCommunities
                .where((user) => !followingUsers.contains(user.id))
                .toList();

            return ListView.builder(
              itemCount: nonJoinedCommunities.length,
              itemBuilder: (context, index) {
                final community = nonJoinedCommunities[index];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(community.image),
                    onBackgroundImageError: (exception, stackTrace) {
                      log('Failed to load image');
                    },
                  ),
                  title: Text(
                    community.name,
                    style: GoogleFonts.ptSans(),
                  ),
                  subtitle: Text(community.about, style: GoogleFonts.ptSans()),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      // Use the provider to follow the user
                      final didJoin = await ref.read(joinCommunityProvider)(
                          ref.read(userDataProvider).userData!,
                          community,
                          context);

                      if (didJoin) {
                        log("joined community");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('You have joined ${community.name}')),
                        );
                      } else {
                        log("failed to join");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Failed to join ${community.name}')),
                        );
                      }
                    },
                    child: Text('Join', style: GoogleFonts.ptSans()),
                  ),
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
    );
  }
}
