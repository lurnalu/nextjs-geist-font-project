import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'sales_management.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        fullName TEXT,
        email TEXT,
        createdAt TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Products table
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        category TEXT NOT NULL,
        barcode TEXT UNIQUE,
        stockLevel INTEGER NOT NULL DEFAULT 0,
        isService INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT
      )
    ''');

    // Customers table
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phoneNumber TEXT,
        email TEXT,
        address TEXT,
        createdAt TEXT NOT NULL,
        lastVisit TEXT,
        visitHistory TEXT,
        notes TEXT
      )
    ''');

    // Sales table
    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerId INTEGER,
        customerName TEXT,
        items TEXT NOT NULL,
        saleDate TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        paidAmount REAL NOT NULL DEFAULT 0,
        paymentMethod TEXT NOT NULL,
        paymentStatus TEXT NOT NULL,
        transactionId TEXT,
        notes TEXT,
        userId INTEGER NOT NULL,
        userFullName TEXT NOT NULL,
        FOREIGN KEY (customerId) REFERENCES customers (id),
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    // Create default admin user
    await db.insert('users', {
      'username': 'admin',
      'password': 'admin123', // In production, this should be hashed
      'role': 'admin',
      'fullName': 'System Admin',
      'createdAt': DateTime.now().toIso8601String(),
      'isActive': 1
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
  }

  // Backup database
  Future<String> backupDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String backupPath = join(documentsDirectory.path, 
        'sales_management_backup_${DateTime.now().millisecondsSinceEpoch}.db');
    
    File dbFile = File(join(documentsDirectory.path, 'sales_management.db'));
    await dbFile.copy(backupPath);
    
    return backupPath;
  }

  // Restore database
  Future<void> restoreDatabase(String backupPath) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String dbPath = join(documentsDirectory.path, 'sales_management.db');
    
    File backupFile = File(backupPath);
    await backupFile.copy(dbPath);
    
    // Close and reset the database connection
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
