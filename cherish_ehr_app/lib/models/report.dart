class Report {
  final int? id;
  final String title;
  final String description;
  final DateTime generatedDate;

  Report({
    this.id,
    required this.title,
    required this.description,
    required this.generatedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'generatedDate': generatedDate.toIso8601String(),
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      generatedDate: DateTime.parse(map['generatedDate']),
    );
  }
}
