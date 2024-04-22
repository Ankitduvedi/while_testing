import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import '../data/model/chat_user.dart';
import 'draft_method.dart';

class DraftDb with ChangeNotifier {
  String UsersTable = 'users';
  String coluid = 'uid';

  List<ChatUser> allMyUsers = [];

  List<ChatUser> get userlist => allMyUsers;

  Future<void> createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE users(id TEXT PRIMARY KEY, image TEXT, about TEXT, name TEXT, created_at TEXT, is_online INTEGER, last_active TEXT, email TEXT, push_token TEXT, phoneNumber TEXT, dateOfBirth TEXT, gender TEXT, profession TEXT, place TEXT, designation TEXT, following INTEGER, follower INTEGER, easyQuestions INTEGER, mediumQuestions INTEGER, hardQuestions INTEGER, lives INTEGER, isContentCreator INTEGER, isCounsellor INTEGER, isCounsellorVerified INTEGER, isApproved INTEGER)');
  }

  Future<void> insertNote(ChatUser user) async {
    final database1 = await DatabaseHelper().database;
    print(database1?.path);
    print(user.toJson());
    int result = await database1!.insert(UsersTable, user.toJson());
    allMyUsers.add(user);
    print("inserted $result");

    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getUserMapList() async {
    final database1 = await DatabaseHelper().database;
    var result = await database1!.query(
      UsersTable,
    );
    notifyListeners();
    return result;
  }

  Future<void> getDraftsList() async {
    print("call");
    var noteMapList = await getUserMapList();
    int count = noteMapList.length;

    List<ChatUser> noteList = [];
    for (int i = 0; i < count; i++) {
      noteList.add(ChatUser.fromJson(noteMapList[i]));
    }
    allMyUsers = noteList;
    notifyListeners();
  }
}
