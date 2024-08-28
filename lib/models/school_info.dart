class SchoolInfo {
  final int id;
  final String schoolcolor;

  SchoolInfo({
    required this.id,
    required this.schoolcolor,
  });

  factory SchoolInfo.fromJson(Map<String, dynamic> json) {
    return SchoolInfo(
      id: json['id'],
      schoolcolor: json['schoolcolor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'semester': schoolcolor,
    };
  }

  @override
  String toString() {
    return 'SchoolInfo(id: $id,schoolcolor: $schoolcolor)';
  }
}
