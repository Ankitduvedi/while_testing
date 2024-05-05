import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/data/model/community_user.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MyCardWidget extends StatelessWidget {
  final Map<String, dynamic> resource;
  final IconData iconData;
  final Function onTap;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Community user;

  MyCardWidget(
      {required this.resource,
      required this.iconData,
      required this.onTap,
      required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
      child: Card(
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [
                const Color(0xFFF2F2F2),
                Color.fromARGB(255, 242, 208, 192),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListTile(
            leading: Icon(iconData, size: 40),
            title: Text(
              resource['title'] ?? 'No Title', // handle null titles
              style: TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              resource['text'] != null && resource['text'].isNotEmpty
                  ? resource['text']
                  : 'No description provided',
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => onTap(),
            trailing: IconButton(
              onPressed: () => _showMenu(context),
              icon: const Icon(Icons.more_vert),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showMenu(BuildContext context) async {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final String? result = await showMenu<String>(
      context: context,
      position: position,
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'Option1',
          child: Text('Details'),
        ),
        PopupMenuItem<String>(
          value: 'Option2',
          child: Text('Download'),
        ),
        PopupMenuItem<String>(
          value: 'Option3',
          child: Text('Delete'),
        ),
      ],
      elevation: 8.0,
    );

    if (result != null) {
      switch (result) {
        case 'Option1':
          _showDetails(context);
          break;
        case 'Option2':
          _downloadItem(context);
          break;
        case 'Option3':
          _deleteItem(context);
          break;
      }
    }
  }

  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Resource Details',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name : ',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Text(
                        '${resource['title'] ?? 'No name provided '}',
                        style: TextStyle(fontSize: 15),
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description : ',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Text(
                        resource['text'] != null && resource['text'].isNotEmpty
                            ? resource['text']
                            : 'No description provided',
                        style: TextStyle(fontSize: 15),
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'File Type :',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Text(
                        ' ${resource['type'] ?? 'No type specified'}',
                        style: TextStyle(fontSize: 15),
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _downloadItem(BuildContext context) {
    launchURL(resource['url']);
  }

  void _deleteItem(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        print(user.id);
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                print('lalalalalala');
                _firestore
                    .collection('communities')
                    .doc(user.id)
                    .collection('resources')
                    .doc('${resource['id']}')
                    .delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

void launchURL(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $url';
  }
}
