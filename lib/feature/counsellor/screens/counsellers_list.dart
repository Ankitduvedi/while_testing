import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CounsellorDetails extends StatelessWidget {
  final String counsellorId;

  const CounsellorDetails({Key? key, required this.counsellorId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counsellor Details'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('counsellers')
            .doc(counsellorId)
            .collection('counsellersData')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Extract the documents from the snapshot
          final List<DocumentSnapshot> alldataDocs = snapshot.data!.docs;
          log(alldataDocs.length.toString());
          return ListView.builder(
            itemCount: alldataDocs.length,
            itemBuilder: (context, index) {
              final alldataDoc = alldataDocs[index];
              final data = alldataDoc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text('Document ID: ${alldataDoc.id}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: data.entries.map((entry) {
                    return Text('${entry.key}: ${entry.value}');
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
