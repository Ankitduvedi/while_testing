// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:sqflite/sqflite.dart';
import 'dart:async';
 
class ChatDatabaseHelper {
  Database? _database;

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    } else {
      _database = await initializeDatabase();
    }
    return _database!;
  }

  Future<String> getDatabasePath() async {
    String documentsDirectory = await getDatabasesPath();
    String path = documentsDirectory + 'WhileChat.db';
    return path;
  }

  Future<Database> initializeDatabase() async {
    final path = await getDatabasePath();
    var datatbase1 = await openDatabase(path,
        version: 1, onCreate: create, singleInstance: true);
    return datatbase1;
  }

  Future<void> create(Database database, int version) async =>
      await createChatDb(database, version, '');

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
}
