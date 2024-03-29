import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/data/model/reels_models.dart';
import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
import 'package:com.while.while_app/resources/components/message/helper/dialogs.dart';
import 'package:com.while.while_app/resources/components/round_button.dart';
import 'package:com.while.while_app/resources/components/text_container_widget.dart';
import 'package:com.while.while_app/resources/components/video_player.dart';
import 'package:com.while.while_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_compress/video_compress.dart';
import 'package:http/http.dart' as http;

class AddReel extends ConsumerStatefulWidget {
  final String video;
  const AddReel({Key? key, required this.video}) : super(key: key);

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

  void uploadVideo(BuildContext context, String title, String des, String path,
      List likes, int shares) async {
    setState(() {
      isloading = true;
    });
    File vid = await compressVideo(path);
    Dialogs.showSnackbar(context, vid.path.split(".").last);
// Api.video
    uploadVideo(File videoFile, String id) async {
      //Dialogs.showSnackbar(context, 'Function called');
      const apiKey = 'LJd5487BMFq2YdiDxjNWeoJBPY3eqm3M0YHiw1qj7g6';
      const apiUrl = 'https://sandbox.api.video/videos';

      var request = http.MultipartRequest(
          'POST', Uri.parse('$apiUrl/$id/source'))
        ..headers['Authorization'] = 'Bearer $apiKey'
        ..files.add(await http.MultipartFile.fromPath('file', videoFile.path));

      try {
        var response = await request.send();
        //Dialogs.showSnackbar(context, 'Trying');
        if (response.statusCode == 201) {
          // Video uploaded successfully
          final Map<String, dynamic> data =
              json.decode(await response.stream.bytesToString());
          //Dialogs.showSnackbar(context, data['videoId']);
          //Dialogs.showSnackbar(context, data['assets']['thumbnail']);
          final Loops loop = Loops(
              id: id,
              uploadedBy: ref.read(userProvider)!.id,
              videoUrl: data['assets']['mp4'],
              thumbnail: data['assets']['thumbnail'],
              title: title,
              description: des,
              likes: likes,
              views: 0,
              category: 'category');

          FirebaseFirestore.instance
              .collection('loops')
              .doc(id)
              .set(loop.toJson())
              .then((value) {
            FirebaseFirestore.instance
                .collection('users')
                .doc(ref.read(userProvider)!.id)
                .collection('loops')
                .doc(id)
                .set(loop.toJson());
            Utils.toastMessage('Your video is uploaded!');
            setState(() {
              isloading = false;
            });
            Navigator.pop(context);
            return data['videoId'];
          });
        } else {
          // Handle upload failure
          //Dialogs.showSnackbar(context, 'Failed');
          throw Exception('Failed to upload video');
        }
      } catch (e) {
        // Handle exceptions
        //Dialogs.showSnackbar(context, e.toString());
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
}
