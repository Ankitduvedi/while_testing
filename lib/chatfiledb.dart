import 'dart:developer';
import 'dart:io';

import 'package:com.while.while_app/data/model/message.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'data/model/SQlite_message_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<bool> requestPermissions() async {
    var status = await Permission.storage.status;
    if (status.isDenied) {
      if (await Permission.storage.request().isGranted) {
        // log('Permission granted');
      } else {
        await Permission.storage.request();
        // log('Permission denied');
      }
    } else if (status.isPermanentlyDenied) {
      // log('Permission permanently denied');
      openAppSettings();
    } else {
      // Permission already granted
    }
    return true;
  }

  void createDirectoryIfNotExists(String path) async {
    final directory = Directory(path);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  Future<Database> _initDatabase() async {
    await requestPermissions;
    createDirectoryIfNotExists('/storage/emulated/0/Download/');
    String path = join('/storage/emulated/0/Download/', 'messages.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // No need to create tables here, as they will be created dynamically
      },
    );
  }

  Future<void> _createTableIfNotExists(Database db, String tableName) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName(
        toId TEXT,
        fromId TEXT,
        msg TEXT,
        read INTEGER,
        type TEXT,
        image BLOB,
        sent TEXT PRIMARY KEY
      )
    ''');
  }

  String _sanitizeTableName(String tableName) {
    // Replace any non-alphanumeric character with an underscore
    tableName = tableName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    return tableName;
  }

  Future<void> insertMessage(
      String conversationId, MessageWithImage message) async {
    print('inserting message');
    try {
      final db = await database;
      conversationId = '_' + conversationId;
      conversationId = _sanitizeTableName(conversationId);

      await _createTableIfNotExists(db, conversationId);
      // log('${message.toJson()}');

      int res = await db.insert(
        conversationId,
        message.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('inserted $res');
    } catch (e) {
      print(e);
    }
  }

  Future<List<MessageWithImage>> getMessages(String conversationId) async {
    final db = await database;
    conversationId = '_' + conversationId;
    conversationId = _sanitizeTableName(conversationId);
    await _createTableIfNotExists(db, conversationId);
    List<Map<String, dynamic>> messages = await db.query(conversationId);
    // log("length: ${messages.length}");
    List<MessageWithImage> messageList = [];
    for (var message in messages) {
      messageList.add(await convert(MessageWithImage.fromJson2(message)));
    }
    messages.map((e) => MessageWithImage.fromJson(e)).toList();
    messageList.sort((a, b) => b.sent.compareTo(a.sent));
    return messageList;
  }

  Future<MessageWithImage> convert(Future<MessageWithImage> message) async {
    return await message;
  }

  Future<void> deleteMessages(String tableId) async {
    final db = await database;
    tableId = '_' + tableId;
    String tableName = _sanitizeTableName(tableId);

    await _createTableIfNotExists(db, tableName);

    await db.delete(tableName);
  }

  // New function to get the timestamp of the last message
  Future<String?> getLastMessageTimestamp(String conversationId) async {
    final db = await database;
    conversationId = '_' + conversationId;
    conversationId = _sanitizeTableName(conversationId);
    await _createTableIfNotExists(db, conversationId);

    // Query to get the latest message by sent timestamp
    List<Map<String, dynamic>> result = await db.query(
      conversationId,
      orderBy: 'sent DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['sent'] as String?;
    }
    print("list is $result");

    return null;
  }
}
