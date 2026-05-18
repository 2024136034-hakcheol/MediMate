class IntakeLog {
  final int? id;
  final int scheduleId;
  final String takenAt;
  final String status; // 'taken' | 'skipped'

  IntakeLog({
    this.id,
    required this.scheduleId,
    required this.takenAt,
    required this.status,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'schedule_id': scheduleId,
        'taken_at': takenAt,
        'status': status,
      };

  factory IntakeLog.fromMap(Map<String, dynamic> map) => IntakeLog(
        id: map['id'],
        scheduleId: map['schedule_id'],
        takenAt: map['taken_at'],
        status: map['status'],
      );
}
