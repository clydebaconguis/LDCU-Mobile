class SchoolInfo {
  final int id;
  final String schoolid;
  final String schoolname;
  final String address;
  final String picurl;
  final String abbreviation;
  final int admission;
  final String schoolcolor;

  SchoolInfo({
    required this.id,
    required this.schoolid,
    required this.schoolname,
    required this.address,
    required this.picurl,
    required this.abbreviation,
    required this.admission,
    required this.schoolcolor,
  });

  factory SchoolInfo.fromJson(Map<String, dynamic> json) {
    return SchoolInfo(
      id: json['id'] ?? 0,
      schoolid: json['schoolid'] ?? '',
      schoolname: json['schoolname'] ?? '',
      address: json['address'] ?? '',
      picurl: json['picurl'] ?? '',
      abbreviation: json['abbreviation'] ?? '',
      admission: json['admission'] ?? 0,
      schoolcolor: json['schoolcolor'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schoolid': schoolid,
      'schoolname': schoolname,
      'address': address,
      'picurl': picurl,
      'abbreviation': abbreviation,
      'admission': admission,
      'schoolcolor': schoolcolor,
    };
  }

  @override
  String toString() {
    return 'SchoolInfo(id: $id,schoolid: $schoolid,schoolname: $schoolname,address: $address,picurl: $picurl,abbreviation: $abbreviation,admission: $admission,schoolcolor: $schoolcolor)';
  }
}
