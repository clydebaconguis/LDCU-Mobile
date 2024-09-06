import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class SchoolApi {
  final String _mainDomain = "https://esvault.essentiel.ph/";
  final String _esDomain = "api/getSchoolList";

  getSchoolList() async {
    var fullUrl = '$_mainDomain$_esDomain';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getImage() {
    return _mainDomain;
  }
}
