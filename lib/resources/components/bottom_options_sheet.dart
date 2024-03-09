import 'package:com.example.while_app/repository/firebase_repository.dart';
import 'package:com.example.while_app/view_model/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:com.example.while_app/utils/routes/routes_name.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import '../../view/profile/edit_profile_user.dart';

class MoreOptions extends ConsumerWidget {
  const MoreOptions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).pop();

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EditUserProfileScreen()));
              },
              leading: const Icon(
                Icons.edit,
                color: Colors.black,
                size: 30,
              ),
              title: const Text("Edit Profile"),
            ),
            const ListTile(
              leading: Icon(
                Icons.share_outlined,
                color: Colors.black,
                size: 30,
              ),
              title: Text("Share"),
            ),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.black,
                size: 30,
              ),
              title: const Text("logout"),
              onTap: () {
                ref.read(toggleStateProvider.notifier).state = 0;
                context.read<FirebaseAuthMethods>().signout(context);
                Navigator.pop(context);
                // SystemNavigator.pop();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_forever_outlined,
                color: Colors.black,
                size: 30,
              ),
              title: const Text("Delete Account"),
              onTap: () async {
                // Show a confirmation dialog
                final shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Account'),
                        content: const Text(
                            'Are you sure you want to delete your account? This action cannot be undone.'),
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
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    ) ??
                    false; // Default to false if null

                // Proceed with deletion if confirmed
                if (shouldDelete) {
                  ref.read(toggleStateProvider.notifier).state = 0;
                  await  context
                      .read<FirebaseAuthMethods>()
                      .deleteAccount(context);
                  context.read<FirebaseAuthMethods>().signout(context);
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
