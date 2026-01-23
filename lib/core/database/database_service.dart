import 'dart:developer';
import 'package:easy_qr_toolkit/features/history/scan_data_model.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database_service.g.dart';

@Riverpod(keepAlive: true)
DatabaseService databaseService(DatabaseServiceRef ref) {
  return DatabaseService.instance;
}

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();
  final String _scansTableName = 'scans';
  final String _columnId = 'id';
  final String _columnContent = 'content';
  final String _columnDate = 'date';
  final String _columnImage = 'image';

  final String _columnType = 'type';

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
    final database = await openDatabase(
      databasePath,
      version: 2,
      onCreate: (db, version) {
        db.execute(
            'CREATE TABLE $_scansTableName ($_columnId INTEGER PRIMARY KEY, $_columnContent TEXT NOT NULL, $_columnDate INTEGER, $_columnImage BLOB, $_columnType TEXT)');
        log('Table $_scansTableName created');
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          db.execute(
              'ALTER TABLE $_scansTableName ADD COLUMN $_columnType TEXT DEFAULT "text"');
          log('Table $_scansTableName upgraded to version 2 (added type column)');
        }
      },
    );
    log('Database path: $databasePath');
    return database;
  }

  /// Add data
  Future<void> addData(ScanDataModel data) async {
    final db = await database;
    try {
      await db.insert(_scansTableName, {
        _columnId: await _getNextId(),
        _columnContent: data.content,
        _columnDate: data.date,
        _columnImage: data.image,
        _columnType: data.type,
      });
    } catch (e) {
      log('❌ ${e.toString()}');
    }
  }

  /// Delete data
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

  /// Get data (Lightweight, no images)
  Future<List<ScanDataModel>> getData() async {
    final db = await database;
    // Explicitly select columns excluding image to reduce memory usage and jank
    final List<Map<String, dynamic>> maps = await db.query(
      _scansTableName,
      columns: [_columnId, _columnContent, _columnDate, _columnType],
    );
    return List.generate(maps.length, (index) {
      return ScanDataModel(
        id: maps[index][_columnId],
        content: maps[index][_columnContent],
        date: maps[index][_columnDate],
        image: null,
        // Image loaded on demand
        type: maps[index][_columnType] ?? 'text',
      );
    });
  }

  /// Get specific image for a scan ID
  Future<Uint8List?> getScanImage(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _scansTableName,
      columns: [_columnImage],
      where: '$_columnId = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return maps.first[_columnImage] as Uint8List?;
    }
    return null;
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete(_scansTableName);
  }
}
