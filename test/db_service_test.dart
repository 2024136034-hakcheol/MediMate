import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:medimate/data/local/db_service.dart';
import 'package:medimate/domain/entities/medicine.dart';
import 'package:medimate/domain/entities/schedule.dart';

String _todayStr() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

void main() {
  late DbService dbService;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    dbService = DbService();
    final db = await dbService.db;
    // 테스트 간 격리를 위해 모든 테이블 초기화
    await db.delete('intake_logs');
    await db.delete('schedules');
    await db.delete('medicines');
  });

  group('DbService — 약 정보 CRUD', () {
    test('insertMedicine 후 getMedicines로 조회된다', () async {
      final id = await dbService.insertMedicine(Medicine(
        name: '타이레놀',
        dosage: '500mg',
        cautions: '공복 주의',
        createdAt: DateTime.now().toIso8601String(),
      ));

      expect(id, greaterThan(0));

      final medicines = await dbService.getMedicines();
      expect(medicines.length, 1);
      expect(medicines.first.name, '타이레놀');
      expect(medicines.first.dosage, '500mg');
    });

    test('deleteMedicine은 약과 연결된 스케줄을 함께 삭제한다', () async {
      final medicineId = await dbService.insertMedicine(Medicine(
        name: '감기약',
        createdAt: DateTime.now().toIso8601String(),
      ));
      await dbService.insertSchedule(Schedule(
        medicineId: medicineId,
        time: '08:00',
        startDate: _todayStr(),
      ));

      await dbService.deleteMedicine(medicineId);

      expect(await dbService.getMedicines(), isEmpty);
      expect(await dbService.getSchedulesByMedicine(medicineId), isEmpty);
    });
  });

  group('DbService — 스케줄 & 복용 기록', () {
    test('오늘 시작하는 스케줄은 getTodaySchedules에 나타나고, 복용 완료 후 log_id가 채워진다', () async {
      final medicineId = await dbService.insertMedicine(Medicine(
        name: '비타민',
        dosage: '1정',
        createdAt: DateTime.now().toIso8601String(),
      ));
      final scheduleId = await dbService.insertSchedule(Schedule(
        medicineId: medicineId,
        time: '08:00',
        startDate: _todayStr(),
      ));

      final before = await dbService.getTodaySchedules();
      expect(before.length, 1);
      expect(before.first['medicine_name'], '비타민');
      expect(before.first['log_id'], isNull);

      await dbService.recordIntake(scheduleId);

      final after = await dbService.getTodaySchedules();
      expect(after.first['log_id'], isNotNull);
    });

    test('종료된 스케줄(end_date가 과거)은 getTodaySchedules에 나타나지 않는다', () async {
      final medicineId = await dbService.insertMedicine(Medicine(
        name: '항생제',
        createdAt: DateTime.now().toIso8601String(),
      ));
      await dbService.insertSchedule(Schedule(
        medicineId: medicineId,
        time: '09:00',
        startDate: '2020-01-01',
        endDate: '2020-01-07',
      ));

      expect(await dbService.getTodaySchedules(), isEmpty);
    });
  });

  group('DbService — 통계 집계', () {
    test('getWeeklyAdherence는 최근 7일을 반환하고 마지막 항목이 오늘이다', () async {
      final medicineId = await dbService.insertMedicine(Medicine(
        name: '약A',
        createdAt: DateTime.now().toIso8601String(),
      ));
      final scheduleId = await dbService.insertSchedule(Schedule(
        medicineId: medicineId,
        time: '08:00',
        startDate: _todayStr(),
      ));
      await dbService.recordIntake(scheduleId);

      final weekly = await dbService.getWeeklyAdherence();

      expect(weekly.length, 7);
      expect(weekly.last['date'], _todayStr());
      expect(weekly.last['scheduled'], 1);
      expect(weekly.last['taken'], 1);
    });

    test('getMedicineIntakeCounts는 복용 횟수가 많은 약을 먼저 반환한다', () async {
      final med1 = await dbService.insertMedicine(Medicine(name: '약A', createdAt: DateTime.now().toIso8601String()));
      final med2 = await dbService.insertMedicine(Medicine(name: '약B', createdAt: DateTime.now().toIso8601String()));

      final schedule1 = await dbService.insertSchedule(Schedule(medicineId: med1, time: '08:00', startDate: _todayStr()));
      final schedule2 = await dbService.insertSchedule(Schedule(medicineId: med2, time: '08:00', startDate: _todayStr()));

      // 약A는 2회, 약B는 0회 복용
      await dbService.recordIntake(schedule1);
      await dbService.recordIntake(schedule1);
      // schedule2는 복용하지 않음 (0회 유지)
      expect(schedule2, greaterThan(0));

      final counts = await dbService.getMedicineIntakeCounts();

      expect(counts.first['medicine_name'], '약A');
      expect(counts.first['taken_count'], 2);
      expect(counts.last['medicine_name'], '약B');
      expect(counts.last['taken_count'], 0);
    });
  });
}
