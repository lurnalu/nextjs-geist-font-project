class MedicalRecord {
  final int? id;
  final int patientId;
  final String diagnosis;
  final String treatment;
  final String prescription;
  final DateTime recordDate;

  MedicalRecord({
    this.id,
    required this.patientId,
    required this.diagnosis,
    required this.treatment,
    required this.prescription,
    required this.recordDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'prescription': prescription,
      'recordDate': recordDate.toIso8601String(),
    };
  }

  factory MedicalRecord.fromMap(Map<String, dynamic> map) {
    return MedicalRecord(
      id: map['id'],
      patientId: map['patientId'],
      diagnosis: map['diagnosis'],
      treatment: map['treatment'],
      prescription: map['prescription'],
      recordDate: DateTime.parse(map['recordDate']),
    );
  }
}
