class Appointment {
  final int? id;
  final int patientId;
  final DateTime appointmentDate;
  final String doctorName;
  final String notes;

  Appointment({
    this.id,
    required this.patientId,
    required this.appointmentDate,
    required this.doctorName,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'appointmentDate': appointmentDate.toIso8601String(),
      'doctorName': doctorName,
      'notes': notes,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'],
      patientId: map['patientId'],
      appointmentDate: DateTime.parse(map['appointmentDate']),
      doctorName: map['doctorName'],
      notes: map['notes'],
    );
  }
}
