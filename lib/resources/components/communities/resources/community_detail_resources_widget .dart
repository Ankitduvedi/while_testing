import 'package:com.while.while_app/resources/components/communities/resources/imageview.dart';
import 'package:com.while.while_app/resources/components/communities/resources/pdfview.dart';
import 'package:com.while.while_app/resources/components/communities/resources/videoplay.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class CommunityDetailResources extends StatefulWidget {
  const CommunityDetailResources({Key? key}) : super(key: key);

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

  Future<void> uploadFile() async {
    try {
      final ref =
          _storage.ref('resources/${selectedFilePath!.split('/').last}');
      final uploadTask = ref.putFile(selectedFile!);

      await uploadTask.whenComplete(() => null);
      final downloadUrl = await ref.getDownloadURL();

      // Store the download URL, text, and title in Firestore
      await _firestore
          .collection('communities')
          .doc('6d34287d-76c5-4317-a72d-e8fcd33fb87d')
          .collection('resources')
          .add({
        'url': downloadUrl,
        'text': statusTextController.text,
        'type': selectedFileType,
        'title': titleTextController.text, // Add title
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
                  hintText: 'Add a description (optional)',
                ),
              ),
              TextField(
                controller: titleTextController, // Add title text field
                decoration: const InputDecoration(
                  hintText: 'Add a title (optional)',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
              //style: ButtonStyle(iconColor: Colors.black),
            ),
            TextButton(
              child: const Text('Upload'),
              onPressed: () {
                uploadFile();
                Navigator.of(context).pop();
              },
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
            .doc('6d34287d-76c5-4317-a72d-e8fcd33fb87d')
            .collection('resources')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final resource = snapshot.data!.docs[index].data();
              return Column(
                children: [
                  ListTile(
                    title: Text(
                      resource['title'] ?? 'Resource $index',
                      style: const TextStyle(color: Colors.black),
                    ), // Use the title if available
                    subtitle: Text(
                      resource['text'],
                      style: const TextStyle(color: Colors.black),
                    ),
                    onTap: () {
                      // Handle the resource item click
                      // You can open or download the resource here

                      if (resource['type'] == 'jpg' ||
                          resource['type'] == 'jpeg' ||
                          resource['type'] == 'png') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageDekhlo(
                              url: resource['url'], //resource['title']
                            ),
                          ),
                        );
                      } else if (resource['type'] == 'mp4') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                videoplay(url: resource['url']),
                          ),
                        );
                      } else if (resource['type'] == 'pdf') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => pdfview(url: resource['url']),
                          ),
                        );
                      }
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

// class VideoPlayerWidget extends StatefulWidget {
//   final File videoFile;

//   VideoPlayerWidget(this.videoFile);

//   @override
//   _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
// }

// class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
//   late VideoPlayerController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.file(widget.videoFile)
//       ..initialize().then((_) {
//         setState(() {});
//       });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_controller.value.isInitialized) {
//       return AspectRatio(
//         aspectRatio: _controller.value.aspectRatio,
//         child: VideoPlayer(_controller),
//       );
//     } else {
//       return const CircularProgressIndicator();
//     }
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _controller.dispose();
//   }
// }
