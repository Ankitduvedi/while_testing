import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:com.while.while_app/data/model/community_user.dart';
import 'package:com.while.while_app/components/communities/opportunities/community_detail_opportunities_widget.dart';
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
  final TextEditingController descriptionController = TextEditingController();
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
