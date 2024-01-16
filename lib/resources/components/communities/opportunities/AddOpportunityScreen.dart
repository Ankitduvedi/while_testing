import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:while_app/resources/components/message/models/community_user.dart';
import 'package:while_app/resources/components/communities/opportunities/community_detail_opportunities_widget.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class AddOpportunityScreen extends StatefulWidget {
  const AddOpportunityScreen({super.key, required this.user});
  final CommunityUser user;
  @override
  AddOpportunityScreenState createState() => AddOpportunityScreenState();
}

class AddOpportunityScreenState extends State<AddOpportunityScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Add Opportunity'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Opportunity Name',
                labelStyle: TextStyle(color: Colors.white),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                hintStyle: TextStyle(color: Colors.yellow),
                suffixStyle: TextStyle(color: Colors.yellow),
              ),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Opportunity Description',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Opportunity URL',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.white)),
              onPressed: () {
                // Upload the new opportunity to Firestore
                _uploadOpportunity();
                Navigator.pop(context);
              },
              child: const Text('Add Opportunity',  style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  void _uploadOpportunity() {
    final newOpportunity = Opportunity(
      id: uuid.v4(),
      name: nameController.text,
      description: descriptionController.text,
      url: urlController.text,
    );

    FirebaseFirestore.instance
        .collection('communities')
        .doc(widget.user.id)
        .collection('opportunities')
        .doc(newOpportunity.id)
        .set({
      'name': newOpportunity.name,
      'description': newOpportunity.description,
      'url': newOpportunity.url,
      'id': newOpportunity.id,
    }).then((_) {
      // After successful upload, clear the text fields
      nameController.clear();
      descriptionController.clear();
      urlController.clear();
    });
  }
}
