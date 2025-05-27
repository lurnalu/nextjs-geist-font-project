class Patient {
  final int? id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final DateTime dateOfBirth;

  Patient({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.dateOfBirth,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'dateOfBirth': dateOfBirth.toIso8601String(),
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      phone: map['phone'],
      email: map['email'],
      dateOfBirth: DateTime.parse(map['dateOfBirth']),
    );
  }
}
