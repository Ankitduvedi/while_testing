import 'package:com.while.while_app/data/model/message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../data/model/chat_user.dart';
import 'chat_SqLite_methods.dart';

class ChatDb with ChangeNotifier {
  String UsersTable = 'users';
  String coluid = 'uid';

  List<ChatUser> allMyUsers = [];

  List<ChatUser> get userlist => allMyUsers;

  Future<void> createChatDb(
    Database db,
    int newVersion,
    String Tablename,
  ) async {
    if (Tablename == '') {
      Tablename = 'Default';
    }
    await db.execute(
        'CREATE TABLE $Tablename(sent TEXT PRIMARY KEY, toId TEXT, msg TEXT, read TEXT, fromId TEXT, type TEXT)');
  }

  Future<void> insertUserChat(Message msg, String Tablename) async {
    final database1 = await ChatDatabaseHelper().database;
    print(database1?.path);
    print(msg.toJson());
    int result = await database1!.insert(Tablename, msg.toJson());

    print("inserted $result");

    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getAllUserChatMapList(
      String Tablename) async {
    final database1 = await ChatDatabaseHelper().database;
    var result = await database1!.query(
      Tablename,
    );
    notifyListeners();
    return result;
  }

  Future<void> getAllChatUserList(String Tablename) async {
    print("call");
    var noteMapList = await getAllUserChatMapList(Tablename);
    int count = noteMapList.length;

    List<Message> allMessage = [];
    for (int i = 0; i < count; i++) {
      allMessage.add(Message.fromJson(noteMapList[i]));
    }

    notifyListeners();
  }
}
