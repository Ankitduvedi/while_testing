import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:com.while.while_app/data/model/community_user.dart';
import 'package:com.while.while_app/feature/social/screens/community/opportunities/community_detail_opportunities_widget.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class AddOpportunityScreen extends StatefulWidget {
  const AddOpportunityScreen({super.key, required this.user});
  final Community user;
  @override
  AddOpportunityScreenState createState() => AddOpportunityScreenState();
}

class AddOpportunityScreenState extends State<AddOpportunityScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController organizationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();
  final TextEditingController urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.lightBlueAccent,
            )),
        title: const Text(
          'Add Opportunity',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Opportunity Name',
                labelStyle: TextStyle(color: Colors.black),
                // focusedBorder: UnderlineInputBorder(
                //   borderSide: BorderSide(color: Colors.blue),
                // ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlueAccent),
                ),
                hintStyle: TextStyle(color: Colors.black),
                suffixStyle: TextStyle(color: Colors.black),
              ),
            ),
            TextField(
              controller: organizationController,
              decoration: const InputDecoration(
                labelText: 'Organization Name',
                labelStyle: TextStyle(color: Colors.black),
                // focusedBorder: UnderlineInputBorder(
                //   borderSide: BorderSide(color: Colors.blue),
                // ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlueAccent),
                ),
                hintStyle: TextStyle(color: Colors.black),
                suffixStyle: TextStyle(color: Colors.black),
              ),
            ),
            TextField(
              controller: tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (comma-separated)',
                labelStyle: TextStyle(color: Colors.black),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlueAccent),
                ),
              ),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Opportunity Description',
                labelStyle: TextStyle(color: Colors.black),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlueAccent),
                ),
              ),
            ),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Opportunity URL',
                labelStyle: TextStyle(color: Colors.black),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlueAccent),
                ),
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.lightBlueAccent)),
              onPressed: () {
                // Upload the new opportunity to Firestore
                _uploadOpportunity();
                Navigator.pop(context);
              },
              child: const Text('Add Opportunity',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _uploadOpportunity() {
  final List<String> tagsList = tagsController.text.split(',').map((tag) => tag.trim()).toList();
  
  final newOpportunity = Opportunity(
    id: uuid.v4(),
    name: nameController.text,
    organization: organizationController.text,
    description: descriptionController.text,
    url: urlController.text,
    tags: tagsList, // Add tags
  );

  FirebaseFirestore.instance
      .collection('communities')
      .doc(widget.user.id)
      .collection('opportunities')
      .doc(newOpportunity.id)
      .set({
    'name': newOpportunity.name,
    'organization': newOpportunity.organization,
    'description': newOpportunity.description,
    'url': newOpportunity.url,
    'id': newOpportunity.id,
    'tags': newOpportunity.tags, // Store tags in Firestore
  }).then((_) {
    // Clear all fields including tags after uploading
    nameController.clear();
    organizationController.clear();
    descriptionController.clear();
    urlController.clear();
    tagsController.clear();
  });
}

}
