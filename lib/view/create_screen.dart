import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:provider/provider.dart';
import 'package:while_app/resources/components/create_container.dart';
import 'package:while_app/view_model/post_provider.dart';
import 'package:while_app/view_model/reel_controller.dart';

class CreateScreen extends river.ConsumerStatefulWidget {
  const CreateScreen({Key? key}) : super(key: key);

  @override
  river.ConsumerState<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends river.ConsumerState<CreateScreen> {
  @override
  Widget build(BuildContext context) {
    //final currentTheme = ref.watch(themeNotifierProvider);
    final provider = Provider.of<ReelController>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CreateContainer(
              text: "Upload Video",
              function: () {
                provider.selectVideo(context);
              }),
          CreateContainer(
              text: "Upload Loops",
              function: () {
                provider.selectVideo(context);
              }),
          CreateContainer(
              text: "Upload Post",
              function: () {
                postProvider.selectPost(context);
              }),
        ],
      ),
    );
  }
}
