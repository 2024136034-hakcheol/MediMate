class Medicine {
  final int? id;
  final String name;
  final String? dosage;
  final String? cautions;
  final String createdAt;

  Medicine({
    this.id,
    required this.name,
    this.dosage,
    this.cautions,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'dosage': dosage,
        'cautions': cautions,
        'created_at': createdAt,
      };

  factory Medicine.fromMap(Map<String, dynamic> map) => Medicine(
        id: map['id'],
        name: map['name'],
        dosage: map['dosage'],
        cautions: map['cautions'],
        createdAt: map['created_at'],
      );
}
