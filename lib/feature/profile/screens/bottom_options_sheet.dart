import 'dart:developer';
import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
import 'package:com.while.while_app/providers/apis.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'edit_profile_user.dart';
import 'package:google_fonts/google_fonts.dart';

class MoreOptions extends ConsumerWidget {
  const MoreOptions({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            ListTile(
              onTap: () {
                context.pop();
                Navigator.push(context, MaterialPageRoute(builder: (_) => const EditUserProfileScreen()));
              },
              leading: const Icon(
                Icons.edit,
                color: Colors.black,
                size: 30,
              ),
              title: Text(
                "Edit Profile",
                style: GoogleFonts.ptSans(),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.share_outlined,
                color: Colors.black,
                size: 30,
              ),
              title: Text("Share", style: GoogleFonts.ptSans()),
            ),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.black,
                size: 30,
              ),
              title: Text("Logout", style: GoogleFonts.ptSans()),
              onTap: () async {
                log("logging out user");
                ref.read(apisProvider).updateActiveStatus(0);
                // ref.read(toggleStateProvider.notifier).state = 1;
                ref.read(authControllerProvider.notifier).signOut(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_forever_outlined,
                color: Colors.black,
                size: 30,
              ),
              title: Text("Delete Account", style: GoogleFonts.ptSans()),
              onTap: () async {
                // Show a confirmation dialog
                final shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Account'),
                        content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              // User cancels
                              Navigator.of(context).pop(false);
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              // User confirms deletion
                              Navigator.of(context).pop(true);
                              // SystemNavigator.pop();
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    ) ??
                    false; // Default to false if null

                // Proceed with deletion if confirmed
                if (shouldDelete) {
                  // ref.read(toggleStateProvider.notifier).state = 0;
                  ref.read(authControllerProvider.notifier).deleteAccount(context);
                  ref.read(authControllerProvider.notifier).signOut(context);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
