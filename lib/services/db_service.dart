import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/medicine.dart';
import '../models/schedule.dart';
import '../models/intake_log.dart';

class DbService {
  static final DbService _instance = DbService._internal();
  factory DbService() => _instance;
  DbService._internal();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'medimate.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE medicines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        dosage TEXT,
        cautions TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medicine_id INTEGER NOT NULL,
        time TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT,
        is_active INTEGER DEFAULT 1,
        FOREIGN KEY (medicine_id) REFERENCES medicines(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE intake_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        schedule_id INTEGER NOT NULL,
        taken_at TEXT NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (schedule_id) REFERENCES schedules(id)
      )
    ''');
  }

  // Medicine CRUD
  Future<int> insertMedicine(Medicine medicine) async {
    final database = await db;
    return database.insert('medicines', medicine.toMap());
  }

  Future<List<Medicine>> getMedicines() async {
    final database = await db;
    final maps = await database.query('medicines', orderBy: 'created_at DESC');
    return maps.map((m) => Medicine.fromMap(m)).toList();
  }

  Future<void> deleteMedicine(int id) async {
    final database = await db;
    await database.delete('medicines', where: 'id = ?', whereArgs: [id]);
    await database.delete('schedules', where: 'medicine_id = ?', whereArgs: [id]);
  }

  // Schedule CRUD
  Future<int> insertSchedule(Schedule schedule) async {
    final database = await db;
    return database.insert('schedules', schedule.toMap());
  }

  Future<List<Schedule>> getSchedulesByMedicine(int medicineId) async {
    final database = await db;
    final maps = await database.query(
      'schedules',
      where: 'medicine_id = ? AND is_active = 1',
      whereArgs: [medicineId],
    );
    return maps.map((m) => Schedule.fromMap(m)).toList();
  }

  // IntakeLog CRUD
  Future<int> insertIntakeLog(IntakeLog log) async {
    final database = await db;
    return database.insert('intake_logs', log.toMap());
  }

  Future<List<IntakeLog>> getIntakeLogsByDate(String date) async {
    final database = await db;
    final maps = await database.query(
      'intake_logs',
      where: 'taken_at LIKE ?',
      whereArgs: ['$date%'],
    );
    return maps.map((m) => IntakeLog.fromMap(m)).toList();
  }
}
