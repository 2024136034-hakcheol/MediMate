import 'package:flutter_test/flutter_test.dart';
import 'package:medimate/data/api/gemini_service.dart';
import 'package:medimate/domain/entities/medicine.dart';
import 'package:medimate/domain/entities/schedule.dart';
import 'package:medimate/domain/entities/intake_log.dart';

void main() {
  group('MedicineInfo.fromJson — Gemini API 응답 파싱', () {
    test('모든 필드가 채워진 JSON을 정상 파싱한다', () {
      final info = MedicineInfo.fromJson({
        'name': '타이레놀',
        'dosage': '500mg',
        'frequency': 3,
        'duration_days': 5,
        'timing': '식후 30분',
        'cautions': '공복 복용 금지',
      });

      expect(info.name, '타이레놀');
      expect(info.dosage, '500mg');
      expect(info.frequency, 3);
      expect(info.durationDays, 5);
      expect(info.timing, '식후 30분');
      expect(info.cautions, '공복 복용 금지');
    });

    test('frequency/duration_days가 숫자 대신 문자열로 와도 정수로 변환한다', () {
      final info = MedicineInfo.fromJson({
        'name': '감기약',
        'frequency': '2',
        'duration_days': '7',
      });

      expect(info.frequency, 2);
      expect(info.durationDays, 7);
    });

    test('name이 없으면 "알 수 없음"으로 대체한다', () {
      final info = MedicineInfo.fromJson({'dosage': '1정'});

      expect(info.name, '알 수 없음');
      expect(info.dosage, '1정');
    });

    test('null 또는 누락된 필드는 null로 유지한다', () {
      final info = MedicineInfo.fromJson({
        'name': '영양제',
        'dosage': null,
        'duration_days': null,
      });

      expect(info.dosage, isNull);
      expect(info.durationDays, isNull);
      expect(info.frequency, isNull);
      expect(info.cautions, isNull);
    });
  });

  group('도메인 엔티티 — toMap/fromMap 라운드트립', () {
    test('Medicine은 toMap → fromMap 변환 후에도 값이 동일하다', () {
      final medicine = Medicine(
        id: 1,
        name: '타이레놀',
        dosage: '500mg',
        cautions: '공복 주의',
        createdAt: '2026-06-15T00:00:00.000',
      );

      final restored = Medicine.fromMap(medicine.toMap());

      expect(restored.id, medicine.id);
      expect(restored.name, medicine.name);
      expect(restored.dosage, medicine.dosage);
      expect(restored.cautions, medicine.cautions);
      expect(restored.createdAt, medicine.createdAt);
    });

    test('Schedule은 isActive를 0/1 정수로 변환하고 다시 bool로 복원한다', () {
      final schedule = Schedule(
        id: 1,
        medicineId: 10,
        time: '08:00',
        startDate: '2026-06-15',
        isActive: true,
      );

      final map = schedule.toMap();
      expect(map['is_active'], 1);

      final restored = Schedule.fromMap(map);
      expect(restored.isActive, isTrue);
      expect(restored.medicineId, 10);
      expect(restored.time, '08:00');
    });

    test('IntakeLog는 status 값을 그대로 보존한다', () {
      final log = IntakeLog(scheduleId: 5, takenAt: '2026-06-15T08:00:00.000', status: 'taken');

      final restored = IntakeLog.fromMap(log.toMap());

      expect(restored.scheduleId, 5);
      expect(restored.status, 'taken');
    });
  });
}
