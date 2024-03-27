import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.example.while_app/feature/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:video_compress/video_compress.dart';

import 'package:com.while.while_app/resources/components/round_button.dart';
import 'package:com.while.while_app/resources/components/text_container_widget.dart';
import 'package:com.while.while_app/resources/components/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:com.while.while_app/utils/utils.dart';

class AddReel extends ConsumerStatefulWidget {
  final String _video;
  const AddReel({super.key, required String video}) : _video = video;

  @override
  ConsumerState<AddReel> createState() => _AddReelState();
}

class _AddReelState extends ConsumerState<AddReel> {
  late Subscription _subscription;
  bool isloading = false;

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


  Future<void> uploadVideo(
      String title, String des, String path, List likes, int shares) async {
    setState(() {
      isloading = true;
    });
    File vid = await compressVideo(path);
    // Dialogs.showSnackbar(context, vid.path.split(".").last);
    // DateTime now = DateTime.now();
    // File video = _compressVideo(path);
    // File video = File(path);
    // var stream = http.ByteStream(video.openRead().cast());
    // var length = video.lengthSync();
    // var uri = Uri.parse('http://13.233.151.213:3000/reels');
    // var request = http.MultipartRequest('POST', uri)
    //   ..files.add(http.MultipartFile('video', stream, length,
    //       filename: basename(video.path)));
    // // await request.send();
    // try {
    //   final response = await http.Response.fromStream(await request.send());

    //   if (response.statusCode == 200) {
    //     // Parse the URL from the response
    //     // final Map<String, dynamic> jsonResponse =
    //     String videoUrl = json.decode(response.body);
    //     Dialogs.showSnackbar(context, videoUrl);
    //     final CollectionReference collectionReference =
    //         FirebaseFirestore.instance.collection('videos');
    //     final Map<String, dynamic> vid = {
    //       "uploadedBy": APIs.me.id,
    //       'videoUrl': videoUrl,
    //       'title': title,
    //       'description': des,
    //       'likes': [],
    //       'views': 0
    //     };
    //     collectionReference.add(vid).then((value) {
    //       // Utils.toastMessage('Your video is uploaded!');
    //       setState(() {
    //         isloading = false;
    //       });
    //       Navigator.pop(context);
    //     }).onError((error, stackTrace) {
    //       Utils.toastMessage(error.toString());
    //     });
    //     // Now you can use the videoUrl as needed, for example, storing it in a variable or database
    //     print('Uploaded video URL: $videoUrl');

    //     // You can use the videoUrl as needed, for example, store it in a variable, database, etc.
    //     // You can then use this URL to display the video or perform other operations.
    //   } else {
    //     print('Failed to upload video. Status code: ${response.statusCode}');
    //   }
    // } catch (error) {
    //   print('Error uploading video: $error');
    // }
// Api.video
    Future<void> uploadVideo(File videoFile, String id) async {
      // Dialogs.showSnackbar(context, 'Function called');
      const apiKey = 'LJd5487BMFq2YdiDxjNWeoJBPY3eqm3M0YHiw1qj7g6';
      const apiUrl = 'https://sandbox.api.video/videos';

      var request = http.MultipartRequest(
          'POST', Uri.parse('$apiUrl/$id/source'))
        ..headers['Authorization'] = 'Bearer $apiKey'
        ..files.add(await http.MultipartFile.fromPath('file', videoFile.path));

      try {
        var response = await request.send();
        // Dialogs.showSnackbar(context, 'Trying');
        if (response.statusCode == 201) {
          // Video uploaded successfully
          final Map<String, dynamic> data =
              json.decode(await response.stream.bytesToString());
          //Dialogs.showSnackbar(context, data['videoId']);
          // Dialogs.showSnackbar(context, data['assets']['thumbnail']);

          // final CollectionReference collectionReference =
          //     FirebaseFirestore.instance.collection('videos');
          final Map<String, dynamic> vid = {
            "uploadedBy": ref.read(userProvider)!.id,
            'videoUrl': data['assets']['mp4'],
            'title': title,
            'description': des,
            'likes': [],
            'views': 0,
            'thumbnail': data['assets']['thumbnail'],
          };
          FirebaseFirestore.instance
              .collection('loops')
              .doc(id)
              .set(vid)
              .then((value) {
            // Utils.toastMessage('Your video is uploaded!');
            setState(() {
              isloading = false;
            });
            // Navigator.pop(context);
            return data['videoId'];
          });
        } else {
          // Handle upload failure
          // Dialogs.showSnackbar(context, 'Failed');
          throw Exception('Failed to upload video');
        }
      } catch (e) {
        // Handle exceptions
        // Dialogs.showSnackbar(context, e.toString());
        throw Exception('Failed to upload video');
      }
    }

    createVideo(String title, String description) async {
      // Dialogs.showSnackbar(context, 'Called');
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
        // Dialogs.showSnackbar(context, 'Failed');
        throw Exception('Failed to create video');
      }
    }

    createVideo(title, des);

    // print(url);

    // firebase_storage.Reference storageRef = firebase_storage
    //     .FirebaseStorage.instance
    //     .ref('content/${FirebaseSessionController().uid!}/video/$now');
    // firebase_storage.UploadTask uploadTask =
    //     storageRef.putFile(await _compressVideo(path));

    // await Future.value(uploadTask);

    // final newUrl = await storageRef.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height * 1;
    final w = MediaQuery.of(context).size.width * 1;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Reel"),
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
                  child: VideoPlayerWidget(videoPath: widget._video),
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
              const SizedBox(
                height: 10,
              ),
              RoundButton(
                  title: "Add Reel",
                  loading: isloading,
                  onPress: () async {
                    if (_titleController.text.isEmpty) {
                      Utils.flushBarErrorMessage('Please enter title', context);
                    } else if (_descriptionController.text.isEmpty) {
                      Utils.flushBarErrorMessage(
                          'Please enter description', context);
                    } else {
                      FocusManager.instance.primaryFocus?.unfocus();
                      await uploadVideo(
                          _titleController.text.toString(),
                          _descriptionController.text.toString(),
                          widget._video.toString(),
                          [], // initally the likes list shall be holding an empty list to be precise
                          0);
                      Navigator.of(context).pop();
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }
}
