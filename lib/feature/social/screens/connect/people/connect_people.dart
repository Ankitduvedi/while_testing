import 'dart:developer';
import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
import 'package:com.while.while_app/feature/notifications/controller/notif_contoller.dart';
import 'package:com.while.while_app/feature/social/screens/chat/profile_dialog.dart';
import 'package:com.while.while_app/providers/connect_users_provider.dart';
import 'package:com.while.while_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class Connect extends ConsumerWidget {
  const Connect({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allUsersAsyncValue = ref.watch(allUsersProvider);

    var user = ref.watch(userDataProvider).userData!;

    final followingUsersAsyncValue = ref.watch(followingUsersProvider(user.id));

    final fireService = ref.watch(userProvider);
    final notifService =
        ref.watch(notifControllerProvider.notifier); // Assume this is non-null

    return Scaffold(
      body: allUsersAsyncValue.when(
        data: (allUsers) => followingUsersAsyncValue.when(
          data: (followingUsers) {
            // Now excluding the current user's ID as well
            final nonFollowingUsers = allUsers
                .where((user) =>
                    !followingUsers.contains(user.id) &&
                    user.id != ref.read(userProvider)!.id)
                .toList();
            return ListView.builder(
              itemCount: nonFollowingUsers.length,
              itemBuilder: (context, index) {
                final user = nonFollowingUsers[index];
                return ListTile(
                  leading: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => ProfileDialog(user: user),
                      );
                    },
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(user.image),
                    ),
                  ),
                  title: Text(user.name, style: GoogleFonts.ptSans()),
                  subtitle: Text(user.email, style: GoogleFonts.ptSans()),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      try {
                        final didFollow =
                            await ref.read(followUserProvider)(user.id);
                        final currentUser = ref.read(userDataProvider).userData;
                        if (didFollow) {
                          if (fireService != null && currentUser != null) {
                            notifService.addNotification(
                                '${fireService.name} started following you',
                                user.id);
                            log("now following");
                          } else {
                            log("Error: fireService or currentUser is null");
                          }
                        } else {
                          log("failed to follow, ${currentUser!.name}");
                        }
                      } catch (e) {
                        log("Error in follow button: $e");
                      }
                    },
                    child: Text('Follow', style: GoogleFonts.ptSans()),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error up: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error down: $e')),
      ),
    );
  }
}
