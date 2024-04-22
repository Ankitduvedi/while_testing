import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/data/model/chat_user.dart';
import 'package:com.while.while_app/feature/counsellor/controller/counseller_contoller.dart';
import 'package:com.while.while_app/feature/counsellor/screens/counseller_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CounsellorDetails extends ConsumerWidget {
  final String counsellorId;

  const CounsellorDetails({Key? key, required this.counsellorId})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log("building");
    final counsellorDataSnapshot =
        ref.watch(counsellerDetailsProvider(counsellorId));
    return Scaffold(
      appBar: AppBar(
        title: Text(counsellorId),
      ),
      body: counsellorDataSnapshot.when(
        data: (QuerySnapshot snapshot) {
          final List<DocumentSnapshot> documents = snapshot.docs;
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final document = documents[index];
              final data = document.data() as Map<String, dynamic>;
              final userAsyncValue =
                  ref.watch(particularUser(data['counsellerId']));

              return userAsyncValue.when(
                data: (DocumentSnapshot snapshot) {
                  final userData = ChatUser.fromJson(
                      snapshot.data() as Map<String, dynamic>);
                  return ListTile(
                    leading: CircleAvatar(
                        backgroundImage:
                            CachedNetworkImageProvider(userData.image)),
                    title: Text(userData.name),
                    subtitle: Text(data['organisation']),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        Text("Experience: ${data['yearsOfExperience']}"),
                        Text("Catered: ${data['customersCatered']}"),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CounsellorDetailPage(
                              userData: userData, extraData: data),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, stack) =>
                    const ListTile(title: Text('Error loading user data')),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(child: Text('Error: ${e.toString()}')),
      ),
    );
  }
}
