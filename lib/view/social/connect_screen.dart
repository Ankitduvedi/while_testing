import 'dart:async';
import 'package:com.example.while_app/view/profile/community_connect.dart';
import 'package:com.example.while_app/view/profile/demo.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.example.while_app/resources/components/message/apis.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectScreen extends ConsumerStatefulWidget {
  const ConnectScreen({Key? key}) : super(key: key);

  @override
  ConnectScreenState createState() => ConnectScreenState();
}

class ConnectScreenState extends ConsumerState<ConnectScreen>
    with SingleTickerProviderStateMixin {
  late Stream<QuerySnapshot> peopleStream;
  late Stream<QuerySnapshot> pagesStream;
  late TabController _tabController;
  late String userId; // Add the user's ID here

  @override
  void initState() {
    super.initState();
    // Initialize Firestore streams
    peopleStream = FirebaseFirestore.instance.collection('users').snapshots();
    pagesStream =
        FirebaseFirestore.instance.collection('communities').snapshots();

    // Initialize the TabController
    _tabController = TabController(length: 2, vsync: this);

    // Replace 'yourUserId' with the actual user ID (you can get it from Firebase Authentication)
    userId = APIs.me.id;
  }

  @override
  void dispose() {
    // Dispose the TabController
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        tabs: const [
          Tab(
            text: 'People',
          ),
          Tab(
            text: 'Communities',
          ),
        ],
        labelColor: Colors.white, // Set the text color of the selected tab
        unselectedLabelColor:
            Colors.grey, // Set the text color of unselected tabs
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          Connect(),
          CommunityConnect(),
          //_buildPagesTab(),
        ],
      ),
    );
  }

  // Widget _buildPagesTab() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Padding(
  //         padding: EdgeInsets.all(16.0),
  //         child: Text(
  //           'Communities to Join:',
  //           style: TextStyle(
  //               fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
  //         ),
  //       ),
  //       Expanded(
  //         child: StreamBuilder<QuerySnapshot>(
  //           stream: pagesStream,
  //           builder: (context, snapshot) {
  //             if (snapshot.connectionState == ConnectionState.waiting) {
  //               return const Center(child: CircularProgressIndicator());
  //             }
  //             if (snapshot.hasError) {
  //               return Center(child: Text('Error: ${snapshot.error}'));
  //             }

  //             final pagesDocs = snapshot.data!.docs;

  //             // Fetch the list of communities that the current user is following
  //             return StreamBuilder<QuerySnapshot>(
  //               stream: FirebaseFirestore.instance
  //                   .collection('users')
  //                   .doc(APIs.me.id)
  //                   .collection('my_communities')
  //                   .snapshots(),
  //               builder: (context, followingSnapshot) {
  //                 if (followingSnapshot.connectionState ==
  //                     ConnectionState.waiting) {
  //                   return const Center(child: CircularProgressIndicator());
  //                 }
  //                 if (followingSnapshot.hasError) {
  //                   return Center(
  //                       child: Text('Error: ${followingSnapshot.error}'));
  //                 }

  //                 final followingDocs = followingSnapshot.data!.docs
  //                     .map((doc) => doc.id)
  //                     .toList();

  //                 // Filter out the communities that are already followed by the user
  //                 final filteredCommunities = pagesDocs.where((pageDoc) {
  //                   final page = pageDoc.data() as Map<String, dynamic>;
  //                   final pageId = page['id'];
  //                   return !followingDocs.contains(pageId);
  //                 }).toList();

  //                 return ListView.builder(
  //                   itemCount: filteredCommunities.length,
  //                   itemBuilder: (context, index) {
  //                     final page = filteredCommunities[index].data()
  //                         as Map<String, dynamic>;

  //                     return ListTile(
  //                       leading: ClipRRect(
  //                         borderRadius: BorderRadius.circular(mq.height * .03),
  //                         child: CachedNetworkImage(
  //                           width: mq.height * .055,
  //                           height: mq.height * .055,
  //                           fit: BoxFit.fill,
  //                           imageUrl: page['image'],
  //                           errorWidget: (context, url, error) =>
  //                               const CircleAvatar(
  //                                   child: Icon(CupertinoIcons.person)),
  //                         ),
  //                       ),
  //                       title: Text(
  //                         page['name'],
  //                         style: const TextStyle(color: Colors.white),
  //                       ),
  //                       subtitle: Text(
  //                         page['domain'],
  //                         style: const TextStyle(color: Colors.white),
  //                       ),
  //                       trailing: ElevatedButton(
  //                         style: TextButton.styleFrom(
  //                             elevation: 4,
  //                             backgroundColor:
  //                                 const Color.fromARGB(255, 235, 235, 235)),
  //                         onPressed: () async {
  //                           await APIs.addUserToCommunity(page['id'])
  //                               .then((value) {
  //                             if (value) {
  //                               Dialogs.showSnackbar(
  //                                   context, 'Community Added');
  //                             }
  //                           });
  //                         },
  //                         child: const Text(
  //                           'Join',
  //                           style: TextStyle(color: Colors.black),
  //                         ),
  //                       ),
  //                     );
  //                   },
  //                 );
  //               },
  //             );
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
