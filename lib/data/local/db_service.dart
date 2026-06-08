import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../domain/entities/medicine.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/entities/intake_log.dart';

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
    return openDatabase(path, version: 1, onCreate: _onCreate);
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

  // 오늘의 스케줄 + 복용 여부 조회
  Future<List<Map<String, dynamic>>> getTodaySchedules() async {
    final database = await db;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return database.rawQuery('''
      SELECT
        s.id   AS schedule_id,
        s.time AS schedule_time,
        m.name AS medicine_name,
        m.dosage AS medicine_dosage,
        (SELECT id FROM intake_logs
         WHERE schedule_id = s.id AND taken_at LIKE '$today%'
         LIMIT 1) AS log_id
      FROM schedules s
      JOIN medicines m ON s.medicine_id = m.id
      WHERE s.is_active = 1
        AND s.start_date <= '$today'
        AND (s.end_date IS NULL OR s.end_date >= '$today')
      ORDER BY s.time
    ''');
  }

  // 복용 완료 기록
  Future<void> recordIntake(int scheduleId) async {
    final database = await db;
    await database.insert('intake_logs', {
      'schedule_id': scheduleId,
      'taken_at': DateTime.now().toIso8601String(),
      'status': 'taken',
    });
  }

  // 날짜별 복용률 조회 (달력용)
  Future<Map<String, double>> getMonthlyCompliance(int year, int month) async {
    final database = await db;
    final startDate = '$year-${month.toString().padLeft(2, '0')}-01';
    final endDate = DateTime(year, month + 1, 0);
    final endStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

    final result = await database.rawQuery('''
      SELECT DATE(il.taken_at) as date, COUNT(*) as count
      FROM intake_logs il
      WHERE il.taken_at >= '$startDate' AND il.taken_at <= '$endStr 23:59:59'
        AND il.status = 'taken'
      GROUP BY DATE(il.taken_at)
    ''');

    final Map<String, double> map = {};
    for (final row in result) {
      map[row['date'] as String] = (row['count'] as int).toDouble();
    }
    return map;
  }

  // 최근 7일간 일자별 복용 현황 (예정 횟수 대비 실제 복용 횟수)
  Future<List<Map<String, dynamic>>> getWeeklyAdherence() async {
    final database = await db;
    final now = DateTime.now();
    final List<Map<String, dynamic>> days = [];

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dateStr =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

      final scheduled = Sqflite.firstIntValue(await database.rawQuery('''
        SELECT COUNT(*) FROM schedules
        WHERE is_active = 1 AND start_date <= ? AND (end_date IS NULL OR end_date >= ?)
      ''', [dateStr, dateStr])) ?? 0;

      final taken = Sqflite.firstIntValue(await database.rawQuery('''
        SELECT COUNT(*) FROM intake_logs
        WHERE status = 'taken' AND taken_at LIKE ?
      ''', ['$dateStr%'])) ?? 0;

      days.add({
        'date': dateStr,
        'weekday': day.weekday, // 1=월 ... 7=일
        'scheduled': scheduled,
        'taken': taken > scheduled ? scheduled : taken,
      });
    }
    return days;
  }

  // 약별 누적 복용 횟수 (많이 챙겨 먹은 순)
  Future<List<Map<String, dynamic>>> getMedicineIntakeCounts() async {
    final database = await db;
    return database.rawQuery('''
      SELECT m.id AS medicine_id, m.name AS medicine_name,
        COUNT(il.id) AS taken_count
      FROM medicines m
      JOIN schedules s ON s.medicine_id = m.id
      LEFT JOIN intake_logs il ON il.schedule_id = s.id AND il.status = 'taken'
      GROUP BY m.id
      ORDER BY taken_count DESC
    ''');
  }
}
