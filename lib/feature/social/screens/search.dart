// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart'; // For Cupertino icons
// import 'package:google_fonts/google_fonts.dart';

// class MyCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   MyCustomAppBar({Key? key})
//       : preferredSize = Size.fromHeight(90.0),
//         super(key: key);

//   @override
//   final Size preferredSize; // default is 56.0

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       automaticallyImplyLeading: false,
//       toolbarHeight: 45,
//       backgroundColor: Colors.white,
//       elevation: 1, // Adds a subtle shadow to the AppBar for depth
//       title: AnimatedSwitcher(
//         duration: const Duration(milliseconds: 300),
//         child: toogleSearch!= 0
//             ? TextField(
//                 key: ValueKey('SearchField'),
//                 onChanged: (value) => searchValue.state = value,
//                 // decoration: InputDecoration(
//                   labelText: 'Search',
//                   labelStyle: GoogleFonts.ptSans(),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(30.0),
//                     borderSide: BorderSide.none,
//                   ),
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                   prefixIcon: Icon(Icons.search, color: Colors.black),
//                   suffixIcon: IconButton(
//                     icon: Icon(CupertinoIcons.clear_circled_solid, color: Colors.black),
//                     onPressed: () => yourClearSearchFunction(context),
//                   ),
//                 ),
//                 style: GoogleFonts.ptSans(color: Colors.black),
//               )
//             : Text(
//                 '',
//                 style: GoogleFonts.ptSans(color: Colors.black),
//               ),
//       ),
//       actions: [
//         IconButton(
//           onPressed: () => yourToggleSearchHandler(context),
//           icon: Icon(
//             yourToggleSearchFunction(context) != 0 ? CupertinoIcons.xmark : Icons.search_rounded,
//             color: Colors.black,
//           ),
//         ),
//       ],
//       bottom: TabBar(
//         controller: yourTabControllerFunction(context),
//         indicatorColor: Colors.black,
//         indicatorSize: TabBarIndicatorSize.tab,
//         labelColor: Colors.black,
//         labelStyle: GoogleFonts.ptSans(fontWeight: FontWeight.bold, fontSize: 15),
//         tabs: const [
//           Tab(text: 'Connect   '),
//           Tab(text: 'Chats  '),
//           Tab(text: 'Community'),
//           Tab(text: 'Status'),
//         ],
//       ),
//     );
//   }
// }

// // Replace placeholder functions with your actual state management hooks/methods.
