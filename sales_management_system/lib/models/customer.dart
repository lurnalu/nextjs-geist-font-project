class Customer {
  final int? id;
  final String name;
  final String? phoneNumber;
  final String? email;
  final String? address;
  final DateTime createdAt;
  final DateTime? lastVisit;
  final List<DateTime> visitHistory;
  final String? notes;

  Customer({
    this.id,
    required this.name,
    this.phoneNumber,
    this.email,
    this.address,
    required this.createdAt,
    this.lastVisit,
    List<DateTime>? visitHistory,
    this.notes,
  }) : visitHistory = visitHistory ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'lastVisit': lastVisit?.toIso8601String(),
      'visitHistory': visitHistory.map((date) => date.toIso8601String()).join(','),
      'notes': notes,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      email: map['email'],
      address: map['address'],
      createdAt: DateTime.parse(map['createdAt']),
      lastVisit: map['lastVisit'] != null ? DateTime.parse(map['lastVisit']) : null,
      visitHistory: map['visitHistory'] != null && map['visitHistory'].isNotEmpty
          ? map['visitHistory']
              .split(',')
              .map<DateTime>((date) => DateTime.parse(date))
              .toList()
          : [],
      notes: map['notes'],
    );
  }

  Customer copyWith({
    int? id,
    String? name,
    String? phoneNumber,
    String? email,
    String? address,
    DateTime? createdAt,
    DateTime? lastVisit,
    List<DateTime>? visitHistory,
    String? notes,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      lastVisit: lastVisit ?? this.lastVisit,
      visitHistory: visitHistory ?? List.from(this.visitHistory),
      notes: notes ?? this.notes,
    );
  }

  void addVisit(DateTime visitDate) {
    visitHistory.add(visitDate);
    visitHistory.sort((a, b) => b.compareTo(a)); // Keep most recent first
  }

  int get totalVisits => visitHistory.length;

  DateTime? get firstVisit => 
      visitHistory.isNotEmpty ? visitHistory.reduce((a, b) => a.isBefore(b) ? a : b) : null;

  bool hasVisitedInLastDays(int days) {
    if (lastVisit == null) return false;
    final difference = DateTime.now().difference(lastVisit!);
    return difference.inDays <= days;
  }
}
