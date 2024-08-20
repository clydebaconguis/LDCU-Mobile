class Transactions {
  final int id;
  final String ornum;
  final String transdate;
  final String totalamount;
  final String amountpaid;
  final int studid;
  final String studname;
  final String paytype;

  Transactions({
    required this.id,
    required this.ornum,
    required this.transdate,
    required this.totalamount,
    required this.amountpaid,
    required this.studid,
    required this.studname,
    required this.paytype,
  });

  factory Transactions.fromJson(Map<String, dynamic> json) {
    return Transactions(
      id: json['id'],
      ornum: json['ornum'],
      transdate: json['transdate'],
      totalamount: json['totalamount'],
      amountpaid: json['amountpaid'],
      studid: json['studid'],
      studname: json['studname'],
      paytype: json['paytype'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ornum': ornum,
      'transdate': transdate,
      'totalamount': totalamount,
      'amountpaid': amountpaid,
      'studid': studid,
      'studname': studname,
      'paytype': paytype,
    };
  }

  @override
  String toString() {
    return 'Transactions(id: $id, ornum: $ornum, transdate: $transdate, totalamount: $totalamount, amountpaid: $amountpaid, studid: $studid, studname: $studname, paytype: $paytype)';
  }
}
