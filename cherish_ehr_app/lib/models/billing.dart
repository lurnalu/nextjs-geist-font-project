class Billing {
  final int? id;
  final int patientId;
  final DateTime billingDate;
  final double amount;
  final String description;
  final bool paid;

  Billing({
    this.id,
    required this.patientId,
    required this.billingDate,
    required this.amount,
    required this.description,
    required this.paid,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'billingDate': billingDate.toIso8601String(),
      'amount': amount,
      'description': description,
      'paid': paid ? 1 : 0,
    };
  }

  factory Billing.fromMap(Map<String, dynamic> map) {
    return Billing(
      id: map['id'],
      patientId: map['patientId'],
      billingDate: DateTime.parse(map['billingDate']),
      amount: map['amount'],
      description: map['description'],
      paid: map['paid'] == 1,
    );
  }
}
