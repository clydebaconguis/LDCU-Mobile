class SMS {
  final int id;
  final int studid;
  final int pushstatus;
  final String message;
  final String receiver;
  String createddatetime;

  SMS({
    required this.id,
    required this.studid,
    required this.pushstatus,
    required this.message,
    required this.receiver,
    this.createddatetime = '',
  });

  factory SMS.fromJson(Map<String, dynamic> json) {
    return SMS(
      id: json['id'],
      studid: json['studid'],
      pushstatus: json['pushstatus'],
      message: json['message'],
      receiver: json['receiver'],
      createddatetime: json['createddatetime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studid': studid,
      'pushstatus': pushstatus,
      'message': message,
      'receiver': receiver,
      'createddatetime': createddatetime,
    };
  }

  @override
  String toString() {
    return 'SMS(id: $id,studid: $studid, pushstatus: $pushstatus, message: $message, receiver: $receiver, createddatetime: $createddatetime)';
  }
}
