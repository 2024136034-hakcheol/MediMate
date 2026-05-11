class Schedule {
  final int? id;
  final int medicineId;
  final String time; // "08:00"
  final String startDate;
  final String? endDate;
  final bool isActive;

  Schedule({
    this.id,
    required this.medicineId,
    required this.time,
    required this.startDate,
    this.endDate,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'medicine_id': medicineId,
        'time': time,
        'start_date': startDate,
        'end_date': endDate,
        'is_active': isActive ? 1 : 0,
      };

  factory Schedule.fromMap(Map<String, dynamic> map) => Schedule(
        id: map['id'],
        medicineId: map['medicine_id'],
        time: map['time'],
        startDate: map['start_date'],
        endDate: map['end_date'],
        isActive: map['is_active'] == 1,
      );
}
