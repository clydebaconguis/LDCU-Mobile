import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CallApi {
  // final String _mainDomain = "https://app-ldcu.essentiel.ph/";
  // final String _mainDomain = "http://127.0.0.1:8000/";
  final String _mainDomain = "http://192.168.50.13:8000/";
  final String _onlineDomain = "https://app-ldcu.essentiel.ph/";
  final String _esDomain = "api/mobile/api_login";
  final String _enrollmentInfo = "api/mobile/api_enrollmentinfo";
  final String _enrollmentData = "api/mobile/api_enrollmentdata";
  final String _billingInfo = "/api/mobile/api_billinginfo";
  final String _studLedger = "/api/mobile/api_studledger";
  final String _picUrl = "api/mobile/api_picurl";
  final String _sf9Attendance = "api/mobile/api_sf9attendance";
  final String _studGrade = "api/mobile/api_getgrade";
  final String _getSchedule = "api/mobile/api_getschedule";
  final String _events = "/api/mobile/api_get_events";
  final String _attendance = "api/mobile/student_attendance";
  final String _studeObservedValues = "api/mobile/student_observedvalues";
  final String _schoolinfo = "api/mobile/schoolinfo";
  final String _taphistory = "api/mobile/api_get_taphistory";
  final String _updatePushStatus = "api/mobile/api_update_pushstatus";
  final String _transactions = "api/mobile/api_get_transactions";

  getSchoolInfo() async {
    var fullUrl = '$_mainDomain$_schoolinfo';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getTapHistory(studid) async {
    var fullUrl = '$_mainDomain$_taphistory?studid=$studid';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getUpdatePushStatus(id, studid, pushstatus, message) async {
    var fullUrl =
        '$_mainDomain$_updatePushStatus?id=$id&studid=$studid&pushstatus=$pushstatus&message=$message';
    return await http.post(
      Uri.parse(fullUrl),
    );
  }

  getTransactions(studid) async {
    var fullUrl = '$_mainDomain$_transactions?studid=$studid';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getAttendance(
    studid,
    syid,
    levelid,
  ) async {
    var fullUrl =
        '$_mainDomain$_attendance?studid=$studid&syid=$syid&levelid=$levelid&semid=1';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getStudentObservedValues(syid, studid, levelid) async {
    var fullUrl =
        '$_mainDomain$_studeObservedValues?syid=$syid&studid=$studid&levelid=$levelid';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getEvents(syid) async {
    var fullUrl = '$_mainDomain$_events?syid=$syid';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getStudGrade(studid, gradelevel, syid, sectionid, strand, semid) async {
    var fullUrl =
        '$_mainDomain$_studGrade?studid=$studid&gradelevel=$gradelevel&syid=$syid&sectionid=$sectionid&strand=$strand&semid=$semid';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getPicURL(studid) async {
    var fullUrl = '$_mainDomain$_picUrl?studid=$studid';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getSF9Attendance(studid, syid, gradelevel, sectionid, strand) async {
    var fullUrl =
        '$_mainDomain$_sf9Attendance?studid=$studid&syid=$syid&gradelevel=$gradelevel&sectionid=$sectionid&strand=$strand';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getStudLedger(studid, syid, semid) async {
    var fullUrl =
        '$_mainDomain$_studLedger?studid=$studid&syid=$syid&semid=$semid';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getEnrollmentInfo(studid) async {
    var fullUrl = '$_mainDomain$_enrollmentInfo?studid=$studid';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getEnrollmentData(studid, syid, semid) async {
    var fullUrl =
        '$_mainDomain$_enrollmentData?studid=$studid&syid=$syid&semid=$semid';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getBillingInfo(String studid) async {
    var fullUrl =
        '$_mainDomain$_billingInfo?studid=$studid&syid=1&semid=1&monthid=10';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getSchedule(
    studid,
    syid,
    semid,
    sectionid,
    levelid,
  ) async {
    var fullUrl =
        '$_mainDomain$_getSchedule?studid=$studid&syid=$syid&semid=$semid&sectionid=$sectionid&levelid=$levelid';
    return await http.get(
      Uri.parse(fullUrl),
    );
  }

  getImage() {
    return _mainDomain;
  }

  postData(data, apiUrl) async {}

  //  login(username, pword) async {
  //   var fullUrl = '$_mainDomain$_esDomain?&username=$username&pword=$pword';
  //   return await http.get(Uri.parse(fullUrl));
  // }

  login(username, pword) async {
    var fullUrl = '$_onlineDomain$_esDomain?&username=$username&pword=$pword';
    return await http.get(Uri.parse(fullUrl));
  }

  getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    print('Retrieved token: $token');
    return token;
  }

  getPublicData(apiUrl) async {
    var fullUrl = _esDomain + apiUrl;
    return await http.get(
      Uri.parse(fullUrl),
    );
  }
}
