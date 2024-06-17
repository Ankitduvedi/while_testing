import 'package:com.while.while_app/feature/social/screens/connect/communities_connect/community_connect.dart';
import 'package:com.while.while_app/feature/social/screens/connect/people/connect_people.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class ConnectScreen extends ConsumerStatefulWidget {
  const ConnectScreen({Key? key}) : super(key: key);

  @override
  ConnectScreenState createState() => ConnectScreenState();
}

class ConnectScreenState extends ConsumerState<ConnectScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize the TabController
    _tabController = TabController(length: 2, vsync: this);
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
      backgroundColor: Colors.white,
      appBar: TabBar(
        controller: _tabController,
        indicatorColor: Colors.black,
        tabs: const [
          Tab(
            text: 'People',
          ),
          Tab(
            text: 'Communities',
          ),
        ],
        labelColor: Colors.black,
        labelStyle: GoogleFonts.ptSans(
            fontWeight:
                FontWeight.w700), // Set the text color of the selected tab
        unselectedLabelColor:
            Colors.grey, // Set the text color of unselected tabs
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          Connect(),
          CommunityConnect(),
        ],
      ),
    );
  }
}
