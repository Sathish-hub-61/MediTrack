import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  // In-memory store for Web compatibility
  final List<Map<String, dynamic>> _webMedicines = [];
  final List<Map<String, dynamic>> _webHistory = [];

  Future<Database?> get database async {
    if (kIsWeb) return null; // No SQLite on Web
    if (_database != null) {
      debugPrint('DatabaseService: Existing DB instance returned');
      return _database!;
    }
    _database = await _initDatabase();
    debugPrint('DatabaseService: New DB initialized');
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'meditrack_v1.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    debugPrint('DatabaseService: SQLite Database Initialized');
    // Medicines Table
    await db.execute('''
      CREATE TABLE medicines(
        id TEXT PRIMARY KEY,
        userId TEXT,
        medicineName TEXT,
        batchNumber TEXT,
        manufacturedDate TEXT,
        expiryDate TEXT,
        useCase TEXT,
        disposed INTEGER,
        addedAt TEXT
      )
    ''');

    // History Table
    await db.execute('''
      CREATE TABLE history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT,
        medicineId TEXT,
        action TEXT,
        details TEXT,
        timestamp TEXT
      )
    ''');
  }

  // Insert Medicine
  Future<void> insertMedicine(Map<String, dynamic> data) async {
    if (kIsWeb) {
      debugPrint('DatabaseService: Inserting medicine (In-Memory): \$data');
      _webMedicines.removeWhere((m) => m['id'] == data['id']);
      _webMedicines.add(data);
    } else {
      final db = await database;
      await db!.insert(
        'medicines',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // Query Medicines
  Future<List<Map<String, dynamic>>> getMedicines(String userId) async {
    if (kIsWeb) {
      debugPrint(
          'DatabaseService: Fetching medicines (In-Memory) for \$userId');
      return _webMedicines
          .where((m) =>
              m['userId'] == userId &&
              (m['disposed'] == 0 || m['disposed'] == null))
          .toList();
    } else {
      final db = await database;
      return await db!.query(
        'medicines',
        where: 'userId = ? AND disposed = 0',
        whereArgs: [userId],
        orderBy: 'expiryDate ASC',
      );
    }
  }

  // Dispose Medicine (Update + Log History)
  Future<void> disposeMedicine(
      String medicineId, String userId, String details) async {
    if (kIsWeb) {
      debugPrint(
          'DatabaseService: Disposing medicine (In-Memory): \$medicineId');
      final index = _webMedicines.indexWhere((m) => m['id'] == medicineId);
      if (index != -1) {
        _webMedicines[index]['disposed'] = 1;
      }

      _webHistory.add({
        'userId': userId,
        'medicineId': medicineId,
        'action': 'Disposed',
        'details': details,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } else {
      final db = await database;
      await db!.transaction((txn) async {
        // 1. Mark as disposed
        await txn.update(
          'medicines',
          {'disposed': 1},
          where: 'id = ?',
          whereArgs: [medicineId],
        );

        // 2. Add to history
        await txn.insert('history', {
          'userId': userId,
          'medicineId': medicineId,
          'action': 'Disposed',
          'details': details,
          'timestamp': DateTime.now().toIso8601String(),
        });
      });
    }
  }

  // Get History Logs
  Future<List<Map<String, dynamic>>> getHistory(String userId) async {
    if (kIsWeb) {
      return _webHistory.where((h) => h['userId'] == userId).toList();
    } else {
      final db = await database;
      return await db!.query(
        'history',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'timestamp DESC',
      );
    }
  }
}
