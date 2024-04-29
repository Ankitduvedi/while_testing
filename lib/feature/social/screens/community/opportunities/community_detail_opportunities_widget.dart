import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:com.while.while_app/data/model/community_user.dart';
import 'package:com.while.while_app/feature/social/screens/community/opportunities/AddOpportunityScreen.dart';
import 'package:com.while.while_app/providers/apis.dart';

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
    this.tags = const [],
  });
}

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class OpportunitiesScreen extends ConsumerWidget {
  const OpportunitiesScreen({Key? key, required this.user}) : super(key: key);
  final Community user;

  Future<void> _showOpportunityDetails(
      BuildContext context, Opportunity opportunity, WidgetRef ref) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(opportunity.name,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Description:',
                  style:
                      TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
              Text(opportunity.description, style: TextStyle(fontSize: 16.0)),
              SizedBox(height: 16),
              Text('URL:',
                  style:
                      TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
              InkWell(
                child: Text(opportunity.url,
                    style: TextStyle(fontSize: 16.0, color: Colors.blue)),
                onTap: () => launchURL(opportunity.url),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
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
        stream: _firestore
            .collection('communities')
            .doc(user.id)
            .collection('opportunities')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No opportunities available.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              var opportunity = Opportunity(
                organization: data['organization'],
                name: data['name'],
                description: data['description'],
                url: data['url'],
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
        )
      ),
      child: ListTile(
        leading: Icon(Icons.business_center, size: 44),
        title: Text(
          opportunity.name,
          style: TextStyle(fontSize: 26),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Ensures the column takes up minimal space
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(opportunity.organization, style: TextStyle(fontSize: 20)),
              SizedBox(height: 8),  // Adds space between the organization and tags
              Wrap(
                spacing: 8.0, // space between chips
                runSpacing: 4.0, // space between lines
                children: opportunity.tags
                  .map((tag) => Chip(
                    label: Text(tag),
                    backgroundColor: Colors.lightBlueAccent, // Adds a background color to the chips
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
            MaterialPageRoute(
                builder: (context) => AddOpportunityScreen(user: user)),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add Opportunity',
      ),
    );
  }
}

void launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
