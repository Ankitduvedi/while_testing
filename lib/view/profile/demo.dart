import 'dart:developer';
import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
import 'package:com.while.while_app/feature/notifications/controller/notif_contoller.dart';
import 'package:com.while.while_app/components/message/widgets/dialogs/profile_dialog.dart';
import 'package:com.while.while_app/view_model/providers/connect_users_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class Connect extends ConsumerWidget {
  const Connect({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allUsersAsyncValue = ref.watch(allUsersProvider);
    final followingUsersAsyncValue =
        ref.watch(followingUsersProvider('userId'));

    final fireService = ref.read(userProvider);
    final notifService = ref.read(notifControllerProvider.notifier);

    return Scaffold(
      body: allUsersAsyncValue.when(
        data: (allUsers) => followingUsersAsyncValue.when(
          data: (followingUsers) {
            final nonFollowingUsers = allUsers
                .where((user) => !followingUsers.contains(user.id))
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
                  title: Text(
                    user.name,
                    style: GoogleFonts.ptSans(),
                  ),
                  subtitle: Text(user.email, style: GoogleFonts.ptSans()),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      final didFollow =
                          await ref.read(followUserProvider)(user.id);

                      final currentUser = ref.read(userProvider.notifier).state;

                      if (didFollow) {
                        notifService.addNotification(
                            '${fireService!.name} started following you',
                            user.id);
                        log("now following");
                        ref.read(userProvider.notifier).state!.copyWith(follower: currentUser!.follower + 1);
                      } else {
                        log("failed to follow");
                      }
                    },
                    child: Text('Follow', style: GoogleFonts.ptSans()),
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
