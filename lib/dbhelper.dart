import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'expenses.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses(
       id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        amount REAL,
        date TEXT
      )
    ''');
  }

  Future<int> insertExpense(Expense expense) async {
    final db = await instance.database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<List<Expense>> getExpensesByDate(String date) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'date = ?',
      whereArgs: [date],
    );
    return List.generate(maps.length, (index) {
      return Expense.fromMap(maps[index]);
    });
  }
  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<double> getTotalMoneySpent(String day) async {

    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) FROM expenses WHERE date = ?',
      [day],
    );

    final total = result != null && result.isNotEmpty ? (result.first.values.first as double?) ?? 0.0 : 0.0;

    return total;
  }

}

class Expense {
  int? id;
  final String title;
  final double amount;
  final String date;

  Expense({this.id,required this.title, required this.amount, required this.date});

  Map<String, dynamic> toMap() {
    return {
      'id' :id,
      'title': title,
      'amount': amount,
      'date': date,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: map['date'],
    );
  }
}
