// import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
// import 'package:com.while.while_app/feature/creator/controller/creator_contoller.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';

// class BecomeCounsellor extends ConsumerStatefulWidget {
//   const BecomeCounsellor({
//     super.key,
//   });

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() =>
//       _BecomeCounsellorState();
// }

// class _BecomeCounsellorState extends ConsumerState<BecomeCounsellor> {
//   final TextEditingController _instagramController = TextEditingController();
//   final TextEditingController _youtubeController = TextEditingController();
//   final TextEditingController _organisationController = TextEditingController();

//   @override
//   void dispose() {
//     _instagramController.dispose();
//     _youtubeController.dispose();
//     _organisationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isLoading = ref.watch(creatorControllerProvider);
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Text(
//             'Become Counsellor',
//             style: GoogleFonts.ptSans(
//                 color: Colors.lightBlueAccent,
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 20),
//           TextField(
//             controller: _instagramController,
//             decoration: const InputDecoration(
//               border: OutlineInputBorder(),
//               labelText: 'Instagram Link',
//             ),
//           ),
//           TextField(
//             controller: _instagramController,
//             decoration: const InputDecoration(
//               border: OutlineInputBorder(),
//               labelText: 'Instagram Link',
//             ),
//           ),
//           const SizedBox(height: 10),
//           TextField(
//             controller: _organisationController,
//             decoration: const InputDecoration(
//               border: OutlineInputBorder(),
//               labelText: 'Organisation name',
//             ),
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () async {
//               // Add your submission logic here
//               ref
//                   .watch(creatorControllerProvider.notifier)
//                   .submitCreatorRequest(
//                       ref.read(userProvider)!.id,
//                       _instagramController.text.trim(),
//                       _youtubeController.text.trim());
//             },
//             style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.lightBlueAccent),
//             child: isLoading
//                 ? const CircularProgressIndicator()
//                 : const Text('Submit'),
//           ),
//         ],
//       ),
//     );
//   }
// }
