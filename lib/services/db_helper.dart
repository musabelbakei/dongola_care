import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/facility_model.dart';

class DBHelper {
  DBHelper._();
  static final DBHelper instance = DBHelper._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'dongola_health_guide.db');
      final exists = await databaseExists(path);

      if (!exists) {
        await _copyDatabaseFromAssets(path);
      } else {
        // إصلاح لمشكلة "شاشة فارغة على جهاز آخر": إذا كانت النسخة المحلية
        // موجودة لكن فارغة أو تالفة (مثلاً نسخ ناقص سابق)، نعيد نسخها من
        // الـ asset بدل ترك التطبيق يفتح قاعدة بيانات فارغة بصمت.
        final isValid = await _validateExistingDatabase(path);
        if (!isValid) {
          await File(path).delete();
          await _copyDatabaseFromAssets(path);
        }
      }

      return await openDatabase(path, readOnly: false);
    } catch (e) {
      throw DBHelperException('فشل تهيئة قاعدة البيانات المحلية: $e');
    }
  }

  Future<void> _copyDatabaseFromAssets(String path) async {
    await Directory(dirname(path)).create(recursive: true);
    final data = await rootBundle.load('assets/dongola_health_guide.db');
    final bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(path).writeAsBytes(bytes, flush: true);
  }

  Future<bool> _validateExistingDatabase(String path) async {
    try {
      final db = await openDatabase(path, readOnly: true);
      final result = await db.rawQuery('SELECT COUNT(*) AS c FROM Facilities');
      await db.close();
      final count = Sqflite.firstIntValue(result) ?? 0;
      return count > 0;
    } catch (_) {
      return false;
    }
  }

  Future<List<FacilityModel>> getAllFacilities() async {
    final db = await database;
    return _loadFacilitiesWhere(db);
  }

  Future<List<FacilityModel>> getFacilitiesByType(String type) async {
    final db = await database;
    return _loadFacilitiesWhere(db,
        where: 'facility_type = ?', whereArgs: [type]);
  }

  Future<FacilityModel> getFacilityFullById(int id) async {
    final db = await database;
    final rows = await _loadFacilitiesWhere(db,
        where: 'facility_id = ?', whereArgs: [id]);
    if (rows.isEmpty) throw Exception('Facility not found: $id');
    return rows.first;
  }

  Future<List<FacilityModel>> _loadFacilitiesWhere(
    Database db, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final facilityRows = await db.query(
      'Facilities',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'facility_id ASC',
    );
    if (facilityRows.isEmpty) return [];

    final ids = facilityRows.map((r) => r['facility_id'] as int).toList();
    final placeholders = List.filled(ids.length, '?').join(',');

    final serviceRows = await db.rawQuery('''
      SELECT j.facility_id AS facility_id, s.service_name AS name
      FROM Facility_Service j
      INNER JOIN Services s ON s.service_id = j.service_id
      WHERE j.facility_id IN ($placeholders)
    ''', ids);

    final specialtyRows = await db.rawQuery('''
      SELECT j.facility_id AS facility_id, sp.specialty_name AS name
      FROM Facility_Specialty j
      INNER JOIN Specialties sp ON sp.specialty_id = j.specialty_id
      WHERE j.facility_id IN ($placeholders)
    ''', ids);

    final servicesByFacility = <int, List<String>>{};
    for (final row in serviceRows) {
      final fid = row['facility_id'] as int;
      final name = row['name']?.toString() ?? '';
      if (name.isEmpty) continue;
      servicesByFacility.putIfAbsent(fid, () => []).add(name);
    }

    final specialtiesByFacility = <int, List<String>>{};
    for (final row in specialtyRows) {
      final fid = row['facility_id'] as int;
      final name = row['name']?.toString() ?? '';
      if (name.isEmpty) continue;
      specialtiesByFacility.putIfAbsent(fid, () => []).add(name);
    }

    return facilityRows.map((row) {
      final base = FacilityModel.fromMap(row);
      return base.copyWith(
        services: servicesByFacility[base.facilityId] ?? const [],
        specialties: specialtiesByFacility[base.facilityId] ?? const [],
      );
    }).toList();
  }
}

class DBHelperException implements Exception {
  final String message;
  DBHelperException(this.message);
  @override
  String toString() => message;
}
