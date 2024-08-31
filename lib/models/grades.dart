class Grades {
  final String subjcode;
  final String subjdesc;
  final String q1;
  final String q2;
  final String q3;
  final String q4;
  final String fg;
  final String finalrating;
  final String actiontaken;

  Grades({
    required this.subjcode,
    required this.subjdesc,
    required this.q1,
    required this.q2,
    required this.q3,
    required this.q4,
    required this.fg,
    required this.finalrating,
    required this.actiontaken,
  });

  factory Grades.fromJson(Map json) {
    var subjcode = json['subjcode'] ?? '';
    var subjdesc = json['subjdesc'] ?? '';
    var q1 = json['q1'].toString();
    var q2 = json['q2'].toString();
    var q3 = json['q3'].toString();
    var q4 = json['q4'].toString();
    var fg = json['fg'].toString();
    var finalrating = json['finalrating'].toString();
    var actiontaken = json['actiontaken'] ?? '';
    return Grades(
        subjcode: subjcode,
        q1: q1,
        q2: q2,
        q3: q3,
        q4: q4,
        fg: fg,
        finalrating: finalrating,
        actiontaken: actiontaken,
        subjdesc: subjdesc);
  }

  factory Grades.parseAverage(Map json) {
    var subjcode = json['subjdesc'] ?? '';
    var q1 = json['q1'].toString();
    var q2 = json['q2'].toString();
    var q3 = json['q3'].toString();
    var q4 = json['q4'].toString();
    var fg = json['fg'].toString();
    var finalrating = json['finalrating'].toString();
    var actiontaken = json['actiontaken'] ?? '';
    return Grades(
        subjcode: subjcode,
        q1: q1,
        q2: q2,
        q3: q3,
        q4: q4,
        fg: fg,
        finalrating: finalrating,
        actiontaken: actiontaken,
        subjdesc: subjcode);
  }

  @override
  String toString() {
    return 'Grades(subjcode: $subjcode, subjdesc: $subjdesc, q1: $q1, q2: $q2, q3: $q3, q4: $q4, fg: $fg, finalrating: $finalrating, actiontaken: $actiontaken)';
  }
}
