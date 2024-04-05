// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/core/enums/firebase_providers.dart';
import 'package:com.while.while_app/data/model/chat_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import '../data/model/community_message.dart';
import '../data/model/community_user.dart';
import '../data/model/message.dart';

String userImage = '';
final apisProvider = Provider<APIs>((ref) {
  return APIs(ref: ref);
});

final userDataProviderMain = StreamProvider.family((ref, String uid) {
  final apiController = ref.watch(apisProvider);
  return apiController.getUserInfo(uid);
});

class APIs {
  // for authentication
  final Ref _ref;
  //static FirebaseStorage storage = FirebaseStorage.instance;

  APIs({required Ref ref}) : _ref = ref;

  FirebaseAuth get auth => _ref.read(authProvider);

  // for accessing cloud firestore database
  FirebaseFirestore get firestore => _ref.read(fireStoreProvider);

  // for accessing firebase storage
  FirebaseStorage get storage => _ref.read(firebaseStorageProvider);

  // for storing self information

  ChatUser me = ChatUser.empty();

  // to return current user
  User get user => auth.currentUser!;

  // for accessing firebase messaging (Push Notification)
  FirebaseMessaging get fMessaging => _ref.read(firebaseMessagingProvider);

  // for getting firebase messaging token

  // adding content creator request
  void postStatus(File imageFile, String statText) async {
    final statusText = statText;
    final userId =
        _ref.read(apisProvider).me.id; // Replace with the actual user's ID

    // Upload the image to Firebase Storage
    final storageReference =
        FirebaseStorage.instance.ref().child('$userId/${DateTime.now()}.png');
    await storageReference.putFile(imageFile);

    // Get the image URL from Firebase Storage
    final imageUrl = await storageReference.getDownloadURL();

    FirebaseFirestore.instance.collection('statuses').add({
      'userId': userId,
      'userName': _ref.read(apisProvider).me.name,
      'profileImg': _ref.read(apisProvider).me.image,
      'statusText': statusText,
      'imageUrl': imageUrl, // Add the URL of the uploaded image
      'timestamp': FieldValue.serverTimestamp(),
      // Add other necessary fields like user name and profile image URL
    });
  }

  // for sending push notification
  Future<void> sendPushNotification(ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": me.name, //our name should be send
          "body": msg,
          "android_channel_id": "chats"
        },
        "data": {
          "some_data": "User ID: ${me.id}",
        },
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAAsNkZIGs:APA91bGeaCnMuqtGmil4H3ZKYVQ_9aaWIZlqd1hvrBzJlaKIUYl-w2XCycnvx8l5Iis61lezhZzdjphO4kYG0ahxTZUiz0fMdcaiKyZ3SjQxlt_y57i4sc3npUM4jjgoA7kUSawYYTDt'
          },
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }

  // for checking if user exists or not?
  Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  // for adding an chat user for our conversation
  Future<bool> addChatUserdailog(String id) async {
    final data =
        await firestore.collection('users').where('email', isEqualTo: id).get();
    firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .doc(data.docs.first.id)
        .set({'timeStamp': FieldValue.serverTimestamp()});
    following(data.docs.first.id);
    follower(data.docs.first.id);
    return true;
  }

  Future<bool> addChatUser(String id) async {
    firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .doc(id)
        .set({'timeStamp': FieldValue.serverTimestamp()});
    following(id);
    follower(id);
    return true;
  }

  Future<bool> unfollow(String id) async {
    firestore
        .collection('users')
        .doc(user.uid)
        .collection('following')
        .doc(id)
        .delete();
    firestore
        .collection('users')
        .doc(id)
        .collection('follower')
        .doc(user.uid)
        .delete();

    return true;
  }

  // update profile picture of user
  Future<void> updateProfilePicture(File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;
    log('Extension: $ext');

    //storage file ref with path
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });
    //updating image in firestore database
    userImage = await ref.getDownloadURL();
    me.image = userImage;

    firestore.collection('users').doc(user.uid).update({'image': userImage});
  }

  Future<bool> deleteReel(String id) async {
    firestore.collection('videos').doc(id).delete();
    return true;
  }

  Future<bool> following(String id) async {
    firestore
        .collection('users')
        .doc(user.uid)
        .collection('following')
        .doc(id)
        .set({})
        .then((value) => firestore
            .collection('users')
            .doc(user.uid)
            .update({'following': _ref.read(apisProvider).me.following + 1}))
        .then((value) => _ref.read(apisProvider).getSelfInfo());
    return true;
  }

  Future<bool> follower(String id) async {
    firestore
        .collection('users')
        .doc(id)
        .collection('follower')
        .doc(user.uid)
        .set({});
    await firestore.collection('users').doc(id).get().then((user) async {
      if (user.exists) {
        final data = ChatUser.fromJson(user.data()!);
        firestore
            .collection('users')
            .doc(id)
            .update({'follower': data.follower + 1});
        // log('My Data: ${user.data()}');
      }
    });

    return true;
  }

  Future<bool> addUserToCommunity(String id) async {
    await firestore
        .collection('communities')
        .doc(id)
        .collection('participants')
        .doc(user.uid)
        .set(_ref.read(apisProvider).me.toJson())
        .then((value) => firestore
                .collection('communities')
                .doc(id)
                .collection('participants')
                .doc(user.uid)
                .update({
              'easyQuestions': 0,
              'mediumQuestions': 0,
              'hardQuestions': 0,
              'attemptedEasyQuestion': 0,
              'attemptedMediumQuestion': 0,
              'attemptedHardQuestion': 0,
            }));
    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_communities')
        .doc(id)
        .set({
      'id': id,
    });
    return true;
  }

  Future<bool> adminAddUserToCommunity(String commId, ChatUser user) async {
    await firestore
        .collection('communities')
        .doc(commId) // Use commId as the document ID
        .collection('participants')
        .add({
      'easyQuestions': 0,
      'mediumQuestions': 0,
      'hardQuestions': 0,
      'attemptedEasyQuestion': 0,
      'attemptedMediumQuestion': 0,
      'attemptedHardQuestion': 0,
      ...user.toJson(), // Add user details
    });

    await firestore
        .collection('users')
        .doc(user.id) // Use userId as the document ID
        .collection('my_communities')
        .doc(commId) // Use commId as the document ID
        .set({
      'id': commId,
    });
    // log(commName);
    // addNotification('You were addded to $commName community', user.id);

    return true;
  }

  Future<bool> updateScore(
    String id,
    String scoredLevel,
    int score,
    int usertotalScore,
    String attemptedLevel,
    int attempted,
  ) async {
    firestore
        .collection('communities')
        .doc(id)
        .collection('participants')
        .doc(user.uid)
        .update({
      scoredLevel: score,
      attemptedLevel: attempted,
    });
    firestore.collection('users').doc(_ref.read(apisProvider).me.id).update({
      scoredLevel: usertotalScore,
    });
    return true;
  }

  // for getting current user info

  Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();
        //for setting user status to active
        _ref.read(apisProvider).updateActiveStatus(true);
        log('My Data: ${user.data()}');
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // for creating a new user through new method

  // for creating a new user

  Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
      isContentCreator: false,
      isApproved: false,
      lives: 0,
      easyQuestions: 0,
      hardQuestions: 0,
      mediumQuestions: 0,
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      about: "Hey, I'm using We Chat!",
      image: user.photoURL.toString(),
      createdAt: time,
      isOnline: false,
      lastActive: time,
      pushToken: '',
      dateOfBirth: '',
      gender: '',
      phoneNumber: '',
      place: '',
      designation: 'Member',
      profession: '',
      follower: 0,
      following: 0,
    );

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  // for getting id's of known users from firestore database

  Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .orderBy(
          'timeStamp',
          descending: true,
        )
        .snapshots();
  }

  // for getting id's of known users from firestore database

  Stream<QuerySnapshot<Map<String, dynamic>>> getFriendsUsersId(
      ChatUser users) {
    return firestore
        .collection('users')
        .doc(users.id)
        .collection('following')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getFriendsFollowersUsersId(
      ChatUser users) {
    return firestore
        .collection('users')
        .doc(users.id)
        .collection('follower')
        .snapshots();
  }

  // for getting all users from firestore database

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    // print('\nUserIds: $userIds');

    return firestore
        .collection('users')
        .where('id', whereIn: userIds)
        .snapshots();
  }

  // for getting all users from firestore database

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllCommunities(
      List<String> userIds) {
    log('\nUserIds: $userIds');

    return firestore
        .collection('communities')
        .where('id',
            whereIn: userIds.isEmpty
                ? ['']
                : userIds) //because empty list throws an error
        // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  // for adding an user to my user when first message is send

  Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  // update profile picture of user

  // for getting specific user info

  Stream<ChatUser> getUserInfo(String uid) {
    return firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((event) => ChatUser.fromMap(event.data() as Map<String, dynamic>));
  }

  // update online or last active status of user

  Future<void> updateActiveStatus(bool isOnline) async {
    log("updating status of user");
    log(user.uid);
    await firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  ///************** Chat Screen Related APIs **************

  // chats (collection) --> conversation_id (doc) --> messages (collection) --> message (doc)

  // useful for getting conversation id

  String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // for getting all messages of a specific conversation from firestore database

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // for sending message

  Future<void> sendMessage(ChatUser chatUser, String msg, Type type) async {
    //message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time);

    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : 'image'));
    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .doc(chatUser.id)
        .update({'timeStamp': FieldValue.serverTimestamp()});
    firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .update({'timeStamp': FieldValue.serverTimestamp()});
  }

  //update read status of message

  Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  //get only last message of a specific chat

  Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  //send chat image

  Future<void> sendChatImage(ChatUser chatUser, File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  //delete message

  Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  //update message

  Future<void> updateMessage(Message message, String updatedMsg) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }

  //communities chat messages

  Stream<QuerySnapshot<Map<String, dynamic>>> communityChatMessages(String id) {
    return FirebaseFirestore.instance
        .collection('communities')
        .doc(id)
        .collection('chat')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots();
  }

  //communities add chat messages

  communityAddMessage(String id, String enteredMessage) async {
    final userData = await firestore.collection('users').doc(user.uid).get();
    firestore.collection('communities').doc(id).collection('chat').add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData.data()!['name'],
      'userImage': userData.data()!['image'],
    });
  }

  // for getting id's of joined community from firestore database

  Stream<QuerySnapshot<Map<String, dynamic>>> getCommunityId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_communities')
        .snapshots();
  }

  // get only last message of a specific communtiy

  getLastMessageCommunity(String id) async {
    var data = await FirebaseFirestore.instance
        .collection('communities')
        .doc(id)
        .collection('chat')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .limit(1)
        .get();

    await FirebaseFirestore.instance
        .collection('communities')
        .doc(id)
        .update({'lastMessage': data.docs[0].get('text')});
  }

  //getting information of community

  getCommunityDetail(String id) {
    return FirebaseFirestore.instance.collection('communities').doc(id).get();
  }

  // for getting all user communities from firestore database

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllUserCommunities(
      List<String> communityIds) {
    log('\nCommunityIds: $communityIds');

    return firestore
        .collection('communities')
        .where('id',
            whereIn: communityIds.isEmpty
                ? ['']
                : communityIds) //because empty list throws an error
        // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  //get only last message of a specific community chat

  Stream<QuerySnapshot<Map<String, dynamic>>> getLastCommunityMessage(
      Community user) {
    return firestore
        .collection('communities')
        .doc(user.id)
        .collection('chat')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  // for getting all messages of a specific conversation of community from firestore database

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllCommunityMessages(
      Community user) {
    return firestore
        .collection('communities')
        .doc(user.id)
        .collection('chat')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // for sending message

  Future<void> sendCommunityMessage(String id, String msg, Types type) async {
    //message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final CommunityMessage message = CommunityMessage(
      toId: id,
      msg: msg,
      read: '',
      types: type,
      fromId: user.uid,
      sent: time,
      senderName: me.name,
    );
    log(me.name);

    final ref = firestore.collection('communities').doc(id).collection('chat');
    await ref.doc(time).set(message.toJson()).then((value) {
      try {
        firestore.collection('communities').doc(id).update({'timeStamp': time});
      } catch (error) {
        log(error.toString());
      }
    });
  }

  ///////////////

  Future<void> addCommunities(Community chatUser, File? file) async {
    //getting image file extension
    /*  final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    chatUser.image = imageUrl;*/
    final refe = FirebaseFirestore.instance.collection('communities');
    log('createCommunity function called');

    await refe.doc(chatUser.id).set(chatUser.toJson()).then((value) {
      log('addUserToCommunity function called');
      addUserToCommunity(chatUser.id);
    });
  }

  Future<void> communitySendChatImage(Community chatUser, File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendCommunityMessage(chatUser.id, imageUrl, Types.image);
  }

  // update profile picture of community

  Future<void> updateProfilePictureCommunity(File file, String id) async {
    //getting image file extension
    final ext = file.path.split('.').last;
    log('Extension: $ext');

    //storage file ref with path
    final ref = storage.ref().child('profile_pictures/$id.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    var image = await ref.getDownloadURL();
    await firestore.collection('communities').doc(id).update({'image': image});
  }
  // update profile picture of user

  ///// update community info

  Future<void> updateCommunityInfo(Community community) async {
    log('function called');
    await firestore.collection('communities').doc(community.id).update({
      'name': community.name,
      'about': community.about,
      'email': community.email,
      'domain': community.domain,
    });
  }

  //comunity participants info

  Stream<QuerySnapshot<Map<String, dynamic>>> getCommunityInfo(
      Community community) {
    return firestore
        .collection('communities')
        .where('id', isEqualTo: community.id)
        .snapshots();
  }

  //comunity participants info

  getCommunityInfos(Community community) async {
    firestore
        .collection('communities')
        .doc(community.id)
        .snapshots()
        .map((event) {
      return Community.fromJson(event.data()!);
    });
  }

  //comunity participants info

  Stream<QuerySnapshot<Map<String, dynamic>>> getCommunityParticipantsInfo(
      String id) {
    return firestore
        .collection('communities')
        .doc(id)
        .collection('participants')
        .snapshots();
  }

  //class participants info

  Stream<QuerySnapshot<Map<String, dynamic>>> getClassParticipantsInfo(
      String id) {
    return firestore
        .collection('communities')
        .doc(id)
        .collection('participants')
        .snapshots();
  }

  ///////////dynamic links

  Future<String> shareDynamicLinks(String screen, String url) async {
    log('function called');
    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse("https://while.co.in/app/?screen=/$screen&url=$url"),
      uriPrefix: "https://while.co.in/app",
      androidParameters: const AndroidParameters(
        packageName: "com.example.while_app",
        //minimumVersion: 20,
      ),
      iosParameters: const IOSParameters(
        bundleId: "com.example.app.ios",
        appStoreId: "123456789",
        minimumVersion: "1.0.1",
      ),
      googleAnalyticsParameters: const GoogleAnalyticsParameters(
        source: "While",
        medium: "social",
        campaign: "example-promo",
      ),
      // socialMetaTagParameters: SocialMetaTagParameters(
      //   title: "Example of a Dynamic Link",
      //   imageUrl: Uri.parse("https://example.com/image.png"),
      // ),
    );
    final dynamicLink =
        await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);
    log(dynamicLink.shortUrl.toString());
    return dynamicLink.shortUrl.toString();
  }

  Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log('Push Token: $t');
      }
    });
  }
}
