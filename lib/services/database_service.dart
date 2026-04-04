import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gyanyatra.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        uid TEXT PRIMARY KEY,
        name TEXT,
        email TEXT,
        photoUrl TEXT,
        xp INTEGER,
        level INTEGER,
        classLevel INTEGER,
        streak INTEGER,
        isPremium INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE completed_lessons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid TEXT,
        lesson_id TEXT,
        UNIQUE(uid, lesson_id)
      )
    ''');
  }

  // User methods
  Future<void> saveUser(User user) async {
    final db = await instance.database;
    await db.insert(
      'users',
      {
        'uid': user.uid,
        'name': user.name,
        'email': user.email,
        'photoUrl': user.photoUrl,
        'xp': user.xp,
        'level': user.level,
        'classLevel': user.classLevel,
        'streak': user.streak,
        'isPremium': user.isPremium ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> getUser(String uid) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'uid = ?',
      whereArgs: [uid],
    );

    if (maps.isNotEmpty) {
      final lessons = await getCompletedLessons(uid);
      final data = maps.first;
      return User(
        uid: data['uid'] as String,
        name: data['name'] as String,
        email: data['email'] as String,
        photoUrl: data['photoUrl'] as String?,
        xp: data['xp'] as int,
        level: data['level'] as int,
        classLevel: data['classLevel'] as int,
        streak: data['streak'] as int,
        isPremium: (data['isPremium'] as int) == 1,
        completedLessons: lessons,
        badges: [], // Optional for now
      );
    }
    return null;
  }

  // Lesson methods
  Future<void> addCompletedLesson(String uid, String lessonId) async {
    final db = await instance.database;
    await db.insert(
      'completed_lessons',
      {'uid': uid, 'lesson_id': lessonId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<String>> getCompletedLessons(String uid) async {
    final db = await instance.database;
    final maps = await db.query(
      'completed_lessons',
      where: 'uid = ?',
      whereArgs: [uid],
    );

    return List.generate(maps.length, (i) => maps[i]['lesson_id'] as String);
  }

  Future<void> clearAll() async {
    final db = await instance.database;
    await db.delete('users');
    await db.delete('completed_lessons');
  }
}
