import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/persona.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('people.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
  CREATE TABLE people (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    age INTEGER NOT NULL,
    nationality TEXT,
    datetime TEXT NOT NULL,
    description TEXT NOT NULL,
    photoPath TEXT,
    audioPath TEXT,
    gps TEXT
  )
''');
  }

  Future<int> insert(Person person) async {
    final db = await instance.database;
    return await db.insert('people', person.toMap());
  }

  Future<List<Person>> getAllPeople() async {
    final db = await instance.database;
    final result = await db.query('people');
    return result.map((map) => Person.fromMap(map)).toList();
  }

  Future<void> deleteAll() async {
    final db = await instance.database;
    await db.delete('people');
  }
}
