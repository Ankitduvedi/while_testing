// ignore_for_file: use_build_context_synchronously
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:com.while.while_app/feature/social/controller/social_controller.dart';
import 'package:com.while.while_app/feature/social/screens/community/resources/avail_users_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:com.while.while_app/data/model/chat_user.dart';
import '../../../../../main.dart';
import '../../../../../providers/apis.dart';
import '../../../../../core/utils/dialogs/dialogs.dart';
import '../../../../../data/model/community_user.dart';

//profile screen -- to show signed in user info
class ProfileScreen extends ConsumerStatefulWidget {
  final Community community;

  const ProfileScreen({super.key, required this.community});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  String? _image;

  void _openUserListDialog(String id, List<ChatUser> listUsers) {
    log("community id$id");
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (ctx) => UserListDialog(
                  commId: id,
                  list: listUsers,
                )));
  }

  // Initialize the TextEditingController in your state
  // final TextEditingController _textFieldController = TextEditingController();

// Later, when you want to access the edited text:

  @override
  Widget build(BuildContext context) {
    final fireService = ref.read(apisProvider);
    String designation = "";
    List<ChatUser> list = [];
    final Community community = Community.empty();
    community.id = widget.community.id;
    return GestureDetector(
      // for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          //app bar
          appBar: AppBar(
            title: Text(
              widget.community.name,
              style: const TextStyle(color: Colors.black),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  CupertinoIcons.person_add_solid,
                  size: 28,
                  color: Colors.deepPurple,
                ),
                onPressed: () {
                  _openUserListDialog(widget.community.id, list);
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    log(community.toJson().toString());
                    fireService.updateCommunityInfo(community).then((value) {
                      Dialogs.showSnackbar(
                          context, 'Added Users Successfully!');
                    });
                  }
                },
              ),
            ],
          ),

          //body
          body: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // for adding some space
                    SizedBox(width: mq.width, height: mq.height * .03),

                    //user profile picture
                    Stack(
                      children: [
                        //profile picture
                        _image != null
                            ?
                            //local image
                            ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * .1),
                                child: Image.file(File(_image!),
                                    width: mq.height * .2,
                                    height: mq.height * .2,
                                    fit: BoxFit.cover))
                            :
                            //image from server
                            ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * .1),
                                child: CachedNetworkImage(
                                  width: mq.height * .2,
                                  height: mq.height * .2,
                                  filterQuality: FilterQuality.low,
                                  fit: BoxFit.cover,
                                  imageUrl: widget.community.image,
                                  errorWidget: (context, url, error) =>
                                      const CircleAvatar(
                                          child: Icon(CupertinoIcons.person)),
                                ),
                              ),

                        //edit image button
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: MaterialButton(
                            elevation: 1,
                            onPressed: () {
                              _showBottomSheet(fireService);
                            },
                            shape: const CircleBorder(),
                            color: Colors.white,
                            child: const Icon(Icons.edit, color: Colors.blue),
                          ),
                        )
                      ],
                    ),

                    // for adding some space
                    SizedBox(height: mq.height * .03),

                    // user email label
                    Text(widget.community.email,
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 16)),

                    // for adding some space
                    SizedBox(height: mq.height * .05),

                    // name input field
                    TextFormField(
                      initialValue: widget.community.name,
                      onSaved: (val) => community.name = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.person, color: Colors.blue),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          hintText: 'eg. Happy Singh',
                          label: const Text('Name')),
                    ),

                    // for adding some space
                    SizedBox(height: mq.height * .02),

                    // about input field
                    TextFormField(
                      initialValue: widget.community.about,
                      onSaved: (val) => community.about = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.info_outline,
                              color: Colors.blue),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          hintText: 'eg. Feeling Happy',
                          label: const Text('About')),
                    ),
                    SizedBox(height: mq.height * .02),

                    // domain input field
                    TextFormField(
                      initialValue: widget.community.domain,
                      onSaved: (val) => community.domain = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.info_outline,
                              color: Colors.blue),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          hintText: 'eg. Feeling Happy',
                          label: const Text('Domain')),
                    ),
                    SizedBox(height: mq.height * .02),

                    // email input field
                    TextFormField(
                      initialValue: widget.community.email,
                      onSaved: (val) => community.email = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.info_outline,
                              color: Colors.blue),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          hintText: 'eg. Feeling Happy',
                          label: const Text('Email')),
                    ),

                    // for adding some space
                    SizedBox(height: mq.height * .05),

                    // update profile button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          minimumSize: Size(mq.width * .5, mq.height * .06)),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          log(community.toJson().toString());
                          fireService
                              .updateCommunityInfo(community)
                              .then((value) {
                            Dialogs.showSnackbar(
                                context, 'Profile Updated Successfully!');
                          });
                        }
                      },
                      icon: const Icon(Icons.edit, size: 28),
                      label:
                          const Text('UPDATE', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(
                      height: 20,
                    ),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Participants',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),

                    SingleChildScrollView(
                      child: StreamBuilder(
                          stream: fireService.getCommunityParticipantsInfo(
                              widget.community.id),
                          builder: (context, snapshot) {
                            switch (snapshot.connectionState) {
                              //if data is loading
                              case ConnectionState.waiting:
                              case ConnectionState.none:
                                return const SizedBox();

                              //if some or all data is loaded then show it
                              case ConnectionState.active:
                              case ConnectionState.done:
                                final data = snapshot.data?.docs;
                                list = data
                                        ?.map(
                                            (e) => ChatUser.fromJson(e.data()))
                                        .toList() ??
                                    [];

                                if (list.isNotEmpty) {
                                  log(list.length.toString());
                                  return Column(
                                    children: [
                                      // Add participants
                                      ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: snapshot.data!.docs.length,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Card(
                                                margin: const EdgeInsets.only(
                                                    left: 0, right: 0),
                                                color: Colors.white,
                                                // elevation: 2,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                                child: ListTile(
                                                  subtitle:
                                                      Text(list[index].email),
                                                  onLongPress: () {
                                                    // Show a dialog with the option to delete the user
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: Text(
                                                              list[index].name),
                                                          content: Form(
                                                            key: _formKey2,
                                                            child:
                                                                TextFormField(
                                                              initialValue: list[
                                                                      index]
                                                                  .designation,
                                                              onSaved: (val) {
                                                                setState(() {
                                                                  designation =
                                                                      val!;
                                                                });
                                                              },
                                                              validator: (val) =>
                                                                  val != null &&
                                                                          val.isNotEmpty
                                                                      ? null
                                                                      : 'Required Field',
                                                              decoration: InputDecoration(
                                                                  prefixIcon: const Icon(
                                                                      Icons
                                                                          .info_outline,
                                                                      color: Colors
                                                                          .blue),
                                                                  border: OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              12)),
                                                                  hintText:
                                                                      'eg. Feeling Happy',
                                                                  label: const Text(
                                                                      'Designation')),
                                                            ),
                                                          ),
                                                          actions: [
                                                            OutlinedButton(
                                                              onPressed: () {
                                                                ref
                                                                    .read(socialControllerProvider
                                                                        .notifier)
                                                                    .removeUserFromCommunity(
                                                                        community
                                                                            .id,
                                                                        list[index]
                                                                            .id,
                                                                        context);
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(); // Close the dialog
                                                              },
                                                              child: const Text(
                                                                  'Remove User'),
                                                            ),
                                                            //upddate button
                                                            TextButton(
                                                              onPressed: () {
                                                                if (_formKey2
                                                                    .currentState!
                                                                    .validate()) {
                                                                  _formKey2
                                                                      .currentState!
                                                                      .save();

                                                                  ref.read(socialControllerProvider.notifier).uddateDesignation(
                                                                      community
                                                                          .id,
                                                                      list[index]
                                                                          .id,
                                                                      designation,
                                                                      context);
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                }
                                                              },
                                                              child: const Text(
                                                                  'Update'),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                  leading: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    child: CachedNetworkImage(
                                                      width: 42,
                                                      height: 42,
                                                      imageUrl:
                                                          list[index].image,
                                                      fit: BoxFit.fill,
                                                      placeholder:
                                                          (context, url) =>
                                                              const Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child:
                                                            CircularProgressIndicator(
                                                                strokeWidth: 2),
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          const Icon(
                                                              Icons.image,
                                                              size: 70),
                                                    ),
                                                  ),
                                                  title: Text(list[index].name),
                                                  trailing:
                                                      widget.community.email ==
                                                              list[index].email
                                                          ? const Text('Admin')
                                                          : Text(list[index]
                                                              .designation),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                )),
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                } else {
                                  return const Text(
                                    'No Data to show',
                                    style: TextStyle(color: Colors.grey),
                                  );
                                }
                            }
                          }),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  // bottom sheet for picking a profile picture for user
  void _showBottomSheet(fireservice) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .05),
            children: [
              //pick profile picture label
              const Text('Pick Profile Picture',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),

              //for adding some space
              SizedBox(height: mq.height * .02),

              //buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //pick from gallery button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery, imageQuality: 80);
                        if (image != null) {
                          log('Image Path: ${image.path}');
                          setState(() {
                            _image = image.path;
                          });

                          fireservice.updateProfilePictureCommunity(
                              File(_image!), widget.community.id);
                          // for hiding bottom sheet
                          Navigator.pop(context);
                        }
                      },
                      child: Icon(
                        Icons.image,
                        color: Colors.black,
                        size: mq.width * .2,
                      )),

                  //take picture from camera button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 80);
                        if (image != null) {
                          log('Image Path: ${image.path}');
                          setState(() {
                            _image = image.path;
                          });

                          fireservice.updateProfilePictureCommunity(
                              File(_image!), widget.community.id);
                          // for hiding bottom sheet
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/camera.png')),
                ],
              )
            ],
          );
        });
  }
}
