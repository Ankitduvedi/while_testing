import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:video_compress/video_compress.dart';
import 'package:com.example.while_app/resources/components/message/apis.dart';
import 'package:com.example.while_app/resources/components/message/helper/dialogs.dart';
import 'package:com.example.while_app/resources/components/round_button.dart';
import 'package:com.example.while_app/resources/components/text_container_widget.dart';
import 'package:com.example.while_app/resources/components/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:com.example.while_app/utils/utils.dart';

class AddVideo extends StatefulWidget {
  final String video;
  const AddVideo({Key? key, required this.video}) : super(key: key);

  @override
  State<AddVideo> createState() => AddVideoState();
}

class AddVideoState extends State<AddVideo> {
  late Subscription _subscription;
  bool isloading = false;
  String selectedOption = 'App Development';
  String? _selectedItem = 'App Development';

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _subscription = VideoCompress.compressProgress$.subscribe((progress) {
      debugPrint('progress: $progress');
      isloading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.unsubscribe();
  }

  compressVideo(String videoPath) async {
    final compressedVideo = await VideoCompress.compressVideo(videoPath,
        quality: VideoQuality.MediumQuality, deleteOrigin: false);
    return compressedVideo?.file;
  }

  void uploadVideo(BuildContext context, String title, String des, String path,
      List likes, int shares) async {
    setState(() {
      isloading = true;
    });
    File vid = await compressVideo(path);
    Dialogs.showSnackbar(context, vid.path.split(".").last);

// Api.video
    uploadVideo(File videoFile, String id) async {
      Dialogs.showSnackbar(context, 'Function called');
      const apiKey = 'LJd5487BMFq2YdiDxjNWeoJBPY3eqm3M0YHiw1qj7g6';
      const apiUrl = 'https://sandbox.api.video/videos';

      var request = http.MultipartRequest(
          'POST', Uri.parse('$apiUrl/$id/source'))
        ..headers['Authorization'] = 'Bearer $apiKey'
        ..files.add(await http.MultipartFile.fromPath('file', videoFile.path));

      try {
        var response = await request.send();
        Dialogs.showSnackbar(context, 'Trying');
        if (response.statusCode == 201) {
          // Video uploaded successfully
          final Map<String, dynamic> data =
              json.decode(await response.stream.bytesToString());
          //Dialogs.showSnackbar(context, data['videoId']);
          Dialogs.showSnackbar(context, data['assets']['thumbnail']);

          // final CollectionReference collectionReference =
          //     FirebaseFirestore.instance.collection('videos');
          final Map<String, dynamic> vid = {
            "uploadedBy": APIs.me.id,
            'videoUrl': data['assets']['mp4'],
            'title': title,
            'description': des,
            'likes': [],
            'views': 0,
            'thumbnail': data['assets']['thumbnail'],
            'videoRef': id
          };
          FirebaseFirestore.instance
              .collection('videos')
              .doc(_selectedItem)
              .collection(_selectedItem!)
              .doc(id)
              .set(vid)
              .then((value) {
            // Utils.toastMessage('Your video is uploaded!');
            setState(() {
              isloading = false;
            });
            Navigator.pop(context);
            return data['videoId'];
          });
        } else {
          // Handle upload failure
          Dialogs.showSnackbar(context, 'Failed');
          throw Exception('Failed to upload video');
        }
      } catch (e) {
        // Handle exceptions
        Dialogs.showSnackbar(context, e.toString());
        print('Error uploading video: $e');
        throw Exception('Failed to upload video');
      }
    }

    createVideo(String title, String description) async {
      Dialogs.showSnackbar(context, 'Called');
      const apiKey = 'LJd5487BMFq2YdiDxjNWeoJBPY3eqm3M0YHiw1qj7g6';
      const apiUrl = 'https://sandbox.api.video';
      final response = await http.post(
        Uri.parse('$apiUrl/videos'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          // 'Content-Length': '', // Add the length of the request body here
          // 'Host': 'sandbox.api.video',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        uploadVideo(vid, data['videoId']);
      } else {
        Dialogs.showSnackbar(context, 'Failed');
        throw Exception('Failed to create video');
      }
    }

    createVideo(title, des);

    print(url);
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height * 1;
    final w = MediaQuery.of(context).size.width * 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Video"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 15),
              Center(
                child: SizedBox(
                  width: w,
                  height: h / 2,
                  child: VideoPlayerWidget(videoPath: widget.video),
                ),
              ),
              const SizedBox(height: 15),
              TextContainerWidget(
                keyboardType: TextInputType.text,
                controller: _titleController,
                prefixIcon: Icons.title,
                hintText: 'Title',
              ),
              const SizedBox(height: 10),
              TextContainerWidget(
                keyboardType: TextInputType.text,
                controller: _descriptionController,
                prefixIcon: Icons.description,
                hintText: 'Description',
              ),
              FutureBuilder<List<String>>(
                future: fetchCategoriesFromFirestore(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<String>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(); // Show loading indicator while waiting for data
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    // Once data is fetched, use it to build the dropdown
                    return _buildDropDown(
                        "Select Category", _selectedItem!, snapshot.data!,
                        (String? newValue) {
                      setState(() {
                        _selectedItem = newValue;
                      });
                    });
                  }
                },
              ),
              const SizedBox(
                height: 10,
              ),
              RoundButton(
                  title: "Add Reel",
                  loading: isloading,
                  onPress: () {
                    if (_titleController.text.isEmpty) {
                      Utils.flushBarErrorMessage('Please enter title', context);
                    } else if (_descriptionController.text.isEmpty) {
                      Utils.flushBarErrorMessage(
                          'Please enter description', context);
                    } else {
                      FocusManager.instance.primaryFocus?.unfocus();
                      uploadVideo(
                          context,
                          _titleController.text.toString(),
                          _descriptionController.text.toString(),
                          widget.video.toString(),
                          [], // initally the likes list shall be holding an empty list to be precise
                          0);
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }

  Future<List<String>> fetchCategoriesFromFirestore() async {
    var categoriesSnapshot =
        await FirebaseFirestore.instance.collection('videosCategories').get();
    List<String> categories = [];
    for (var doc in categoriesSnapshot.docs) {
      String categoryName =
          doc.data()['category']; // Assuming each document has a 'name' field
      categories.add(categoryName);
    }
    return categories;
  }

  Widget _buildDropDown(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedItem,
          icon: const Icon(Icons.arrow_drop_down),
          iconSize: 24,
          elevation: 16,
          style: const TextStyle(color: Colors.deepPurple, fontSize: 18),
          onChanged: (String? newValue) {
            setState(() {
              _selectedItem = newValue!;
            });
          },
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          dropdownColor: Colors.white,
        ),
      ),
    );
  }
}
