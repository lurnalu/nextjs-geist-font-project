enum UserRole {
  admin,
  receptionist,
  clinician,
  doctor,
  accountant;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.receptionist:
        return 'Receptionist';
      case UserRole.clinician:
        return 'Clinician';
      case UserRole.doctor:
        return 'Doctor';
      case UserRole.accountant:
        return 'Accountant';
    }
  }

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.toString().split('.').last == value.toLowerCase(),
      orElse: () => throw ArgumentError('Invalid role: $value'),
    );
  }
}
