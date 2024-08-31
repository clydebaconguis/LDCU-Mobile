class Attendance {
  final int id;
  final int syid;
  final int month;
  final int days;
  final String year;
  final int levelid;
  final String sydesc;
  final String sort;
  final String monthdesc;
  final String dates;
  final int present;
  final int absent;

  Attendance({
    required this.id,
    required this.syid,
    required this.month,
    required this.days,
    required this.year,
    required this.levelid,
    required this.sydesc,
    required this.sort,
    required this.monthdesc,
    required this.dates,
    required this.present,
    required this.absent,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      syid: json['syid'],
      month: json['month'],
      days: json['days'],
      year: json['year'],
      levelid: json['levelid'],
      sydesc: json['sydesc'],
      sort: json['sort'],
      monthdesc: json['monthdesc'],
      dates: json['dates'],
      present: json['present'],
      absent: json['absent'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'syid': syid,
      'month': month,
      'days': days,
      'year': year,
      'levelid': levelid,
      'sydesc': sydesc,
      'sort': sort,
      'monthdesc': monthdesc,
      'dates': dates,
      'present': present,
      'absent': absent,
    };
  }

  @override
  String toString() {
    return 'Attendance(id: $id, syid: $syid, month: $month, days: $days, year: $year, levelid: $levelid, sydesc: $sydesc, sort: $sort, monthdesc: $monthdesc, dates: $dates, present: $present, absent: $absent)';
  }
}
