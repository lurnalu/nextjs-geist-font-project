import 'dart:io' show Platform;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:postgres/postgres.dart';

class DatabaseService {
  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Database? _sqfliteDb;
  PostgreSQLConnection? _pgConnection;

  Future<void> init() async {
    if (Platform.isWindows) {
      // Initialize PostgreSQL connection for Windows
      _pgConnection = PostgreSQLConnection(
        'localhost',
        5432,
        'cherish_ehr',
        username: 'your_username',
        password: 'your_password',
      );
      await _pgConnection!.open();
      print('PostgreSQL connected on Windows');
      await _createTablesPostgres();
    } else if (Platform.isAndroid) {
      // Initialize SQLite connection for Android
      var databasesPath = await getDatabasesPath();
      String path = join(databasesPath, 'cherish_ehr.db');
      _sqfliteDb = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE patients (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              firstName TEXT,
              lastName TEXT,
              phone TEXT,
              email TEXT,
              dateOfBirth TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE appointments (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              patientId INTEGER,
              appointmentDate TEXT,
              doctorName TEXT,
              notes TEXT
            )
          ''');
        },
      );
      print('SQLite database opened on Android');
    } else {
      print('Unsupported platform');
    }
  }

  Future<void> _createTablesPostgres() async {
    await _pgConnection!.query('''
      CREATE TABLE IF NOT EXISTS patients (
        id SERIAL PRIMARY KEY,
        firstName VARCHAR(100),
        lastName VARCHAR(100),
        phone VARCHAR(20),
        email VARCHAR(100),
        dateOfBirth DATE
      );
    ''');
    await _pgConnection!.query('''
      CREATE TABLE IF NOT EXISTS appointments (
        id SERIAL PRIMARY KEY,
        patientId INTEGER REFERENCES patients(id),
        appointmentDate DATE,
        doctorName VARCHAR(100),
        notes TEXT
      );
    ''');

    await _pgConnection!.query('''
      CREATE TABLE IF NOT EXISTS medical_records (
        id SERIAL PRIMARY KEY,
        patientId INTEGER REFERENCES patients(id),
        diagnosis TEXT,
        treatment TEXT,
        prescription TEXT,
        recordDate DATE
      );
    ''');

    await _pgConnection!.query('''
      CREATE TABLE IF NOT EXISTS billing (
        id SERIAL PRIMARY KEY,
        patientId INTEGER REFERENCES patients(id),
        billingDate DATE,
        amount NUMERIC(10, 2),
        description TEXT,
        paid BOOLEAN
      );
    ''');

    await _pgConnection!.query('''
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        username VARCHAR(50) UNIQUE,
        passwordHash TEXT,
        role INTEGER
      );
    ''');

    await _pgConnection!.query('''
      CREATE TABLE IF NOT EXISTS reports (
        id SERIAL PRIMARY KEY,
        title VARCHAR(100),
        description TEXT,
        generatedDate DATE
      );
    ''');
  }

  // Patient CRUD for SQLite and PostgreSQL

  Future<int> insertPatient(Map<String, dynamic> patient) async {
    if (Platform.isWindows) {
      var result = await _pgConnection!.query('''
        INSERT INTO patients (firstName, lastName, phone, email, dateOfBirth)
        VALUES (@firstName, @lastName, @phone, @email, @dateOfBirth)
        RETURNING id;
      ''', substitutionValues: patient);
      return result.first[0] as int;
    } else if (Platform.isAndroid) {
      return await _sqfliteDb!.insert('patients', patient);
    }
    throw UnsupportedError('Unsupported platform');
  }

  Future<int> updatePatient(int id, Map<String, dynamic> patient) async {
    if (Platform.isWindows) {
      await _pgConnection!.query('''
        UPDATE patients SET firstName = @firstName, lastName = @lastName,
        phone = @phone, email = @email, dateOfBirth = @dateOfBirth
        WHERE id = @id;
      ''', substitutionValues: {...patient, 'id': id});
      return id;
    } else if (Platform.isAndroid) {
      return await _sqfliteDb!.update('patients', patient, where: 'id = ?', whereArgs: [id]);
    }
    throw UnsupportedError('Unsupported platform');
  }

  Future<int> deletePatient(int id) async {
    if (Platform.isWindows) {
      await _pgConnection!.query('DELETE FROM patients WHERE id = @id;', substitutionValues: {'id': id});
      return id;
    } else if (Platform.isAndroid) {
      return await _sqfliteDb!.delete('patients', where: 'id = ?', whereArgs: [id]);
    }
    throw UnsupportedError('Unsupported platform');
  }

  Future<List<Map<String, dynamic>>> getPatients() async {
    if (Platform.isWindows) {
      var results = await _pgConnection!.query('SELECT * FROM patients;');
      return results.map((row) {
        return {
          'id': row[0],
          'firstName': row[1],
          'lastName': row[2],
          'phone': row[3],
          'email': row[4],
          'dateOfBirth': row[5].toString(),
        };
      }).toList();
    } else if (Platform.isAndroid) {
      return await _sqfliteDb!.query('patients');
    }
    throw UnsupportedError('Unsupported platform');
  }

  // Appointment CRUD for SQLite and PostgreSQL

  Future<int> insertAppointment(Map<String, dynamic> appointment) async {
    if (Platform.isWindows) {
      var result = await _pgConnection!.query('''
        INSERT INTO appointments (patientId, appointmentDate, doctorName, notes)
        VALUES (@patientId, @appointmentDate, @doctorName, @notes)
        RETURNING id;
      ''', substitutionValues: appointment);
      return result.first[0] as int;
    } else if (Platform.isAndroid) {
      return await _sqfliteDb!.insert('appointments', appointment);
    }
    throw UnsupportedError('Unsupported platform');
  }

  Future<int> updateAppointment(int id, Map<String, dynamic> appointment) async {
    if (Platform.isWindows) {
      await _pgConnection!.query('''
        UPDATE appointments SET patientId = @patientId, appointmentDate = @appointmentDate,
        doctorName = @doctorName, notes = @notes WHERE id = @id;
      ''', substitutionValues: {...appointment, 'id': id});
      return id;
    } else if (Platform.isAndroid) {
      return await _sqfliteDb!.update('appointments', appointment, where: 'id = ?', whereArgs: [id]);
    }
    throw UnsupportedError('Unsupported platform');
  }

  Future<int> deleteAppointment(int id) async {
    if (Platform.isWindows) {
      await _pgConnection!.query('DELETE FROM appointments WHERE id = @id;', substitutionValues: {'id': id});
      return id;
    } else if (Platform.isAndroid) {
      return await _sqfliteDb!.delete('appointments', where: 'id = ?', whereArgs: [id]);
    }
    throw UnsupportedError('Unsupported platform');
  }

  Future<List<Map<String, dynamic>>> getAppointments() async {
    if (Platform.isWindows) {
      var results = await _pgConnection!.query('SELECT * FROM appointments;');
      return results.map((row) {
        return {
          'id': row[0],
          'patientId': row[1],
          'appointmentDate': row[2].toString(),
          'doctorName': row[3],
          'notes': row[4],
        };
      }).toList();
    } else if (Platform.isAndroid) {
      return await _sqfliteDb!.query('appointments');
    }
    throw UnsupportedError('Unsupported platform');
  }
}
