import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/data/model/community_user.dart';
import 'package:com.while.while_app/components/communities/opportunities/AddOpportunityScreen.dart';
import 'package:com.while.while_app/components/message/apis.dart';

class Opportunity {
  final String name;
  final String description;
  final String url;
  final String id;

  Opportunity(
      {required this.name,
      required this.description,
      required this.url,
      required this.id});
}

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Convert OpportunitiesScreen to a ConsumerWidget
class OpportunitiesScreen extends ConsumerWidget {
  const OpportunitiesScreen({Key? key, required this.user}) : super(key: key);
  final Community user;
  Future<void> _showOpportunityDetails(
      BuildContext context, Opportunity opportunity, WidgetRef ref) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            opportunity.name,
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Description:',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                opportunity.description,
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16),
              const Text(
                'URL:',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell(
                child: Text(
                  opportunity.url,
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.blue, // Add a link-like color
                  ),
                ),
                onTap: () {
                  // Handle URL click, e.g., open the URL in a web browser
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            (user.email == ref.read(apisProvider).me.email)
                ? TextButton(
                    child: const Text('Delete'),
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('communities')
                          .doc(user.id)
                          .collection('opportunities')
                          .doc(opportunity.id)
                          .delete();
                      Navigator.of(context).pop();
                    },
                  )
                : const Text(''),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('communities')
            .doc(user.id)
            .collection('opportunities')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No opportunities available.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final opportunity = Opportunity(
                name: data['name'],
                description: data['description'],
                url: data['url'],
                id: data['id'],
              );

              return Column(
                children: [
                  ListTile(
                    title: Text(
                      opportunity.name,
                      style: const TextStyle(color: Colors.black),
                    ),
                    subtitle: Text(
                      opportunity.description,
                      style: const TextStyle(color: Colors.black),
                    ),
                    onTap: () {
                      _showOpportunityDetails(context, opportunity, ref);
                    },
                  ),
                  Divider(
                    color: Colors.grey.shade300,
                    thickness: 1,
                    height: 0,
                  )
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlueAccent,
        onPressed: () {
          // Navigate to the screen where admins can add opportunities
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddOpportunityScreen(
                        user: user,
                      )));
        },
        tooltip: 'Add Opportunity',
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
