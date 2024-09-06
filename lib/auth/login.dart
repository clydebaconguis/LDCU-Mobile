import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pushtrial/api/api.dart';
import '../models/user.dart';
import '../models/login.dart';
import 'package:pushtrial/push_notifications.dart';
import 'package:pushtrial/models/school_info.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final CallApi _callApi = CallApi();
  String? picurl;

  bool _obscureText = true;
  String host = CallApi().getImage();
  List<SchoolInfo> schoolInfo = [];

  Color schoolColor = Color.fromARGB(0, 255, 255, 255);

  Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 7 || hexString.length == 9) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> getSchoolInfo() async {
    final response = await CallApi().getSchoolInfo();
    final parsedResponse = json.decode(response.body);
    if (parsedResponse is List) {
      setState(() {
        schoolInfo = parsedResponse
            .map((model) => SchoolInfo.fromJson(model))
            .toList()
            .cast<SchoolInfo>();
        schoolColor = hexToColor(schoolInfo[0].schoolcolor);
        picurl = schoolInfo[0].picurl;
      });

      print(schoolInfo);
    }
  }

  Future<String?> getSchool() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selectedSchool');
  }

  Future<void> _loadSelectedSchool() async {
    String? selectedSchool = await getSchool();

    if (selectedSchool != null) {
      print('Loaded school eslink: $selectedSchool');
    } else {
      print('No school found in preferences.');
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final username = _usernameController.text;
      final password = _passwordController.text;

      try {
        final response = await _callApi.login(username, password);
        // print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          if (response.body.isNotEmpty) {
            final Map<String, dynamic> responseData = jsonDecode(response.body);

            if (responseData['stud'] != null &&
                responseData['userlogin'] != null) {
              final User user = User.fromJson(responseData['stud']);
              final Login userLogin = Login.fromJson(responseData['userlogin']);
              final prefs = await SharedPreferences.getInstance();

              await prefs.setString('user', jsonEncode(user.toJson()));
              await prefs.setString(
                  'studid', responseData['stud']['id'].toString());
              await prefs.setString(
                  'userlogin', jsonEncode(userLogin.toJson()));

              // String? token = await PushNotifications.getFCMToken();
              // if (token != null) {
              //   await _callApi.getSaveToken(user.id, userLogin.type, token);
              // }

              Navigator.pushReplacementNamed(context, '/home', arguments: user);
            } else {
              _showSnackBar('Invalid username or password');
            }
          } else {
            _showSnackBar('Response body is empty');
          }
        } else if (response.statusCode == 400) {
          _showSnackBar('Bad request. Please check your input.');
        } else if (response.statusCode == 401) {
          _showSnackBar('Unauthorized. Please check your credentials.');
        } else {
          _showSnackBar('Failed to login. Please try again.');
        }
      } catch (e) {
        print('Error: $e');
        _showSnackBar('An error occurred. Please try again.');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await getSchoolInfo();
    _loadSelectedSchool();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 50, right: 50, bottom: 80),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (picurl != null) // Check if picurl is not null
                  CachedNetworkImage(
                    imageUrl: "$host$picurl",
                    width: 200,
                    height: 200,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    fit: BoxFit.cover,
                  )
                else
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Icon(Icons.error, size: 50),
                  ),
                const SizedBox(height: 20),
                const Text(
                  'STUDENT PORTAL',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Poppins",
                  ),
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 109, 17, 10),
                  ),
                  child: const Text(
                    'LOGIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
