class Login {
  final int id;
  final String name;
  final String email;
  final int type;

  Login({
    required this.id,
    required this.name,
    required this.email,
    required this.type,
  });

  factory Login.fromJson(Map<String, dynamic> json) {
    return Login(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      type: json['type'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'type': type,
    };
  }

  @override
  String toString() {
    return 'login(id: $id, name: $name, email: $email, type: $type)';
  }
}
