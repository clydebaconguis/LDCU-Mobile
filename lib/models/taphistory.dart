class TapHistory {
  final int id;
  final int studid;
  final String tdate;
  final String ttime;
  final String tapstate;
  final int pushstatus;
  final String message;

  TapHistory({
    required this.id,
    required this.studid,
    required this.tdate,
    required this.ttime,
    required this.tapstate,
    required this.pushstatus,
    required this.message,
  });

  factory TapHistory.fromJson(Map<String, dynamic> json) {
    return TapHistory(
      id: json['id'] ?? 0,
      studid: json['studid'] ?? 0,
      tdate: json['tdate'] ?? '',
      ttime: json['ttime'] ?? '',
      tapstate: json['tapstate'] ?? '',
      pushstatus: json['pushstatus'] ?? 0,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studid': studid,
      'tdate': tdate,
      'ttime': ttime,
      'tapstate': tapstate,
      'pushstatus': pushstatus,
      'message': message,
    };
  }

  @override
  String toString() {
    return 'TapHistory(id=$id, studid=$studid, tdate: $tdate, ttime: $ttime, tapstate: $tapstate, pushstatus: $pushstatus, message: $message)';
  }
}
