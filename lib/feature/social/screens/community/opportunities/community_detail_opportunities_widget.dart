// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:com.while.while_app/data/model/community_user.dart';
import 'package:com.while.while_app/feature/social/screens/community/opportunities/AddOpportunityScreen.dart';

class Opportunity {
  final String name;
  final String organization;
  final String description;
  final String url;
  final List<String> tags;
  final String id;

  Opportunity({
    required this.name,
    required this.organization,
    required this.description,
    required this.url,
    required this.id,
    required this.tags,
  });
}

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class OpportunitiesScreen extends ConsumerWidget {
  const OpportunitiesScreen({Key? key, required this.user}) : super(key: key);
  final Community user;

  Future<void> _showOpportunityDetails(BuildContext context, Opportunity opportunity, WidgetRef ref) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            opportunity.name,
            style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Organization:',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                Text(
                  opportunity.organization,
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Description:',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                Text(
                  opportunity.description,
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Skills:',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 8.0, // Horizontal space between children
                  children: List<Widget>.generate(opportunity.tags.length, (index) {
                    // Check if the current item is the last in the list
                    bool isLast = index == opportunity.tags.length - 1;
                    // Create a text widget with or without a comma
                    return Text(
                      '${opportunity.tags[index]}${isLast ? '' : ','}',
                      style: const TextStyle(fontSize: 16),
                    );
                  }),
                ),
                SizedBox(height: 16),
                Text(
                  'URL:',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                InkWell(
                  child: Text(
                    opportunity.url,
                    style: TextStyle(fontSize: 16.0, color: Colors.blue),
                  ),
                  onTap: () => launchURL(opportunity.url),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // This will space out the children
              children: <Widget>[
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () {
                    FirebaseFirestore.instance.collection('communities').doc(user.id).collection('opportunities').doc(opportunity.id).delete();
                    // Add your delete logic here before popping the dialog
                    context.pop();
                  },
                ),
                TextButton(child: const Text('Close'), onPressed: () => context.pop()),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('communities').doc(user.id).collection('opportunities').snapshots(),
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
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              var tagsList = List<String>.from(data['tags'] ?? []);
              var opportunity = Opportunity(
                organization: data['organization'],
                name: data['name'],
                description: data['description'],
                url: data['url'],
                tags: tagsList,
                id: doc.id,
              );
              return Padding(
                padding: const EdgeInsets.fromLTRB(9, 2, 9, 2),
                child: Card(
                  elevation: 4,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFF2F2F2),
                            Color.fromARGB(255, 242, 208, 192),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )),
                    child: ListTile(
                      leading: const Icon(Icons.business_center, size: 58),
                      title: Text(
                        opportunity.name,
                        style: TextStyle(fontSize: 28),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min, // Ensures the column takes up minimal space
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(opportunity.organization, style: TextStyle(fontSize: 20)),
                            SizedBox(height: 8), // Adds space between the organization and tags
                            Wrap(
                              spacing: 3.0, // space between chips
                              runSpacing: 1.0, // space between lines
                              children: opportunity.tags
                                  .map((tag) => Chip(
                                        padding: EdgeInsets.all(0),
                                        label: Text(tag),
                                        backgroundColor: Color.fromARGB(255, 187, 198, 208), // Adds a background color to the chips
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        _showOpportunityDetails(context, opportunity, ref);
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddOpportunityScreen(user: user)),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add Opportunity',
      ),
    );
  }
}

void launchURL(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $url';
  }
}
