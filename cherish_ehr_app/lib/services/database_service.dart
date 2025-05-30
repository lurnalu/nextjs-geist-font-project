import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> init() async {
    await database;
  }

  Future<Database> _initDatabase() async {
    if (Platform.isWindows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, 'cherish_ehr.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        phoneNumber TEXT NOT NULL,
        role TEXT NOT NULL,
        passwordHash TEXT NOT NULL,
        resetToken TEXT,
        resetTokenExpiry TEXT,
        createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        lastLogin TEXT,
        isActive INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS patients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        dateOfBirth TEXT NOT NULL,
        gender TEXT NOT NULL,
        phoneNumber TEXT NOT NULL,
        email TEXT,
        address TEXT,
        emergencyContact TEXT,
        emergencyPhone TEXT,
        createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS appointments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patientId INTEGER NOT NULL,
        doctorId INTEGER NOT NULL,
        dateTime TEXT NOT NULL,
        status TEXT NOT NULL,
        notes TEXT,
        createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (patientId) REFERENCES patients (id),
        FOREIGN KEY (doctorId) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS medical_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patientId INTEGER NOT NULL,
        doctorId INTEGER NOT NULL,
        diagnosis TEXT NOT NULL,
        treatment TEXT NOT NULL,
        prescription TEXT,
        notes TEXT,
        createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (patientId) REFERENCES patients (id),
        FOREIGN KEY (doctorId) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS billing (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patientId INTEGER NOT NULL,
        appointmentId INTEGER,
        amount REAL NOT NULL,
        status TEXT NOT NULL,
        paymentMethod TEXT,
        paymentDate TEXT,
        notes TEXT,
        createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (patientId) REFERENCES patients (id),
        FOREIGN KEY (appointmentId) REFERENCES appointments (id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  // Patient Methods
  Future<List<Map<String, dynamic>>> getPatients() async {
    final db = await database;
    return await db.query('patients', orderBy: 'lastName, firstName');
  }

  Future<int> insertPatient(Map<String, dynamic> patient) async {
    final db = await database;
    return await db.insert(
      'patients',
      {
        ...patient,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<int> updatePatient(int id, Map<String, dynamic> patient) async {
    final db = await database;
    return await db.update(
      'patients',
      {
        ...patient,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletePatient(int id) async {
    final db = await database;
    return await db.delete(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Appointment Methods
  Future<List<Map<String, dynamic>>> getAppointments() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        a.*,
        p.firstName as patientFirstName,
        p.lastName as patientLastName,
        u.firstName as doctorFirstName,
        u.lastName as doctorLastName
      FROM appointments a
      JOIN patients p ON a.patientId = p.id
      JOIN users u ON a.doctorId = u.id
      ORDER BY a.dateTime DESC
    ''');
  }

  Future<int> insertAppointment(Map<String, dynamic> appointment) async {
    final db = await database;
    return await db.insert(
      'appointments',
      {
        ...appointment,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<int> updateAppointment(int id, Map<String, dynamic> appointment) async {
    final db = await database;
    return await db.update(
      'appointments',
      {
        ...appointment,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAppointment(int id) async {
    final db = await database;
    return await db.delete(
      'appointments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Medical Records Methods
  Future<List<Map<String, dynamic>>> getMedicalRecords(int patientId) async {
    final db = await database;
    return await db.query(
      'medical_records',
      where: 'patientId = ?',
      whereArgs: [patientId],
      orderBy: 'createdAt DESC',
    );
  }

  Future<int> insertMedicalRecord(Map<String, dynamic> record) async {
    final db = await database;
    return await db.insert(
      'medical_records',
      {
        ...record,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<int> updateMedicalRecord(int id, Map<String, dynamic> record) async {
    final db = await database;
    return await db.update(
      'medical_records',
      {
        ...record,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteMedicalRecord(int id) async {
    final db = await database;
    return await db.delete(
      'medical_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Billing Methods
  Future<List<Map<String, dynamic>>> getBillingRecords(int patientId) async {
    final db = await database;
    return await db.query(
      'billing',
      where: 'patientId = ?',
      whereArgs: [patientId],
      orderBy: 'createdAt DESC',
    );
  }

  Future<int> insertBillingRecord(Map<String, dynamic> bill) async {
    final db = await database;
    return await db.insert(
      'billing',
      {
        ...bill,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<int> updateBillingRecord(int id, Map<String, dynamic> bill) async {
    final db = await database;
    return await db.update(
      'billing',
      {
        ...bill,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteBillingRecord(int id) async {
    final db = await database;
    return await db.delete(
      'billing',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Reporting Methods
  Future<Map<String, dynamic>> getClinicStats(DateTime start, DateTime end) async {
    final db = await database;
    final stats = <String, dynamic>{};

    // Get total patients
    final patientsResult = await db.rawQuery('''
      SELECT 
        COUNT(*) as total,
        COUNT(CASE WHEN createdAt >= ? THEN 1 END) as new
      FROM patients
      WHERE createdAt <= ?
    ''', [start.toIso8601String(), end.toIso8601String()]);

    stats['totalPatients'] = patientsResult.first['total'];
    stats['newPatients'] = patientsResult.first['new'];

    // Get appointment stats
    final appointmentsResult = await db.rawQuery('''
      SELECT 
        COUNT(*) as total,
        COUNT(CASE WHEN status = 'COMPLETED' THEN 1 END) as completed,
        COUNT(CASE WHEN status = 'PENDING' THEN 1 END) as pending,
        COUNT(CASE WHEN status = 'CANCELLED' THEN 1 END) as cancelled
      FROM appointments
      WHERE dateTime BETWEEN ? AND ?
    ''', [start.toIso8601String(), end.toIso8601String()]);

    stats['totalAppointments'] = appointmentsResult.first['total'];
    stats['completedAppointments'] = appointmentsResult.first['completed'];
    stats['pendingAppointments'] = appointmentsResult.first['pending'];
    stats['cancelledAppointments'] = appointmentsResult.first['cancelled'];

    // Get financial stats
    final financialResult = await db.rawQuery('''
      SELECT 
        SUM(amount) as totalRevenue,
        SUM(CASE WHEN status = 'PENDING' THEN amount ELSE 0 END) as pendingPayments,
        AVG(amount) as averageBillAmount
      FROM billing
      WHERE createdAt BETWEEN ? AND ?
    ''', [start.toIso8601String(), end.toIso8601String()]);

    stats['totalRevenue'] = financialResult.first['totalRevenue'] ?? 0;
    stats['pendingPayments'] = financialResult.first['pendingPayments'] ?? 0;
    stats['averageBillAmount'] = financialResult.first['averageBillAmount'] ?? 0;

    // Get return visits
    final returnVisitsResult = await db.rawQuery('''
      SELECT COUNT(*) as returnVisits
      FROM appointments a
      WHERE EXISTS (
        SELECT 1 FROM appointments b
        WHERE b.patientId = a.patientId
        AND b.dateTime < a.dateTime
      )
      AND dateTime BETWEEN ? AND ?
    ''', [start.toIso8601String(), end.toIso8601String()]);

    stats['returnVisits'] = returnVisitsResult.first['returnVisits'];

    // Calculate average visit duration (assuming 30 minutes per visit)
    stats['averageVisitDuration'] = 30;

    return stats;
  }
}
