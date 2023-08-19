// ignore_for_file: prefer_const_declarations

import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:strophe/model/poem.dart';

class PoemsDatabase {
  static final PoemsDatabase instance = PoemsDatabase._init();

  static Database? _database;

  PoemsDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('poems.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE $tablePoems (
  ${PoemFields.id} $idType,
  ${PoemFields.title} $textType,
  ${PoemFields.author} $textType,
  ${PoemFields.content} $textType
)
''');
  }

  Future<Poem> create(Poem poem) async {
    final db = await instance.database;

    final id = await db.insert(tablePoems, poem.toJson());
    return poem.copy(id: id);
  }

  Future<Poem> readPoem(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      tablePoems,
      columns: PoemFields.values,
      where: '${PoemFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Poem.fromJson(maps.first);
    } else {
      throw Exception("ID $id not found");
    }
  }

  Future<List<Poem>> readAllPoems() async {
    final db = await instance.database;

    final result = await db.query(tablePoems);

    return result.map((json) => Poem.fromJson(json)).toList();
  }

  Future<int> update(Poem poem) async {
    final db = await instance.database;

    return db.update(
      tablePoems,
      poem.toJson(),
      where: '${PoemFields.id} = ?',
      whereArgs: [poem.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      tablePoems,
      where: '${PoemFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
