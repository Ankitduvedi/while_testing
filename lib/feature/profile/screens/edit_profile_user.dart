import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:com.while.while_app/core/utils/buttons/gradient_filled_outlined_button.dart';
import 'package:com.while.while_app/core/utils/dialogs/dialogs.dart';
import 'package:com.while.while_app/providers/apis.dart';
import 'package:com.while.while_app/providers/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/model/chat_user.dart';
import '../../../main.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class EditUserProfileScreen extends ConsumerStatefulWidget {
  const EditUserProfileScreen({super.key});

  @override
  ConsumerState<EditUserProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<EditUserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;
  final TextEditingController _dobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userProvider = ref.read(userDataProvider);
    _dobController.text = userProvider.userData?.dateOfBirth ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = ref.watch(userDataProvider);
    final user = userProvider.userData;
    final ChatUser updatedUser = user!;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Edit Profile',
            style: GoogleFonts.spaceGrotesk(
              color: const Color.fromARGB(255, 74, 70, 70),
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(width: mq.width, height: mq.height * .03),
                  _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(mq.height * .1),
                          child: Image.file(File(_image!),
                              width: mq.height * .2,
                              height: mq.height * .2,
                              fit: BoxFit.cover))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(mq.height * .1),
                          child: CachedNetworkImage(
                            width: mq.height * .2,
                            height: mq.height * .2,
                            filterQuality: FilterQuality.low,
                            fit: BoxFit.cover,
                            imageUrl: user.image,
                            errorWidget: (context, url, error) =>
                                const CircleAvatar(
                                    child: Icon(CupertinoIcons.person)),
                          ),
                        ),
                  SizedBox(height: mq.height * .03),
                  GradientFilledButton(
                    text: 'Change Picture',
                    onPressed: () {
                      _showBottomSheet();
                    },
                  ),
                  SizedBox(height: mq.height * .04),
                  TextFormField(
                    style: GoogleFonts.spaceGrotesk(
                      color: const Color.fromARGB(255, 74, 70, 70),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                    initialValue: user.about,
                    onSaved: (val) => updatedUser.about = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                    decoration: InputDecoration(
                        prefixIcon: const Icon(CupertinoIcons.info_circle),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'eg. Feeling Happy',
                        label: Text(
                          'About',
                          style: GoogleFonts.spaceGrotesk(
                            color: const Color.fromARGB(255, 74, 70, 70),
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        )),
                  ),
                  SizedBox(height: mq.height * .03),
                  TextFormField(
                    style: GoogleFonts.spaceGrotesk(
                      color: const Color.fromARGB(255, 74, 70, 70),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                    controller: _dobController,
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _dobController.text =
                              "${picked.toLocal()}".split(' ')[0];
                          updatedUser.dateOfBirth = _dobController.text;
                        });
                      }
                    },
                    onSaved: (val) => updatedUser.dateOfBirth = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                    decoration: InputDecoration(
                        prefixIcon: const Icon(CupertinoIcons.calendar),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'YYYY//MM//DD',
                        label: Text('Date Of Birth',
                            style: GoogleFonts.spaceGrotesk(
                              color: const Color.fromARGB(255, 74, 70, 70),
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ))),
                  ),
                  SizedBox(height: mq.height * .03),
                  TextFormField(
                    style: GoogleFonts.spaceGrotesk(
                      color: const Color.fromARGB(255, 74, 70, 70),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                    initialValue: user.gender,
                    onSaved: (val) => updatedUser.gender = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                    decoration: InputDecoration(
                        prefixIcon: const Icon(
                            CupertinoIcons.person_crop_circle_badge_exclam),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'Male/ Female/ Not to disclose',
                        label: Text('Gender',
                            style: GoogleFonts.spaceGrotesk(
                              color: const Color.fromARGB(255, 74, 70, 70),
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ))),
                  ),
                  SizedBox(height: mq.height * .03),
                  TextFormField(
                    style: GoogleFonts.spaceGrotesk(
                      color: const Color.fromARGB(255, 74, 70, 70),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                    initialValue: user.place,
                    onSaved: (val) => updatedUser.place = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                    decoration: InputDecoration(
                        prefixIcon: const Icon(CupertinoIcons.placemark),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'India',
                        label: Text('Place',
                            style: GoogleFonts.spaceGrotesk(
                              color: const Color.fromARGB(255, 74, 70, 70),
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ))),
                  ),
                  SizedBox(height: mq.height * .03),
                  TextFormField(
                    style: GoogleFonts.spaceGrotesk(
                      color: const Color.fromARGB(255, 74, 70, 70),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                    initialValue: user.profession,
                    onSaved: (val) => updatedUser.profession = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                    decoration: InputDecoration(
                        prefixIcon:
                            const Icon(CupertinoIcons.person_badge_plus),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'Student/ Engineer/ etc..',
                        label: Text('Profession',
                            style: GoogleFonts.spaceGrotesk(
                              color: const Color.fromARGB(255, 74, 70, 70),
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ))),
                  ),
                  SizedBox(height: mq.height * .03),
                  IntlPhoneField(
                    style: GoogleFonts.spaceGrotesk(
                      color: const Color.fromARGB(255, 74, 70, 70),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                    initialValue: user.phoneNumber,
                    onSaved: (phone) {
                      updatedUser.phoneNumber = phone!.completeNumber;
                    },
                    validator: (phone) {
                      if (phone == null || phone.completeNumber.length != 10) {
                        return 'Phone number must be 10 digits';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(CupertinoIcons.phone_badge_plus),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: '+91766836XXXX',
                      label: Text('Phone Number',
                          style: GoogleFonts.spaceGrotesk(
                            color: const Color.fromARGB(255, 74, 70, 70),
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          )),
                    ),
                  ),
                  SizedBox(height: mq.height * .04),
                  GradientFilledbutton(
                    text: 'Update',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        userProvider.updateUserData(updatedUser);
                        Dialogs.showSnackbar(
                            context, 'Profile Updated Successfully!');
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 15),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // bottom sheet for picking a profile picture for user
  void _showBottomSheet() {
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

                          ref
                              .read(apisProvider)
                              .updateProfilePicture(File(_image!));
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

                          ref
                              .read(apisProvider)
                              .updateProfilePicture(File(_image!));
                          // for hiding bottom sheet
                          Navigator.pop(context);
                        }
                      },
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.black,
                        size: mq.width * .2,
                      )),
                ],
              )
            ],
          );
        });
  }
}

class GradientFilledbutton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Gradient gradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromRGBO(230, 77, 255, 1),
      Color.fromRGBO(123, 68, 212, 1),
    ],
  );

  const GradientFilledbutton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
