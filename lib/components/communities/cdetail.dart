import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:com.while.while_app/components/communities/resources/community_detail_resources_widget%20.dart';
import 'package:flutter/material.dart';
import 'package:com.while.while_app/components/communities/opportunities/community_detail_opportunities_widget.dart';
import 'package:com.while.while_app/components/communities/quiz/community_detail_quiz_widget.dart';
import 'package:com.while.while_app/components/message/apis.dart';
import 'package:com.while.while_app/components/communities/profile_screen_community_admin.dart';
import 'package:com.while.while_app/components/message/widgets/profileCommunity_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';
import 'cchat.dart';
import '../../data/model/community_user.dart';
import 'package:google_fonts/google_fonts.dart';

class CCommunityDetailScreen extends ConsumerStatefulWidget {
  const CCommunityDetailScreen({Key? key, required this.user})
      : super(key: key);
  final Community user;
  @override
  ConsumerState<CCommunityDetailScreen> createState() =>
      _CCommunityDetailScreenState();
}

class _CCommunityDetailScreenState
    extends ConsumerState<CCommunityDetailScreen> {
  /// List of Tab Bar Item

  List<String> itemsName = const [
    'Chat',
    'Resources',
    'Opportunites',
    'Quiz',
  ];
  int current = 0;

  @override
  Widget build(BuildContext context) {
    var keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    log(keyboardSpace.toString());
    List items = [
      CChatScreen(
        user: widget.user,
      ),
      const CommunityDetailResources(),
      OpportunitiesScreen(
        user: widget.user,
      ),
      QuizScreen(
        user: widget.user,
      ),
    ];
    return Scaffold(
      backgroundColor: Colors.white,

      /// APPBAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () {
            if (widget.user.email == ref.read(apisProvider).me.email) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ProfileScreen(user: widget.user)));
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          ProfileScreenParticipant(user: widget.user)));
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back, color: Colors.blue.shade300)),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  width: 42,
                  height: 42,
                  imageUrl: widget.user.image,
                  fit: BoxFit.fill,
                  placeholder: (context, url) => const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (context, url, error) => const Icon(
                      Icons.broken_image,
                      size: 70,
                      color: Colors.black12),
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Text(widget.user.name,
                  style: GoogleFonts.ptSans(
                      color: Colors.black, fontWeight: FontWeight.w400)),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          /// CUSTOM TABBAR
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: items.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (ctx, index) {
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            current = index;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(top: 10, left: 12),
                          width: itemsName[index].length.toDouble() * 4 + 60,
                          height: 45,
                          decoration: BoxDecoration(
                            color: current == index
                                ? Colors.white
                                : Colors.white70,
                            borderRadius: current == index
                                ? BorderRadius.circular(15)
                                : BorderRadius.circular(10),
                            border: current == index
                                ? Border.all(
                                    color: Colors.grey.shade800, width: 2)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              itemsName[index],
                              style: GoogleFonts.ptSans(),
                              // style: GoogleFonts.laila(
                              //     fontWeight: FontWeight.w500,
                              //     color: current == index
                              //         ? Colors.black
                              //         : Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
          ),

          /// MAIN BODY

          SingleChildScrollView(
            child: SizedBox(
              height: mq.height - keyboardSpace - mq.height / 5.2,
              child: items[current],
            ),
          ),
        ],
      ),
    );
  }
}
