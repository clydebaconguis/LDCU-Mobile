class PaymentOptions {
  final int id;
  final String description;

  PaymentOptions({
    required this.id,
    required this.description,
  });

  factory PaymentOptions.fromJson(Map<String, dynamic> json) {
    return PaymentOptions(
      id: json['id'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
    };
  }

  @override
  String toString() {
    return 'PaymentOptions(id: $id,description: $description)';
  }
}

class Bank {
  final int paymenttype;
  final String optionDescription;

  Bank({
    required this.paymenttype,
    required this.optionDescription,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      paymenttype: json['paymenttype'],
      optionDescription: json['optionDescription'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymenttype': paymenttype,
      'optionDescription': optionDescription,
    };
  }

  @override
  String toString() {
    return 'Bank(paymenttype: $paymenttype,optionDescription: $optionDescription)';
  }
}

class SY {
  final int id;
  final String sydesc;

  SY({
    required this.id,
    required this.sydesc,
  });

  factory SY.fromJson(Map<String, dynamic> json) {
    return SY(
      id: json['id'],
      sydesc: json['sydesc'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sydesc': sydesc,
    };
  }

  @override
  String toString() {
    return 'SY(id: $id,sydesc: $sydesc)';
  }
}

class Semester {
  final int id;
  final String semester;

  Semester({
    required this.id,
    required this.semester,
  });

  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      id: json['id'],
      semester: json['semester'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'semester': semester,
    };
  }

  @override
  String toString() {
    return 'Semester(id: $id,semester: $semester)';
  }
}

class Contact {
  final String contactno;
  final String mcontactno;
  final String fcontactno;
  final String gcontactno;

  Contact({
    required this.contactno,
    required this.mcontactno,
    required this.fcontactno,
    required this.gcontactno,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      contactno: json['contactno'],
      mcontactno: json['mcontactno'],
      fcontactno: json['fcontactno'],
      gcontactno: json['gcontactno'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contactno': contactno,
      'mcontactno': mcontactno,
      'fcontactno': fcontactno,
      'gcontactno': gcontactno,
    };
  }

  @override
  String toString() {
    return 'Student(contactno: $contactno,mcontactno: $mcontactno,fcontactno: $fcontactno,gcontactno: $gcontactno)';
  }
}
