import 'dart:developer';

import 'package:easy_qr_toolkit/models/scan_data_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();
  final String _scansTableName = 'scans';
  final String _columnId = 'id';
  final String _columnContent = 'content';
  final String _columnDate = 'date';
  final String _columnImage = 'image';

  // Private constructor
  DatabaseService._constructor();
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, 'qr_scans.db');
    final database =
        await openDatabase(databasePath, version: 1, onCreate: (db, version) {
      db.execute(
          'CREATE TABLE $_scansTableName ($_columnId INTEGER PRIMARY KEY, $_columnContent TEXT NOT NULL, $_columnDate INTEGER, $_columnImage BLOB)');
      log('Table $_scansTableName created');
    });
    log('Database path: $databasePath');
    return database;
  }

  /// Add data
  ///
  /// This method adds the scanned qr data into the database
  Future<void> addData(ScanDataModel data) async {
    final db = await database;
    try {
      await db.insert(_scansTableName, {
        _columnId: await _getNextId(),
        _columnContent: data.content,
        _columnDate: data.date,
        _columnImage: data.image,
      });
    } catch (e) {
      log('❌' + e.toString());
    }
  }

  /// Delete data
  ///
  /// This method deletes the scanned qr data from the database
  Future<void> deleteData(int id) async {
    final db = await database;
    await db.delete(_scansTableName, where: '$_columnId = ?', whereArgs: [id]);
  }

  Future<int> _getNextId() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_scansTableName);
    if (maps.isEmpty) {
      return 1;
    } else {
      final List<int> ids = maps.map((map) => map[_columnId] as int).toList();
      final int maxId =
          ids.reduce((value, element) => value > element ? value : element);
      return maxId + 1;
    }
  }

  /// Get data
  ///
  /// This method returns the list of scanned qr data from the database
  Future<List<ScanDataModel>> getData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_scansTableName);
    return List.generate(maps.length, (index) {
      return ScanDataModel(
        id: maps[index][_columnId],
        content: maps[index][_columnContent],
        date: maps[index][_columnDate],
        image: maps[index][_columnImage],
      );
    });
  }
}
