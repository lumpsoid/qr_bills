import 'dart:async';

import 'package:bill/bill.dart';
import 'package:rxdart/rxdart.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// {@template bill_sqflite_api}
/// A Very Good Project created by Very Good CLI.
/// {@endtemplate}
class BillSqfliteApi {
  /// {@macro bill_sqflite_api}
  BillSqfliteApi();

  Database? _db;

  final _billsController = BehaviorSubject<List<Bill>>.seeded(const []);

  Future<Database> get db async {
    _db ??= await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'bills.db');
      final db = await openDatabase(path, version: 1, onCreate: _onCreate);
      final result = await db.rawQuery(
        'SELECT * FROM bills ORDER BY id',
      );
      final bills = result.map(Bill.fromMap).toList();
      _billsController.add(bills);
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
    await db.execute('''
      CREATE TABLE currencies (
        name TEXT PRIMARY KEY
      )
    ''');
  }

  Future<int> insertBill(Bill bill) async {
    final bills = [..._billsController.value, bill];
    _billsController.add(bills);
    final dbClient = await db;
    final result = await dbClient.insert('bills', await bill.toMap());
    return result;
  }

  Stream<List<Bill>> getBills() => _billsController.asBroadcastStream();

  Future<List<Map<String, dynamic>>> getBill(int id) async {
    final dbClient = await db;
    return dbClient.query('bills', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getIds() async {
    final dbClient = await db;
    return dbClient.query('bills', columns: ['id']);
  }

  Future<int> updateBill(Bill bill) async {
    final bills = [..._billsController.value];
    final billIndex = bills.indexWhere((b) => b.id == bill.id);
    if (billIndex != -1) {
      bills[billIndex] = bill;
    } else {
      bills.add(bill);
    }
    _billsController.add(bills);
    final dbClient = await db;
    return dbClient.update(
      'bills',
      await bill.toMap(),
      where: 'id = ?',
      whereArgs: [bill.id],
    );
  }

  Future<int> deleteBill(int id) async {
    final bills = [..._billsController.value];
    final billIndex = bills.indexWhere((b) => b.id == id);
    if (billIndex == -1) {
      throw Exception('Bill not found');
    } else {
      bills.removeAt(billIndex);
      _billsController.add(bills);
      final dbClient = await db;
      return dbClient.delete('bills', where: 'id = ?', whereArgs: [id]);
    }
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

  Future<List<String>> getCurrences() async {
    final dbClient = await db;
    final result =
        await dbClient.rawQuery('SELECT DISTINCT name FROM currencies');
    return result.map((e) => e['currency']! as String).toList();
  }

  Future<void> setCurrences(List<String> currenciesList) async {
    final dbClient = await db;
    final batch = dbClient.batch();

    for (final currency in currenciesList) {
      batch.insert('currencies', {'name': currency});
    }

    // Committing the batch
    await batch.commit();
  }
}
