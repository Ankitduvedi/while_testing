import 'package:com.example.while_app/feature/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:com.example.while_app/resources/components/text_button.dart';

class Settings extends ConsumerWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Settings",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back, color: Colors.black)),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const ListTile(
                      leading: Icon(Icons.people_outline),
                      title: Text("Follow and invite friends")),
                  const ListTile(
                      leading: Icon(Icons.notifications),
                      title: Text("Notifications")),
                  const ListTile(
                      leading: Icon(Icons.lock), title: Text("Privacy")),
                  const ListTile(
                      leading: Icon(Icons.people), title: Text("Supervision")),
                  const ListTile(
                      leading: Icon(Icons.security), title: Text("Security")),
                  const ListTile(
                      leading: Icon(Icons.play_arrow),
                      title: Text("Suggested Content")),
                  const ListTile(
                      leading: Icon(Icons.announcement),
                      title: Text("Announcement")),
                  const ListTile(
                      leading: Icon(Icons.account_box), title: Text("Account")),
                  const ListTile(
                      leading: Icon(Icons.help), title: Text("Help")),
                  const ListTile(
                    leading: Icon(Icons.sunny_snowing),
                    title: Text("Theme"),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Textbutton(
                        ontap: () {
                          ref.read(toggleStateProvider.notifier).state = 0;
                          ref.read(authControllerProvider);
                          SystemNavigator.pop(); // Close the app

                          //Navigator.of(context).pop();
                        },
                        text: "Logout"),
                  )
                ],
              ),
            )
          ]),
        ));
  }
}
