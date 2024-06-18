import 'dart:developer';

import 'package:com.while.while_app/data/model/chat_user.dart';
import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
import 'package:com.while.while_app/providers/apis.dart';
import 'package:com.while.while_app/providers/connect_users_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class UserListDialog extends ConsumerStatefulWidget {
  final String commId;
  final List<ChatUser> list;

  const UserListDialog({Key? key, required this.commId, required this.list})
      : super(key: key);

  @override
  _UserListDialogState createState() => _UserListDialogState();
}

class _UserListDialogState extends ConsumerState<UserListDialog> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  @override
  void dispose() {
    ref.watch(toggleSearchStateProvider.notifier).state = 0;
    ref.watch(searchQueryProvider.notifier).state = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log("Building UserListDialog");
    var toogleSearch = ref.watch(toggleSearchStateProvider);
    var searchValue = ref.watch(searchQueryProvider.notifier);

    final allUsersAsyncValue = ref.watch(allUsersProvider);
    log(widget.list.length.toString());
    final communityParticipantsAsyncValue =
        ref.watch(communityParticipantsProvider(widget.commId));

    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              onTap: () {
                final currentToggleSearch = ref.read(toggleSearchStateProvider);
                if (currentToggleSearch == 0) {
                  ref.read(toggleSearchStateProvider.notifier).state =
                      1; // Enable search
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
                      // Enable search
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
      ),
      body: allUsersAsyncValue.when(
        data: (allUsers) => communityParticipantsAsyncValue.when(
          data: (communityUsers) {
            final usersNotInCommunity = allUsers
                .where((user) => !communityUsers.contains(user.id))
                .toList();
            log("Users not in the community: ${usersNotInCommunity.map((u) => u.name).join(', ')}");

            if (usersNotInCommunity.isEmpty) {
              return const Center(child: Text("No users available to add."));
            }

            return ListView.builder(
              itemCount: usersNotInCommunity.length,
              itemBuilder: (context, index) {
                final user = usersNotInCommunity[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.image),
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      log("Adding User: ${user.id} to community");
                      await ref
                          .watch(apisProvider)
                          .adminAddUserToCommunity(widget.commId, user);
                      setState(() {}); // This forces the widget to rebuild
                    },
                    child: const Text('Add'),
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
