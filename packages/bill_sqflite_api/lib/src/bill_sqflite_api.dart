import 'dart:async';

import 'package:bill/bill.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// {@template bill_sqflite_api}
/// A Very Good Project created by Very Good CLI.
/// {@endtemplate}
class BillSqfliteApi {
  /// {@macro bill_sqflite_api}
  BillSqfliteApi();

  Database? _db;

  Future<Database> get db async {
    _db ??= await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'bills.db');
      final db = await openDatabase(path, version: 1, onCreate: _onCreate);
      return db;
    } catch (e) {
      print('Error initializing database: $e');
      rethrow; // Rethrow the error to see the stack trace
    }
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bills (
        id INTEGER PRIMARY KEY,
        type TEXT,
        qr TEXT,
        name TEXT,
        tags TEXT,
        date TEXT,
        currency TEXT,
        country TEXT,
        price REAL,
        exchange_rate REAL,
        date_created TEXT
      )
    ''');
  }

  Future<int> insertBill(Bill bill) async {
    final dbClient = await db;
    return dbClient.insert('bills', await bill.toMap());
  }

  Future<List<Bill>> fetchAllBills() async {
    final dbClient = await db;
    final result = await dbClient.rawQuery(
      'SELECT * FROM bills ORDER BY id',
    );
    final bills = result.map(Bill.fromMap).toList();
    return bills;
  }

  Future<List<Map<String, dynamic>>> getBill(int id) async {
    final dbClient = await db;
    return dbClient.query('bills', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getIds() async {
    final dbClient = await db;
    return dbClient.query('bills', columns: ['id']);
  }

  Future<int> updateBill(Bill bill) async {
    final dbClient = await db;
    return dbClient.update(
      'bills',
      await bill.toMap(),
      where: 'id = ?',
      whereArgs: [bill.id],
    );
  }

  Future<int> deleteBill(int id) async {
    final dbClient = await db;
    return dbClient.delete('bills', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final dbClient = await db;
    try {
      await dbClient.close();
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
