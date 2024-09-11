class EnrolledStud {
  final int id;
  final int studid;
  final int syid;
  final int levelid;
  final int sectionid;
  final int studstatus;

  EnrolledStud({
    required this.id,
    required this.studid,
    required this.syid,
    required this.levelid,
    required this.sectionid,
    required this.studstatus,
  });

  factory EnrolledStud.fromJson(Map<String, dynamic> json) {
    return EnrolledStud(
      id: json['id'] ?? 0,
      studid: json['studid'] ?? 0,
      syid: json['syid'] ?? 0,
      levelid: json['levelid'] ?? 0,
      sectionid: json['sectionid'] ?? 0,
      studstatus: json['studstatus'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studid': studid,
      'syid': syid,
      'levelid': levelid,
      'sectionid': sectionid,
      'studstatus': studstatus,
    };
  }

  @override
  String toString() {
    return 'EnrolledStud{id: $id, studid: $studid, syid: $syid, levelid: $levelid, sectionid: $sectionid, studstatus: $studstatus}';
  }
}
