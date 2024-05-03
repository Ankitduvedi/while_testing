import 'package:com.while.while_app/data/model/community_user.dart';
import 'package:com.while.while_app/feature/social/screens/community/resources/card_widget.dart';
import 'package:com.while.while_app/feature/social/screens/community/resources/imageview.dart';
import 'package:com.while.while_app/feature/social/screens/community/resources/pdfview.dart';
import 'package:com.while.while_app/feature/social/screens/community/resources/videoplay.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:uuid/uuid.dart';

class Resource {
  final String title;
  final String description;
  final String url;
  final String id;

  Resource({
    required this.title,
    required this.description,
    required this.url,
    required this.id,
  });
}

const uuid = Uuid();

class CommunityDetailResources extends StatefulWidget {
  final Community user;
  const CommunityDetailResources({Key? key, required this.user})
      : super(key: key);

  @override
  CommunityDetailResourcesState createState() =>
      CommunityDetailResourcesState();
}

class CommunityDetailResourcesState extends State<CommunityDetailResources> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> resources = [];
  String? uploadMessage;
  File? selectedFile;
  String? selectedFilePath;
  String? selectedFileType;
  TextEditingController statusTextController = TextEditingController();
  TextEditingController titleTextController =
      TextEditingController(); // Add this controller

  @override
  void initState() {
    super.initState();
  }

  Future<void> uploadFile(String title) async {
    final newResource = Resource(
        id: uuid.v4(),
        title: title,
        description: statusTextController.text,
        url: (''));
    try {
      final ref =
          _storage.ref('resources/${selectedFilePath!.split('/').last}');
      final uploadTask = ref.putFile(selectedFile!);

      await uploadTask.whenComplete(() => null);
      final downloadUrl = await ref.getDownloadURL();

      // Store the download URL, text, and title in Firestore
      await _firestore
          .collection('communities')
          .doc(widget.user.id)
          .collection('resources')
          .doc(newResource.id)
          .set({
        'url': downloadUrl,
        'text': newResource.description,
        'type': selectedFileType,
        'title': newResource.title,
        'id': newResource.id,
      }); // Fetch updated resources

      setState(() {
        uploadMessage = 'File uploaded successfully.';
        selectedFile = null;
        selectedFilePath = null;
        selectedFileType = null;
        statusTextController.clear();
        titleTextController.clear();
      });
    } catch (e) {
      setState(() {
        uploadMessage = 'Error uploading file: $e';
      });
    }
  }

  Future<void> pickAndPreviewFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'jpg',
        'jpeg',
        'png',
        'mp4'
      ], // Add allowed extensions
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        selectedFile = file;
        selectedFilePath = file.path;
        selectedFileType = result.files.single.extension;
      });
      _showPreviewDialog();
    }
  }

  Future<void> _showPreviewDialog() {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: Text(
              'Preview File: ${selectedFile!.path.split('/').last}'), // Show the file name
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selectedFileType == 'jpg' ||
                  selectedFileType == 'jpeg' ||
                  selectedFileType == 'png')
                Image.file(selectedFile!, height: 200),
              //if (selectedFileType == 'mp4') VideoPlayerWidget(selectedFile!),
              if (selectedFileType == 'pdf')
                const Text(
                    'PDF Preview Placeholder'), // You can replace this with a PDF viewer widget
              TextField(
                controller: statusTextController,
                decoration: const InputDecoration(
                  hintText: 'Add a description ',
                ),
              ),
              TextField(
                controller: titleTextController, // Add title text field
                decoration: const InputDecoration(
                  hintText: 'Add a title ',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // This spreads out the children across the available space
              children: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Upload'),

                  onPressed: () {
                    String title = titleTextController.text.isNotEmpty
                        ? titleTextController.text
                        : selectedFile!.path
                            .split('/')
                            .last; // Use file name if title is empty

                    // Call upload with the determined title
                    uploadFile(title);
                    Navigator.of(context).pop();
                  },

                  // onPressed: () {
                  //   uploadFile();
                  //   Navigator.of(context).pop();
                  // },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder(
        stream: _firestore
            .collection('communities')
            .doc(widget.user.id)
            .collection('resources')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Uh-Oh! No Resources uploaded yet.', style: TextStyle(fontSize: 18),));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final resource =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return ResourceCard(
                user: widget.user,
                resource: resource,
                index: index,
                onTap: () {
                  if (resource['type'] == 'jpg' ||
                      resource['type'] == 'jpeg' ||
                      resource['type'] == 'png') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageDekhlo(url: resource['url']),
                      ),
                    );
                  } else if (resource['type'] == 'mp4') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoPlay(url: resource['url']),
                      ),
                    );
                  } else if (resource['type'] == 'pdf') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PdfView(url: resource['url']),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlueAccent,
        onPressed: () {
          pickAndPreviewFile();
        },
        tooltip: 'Upload File',
        child: const Icon(
          Icons.upload,
          color: Colors.white,
        ),
      ),
    );
  }
}

class ResourceCard extends StatelessWidget {
  final Map<String, dynamic> resource;
  final int index;
  final Function onTap;
  final Community user;

  ResourceCard(
      {required this.resource,
      required this.index,
      required this.onTap,
      required this.user});

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    switch (resource['type']) {
      case 'pdf':
        iconData = Icons.picture_as_pdf;
        break;
      case 'mp4':
        iconData = Icons.play_circle_fill_outlined;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
        iconData = Icons.photo;
        break;
      default:
        iconData = Icons.insert_drive_file;
    }

    return MyCardWidget(
      resource: resource,
      iconData: iconData,
      onTap: onTap,
      user: user,
    );
  }
}
