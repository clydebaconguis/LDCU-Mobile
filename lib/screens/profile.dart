import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pushtrial/models/user_data.dart';
import 'package:pushtrial/api/api.dart';
import '../auth/login.dart';
import 'package:pushtrial/models/enrollment_info.dart';
import 'dart:convert';
import 'package:pushtrial/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  ProfileScreen({required this.user});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  User user = UserData.myUser;
  String id = '0';
  String selectedYear = '';
  List<EnrollmentInfo> enInfoData = [];
  String syDesc = '';
  String sem = '';
  String host = CallApi().getImage();
  bool isValid = false;
  bool loading = true;

  @override
  void initState() {
    getUser();
    getUserInfo();
    isImageUrlValid();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontFamily: 'Poppins')),
      ),
      body: loading
          ? Center(
              child: LoadingAnimationWidget.prograssiveDots(
                color: const Color.fromARGB(255, 133, 13, 22),
                size: 100,
              ),
            )
          : Column(
              children: [
                _buildProfileHeader(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildSectionHeader('Enrollment Information'),
                          _buildInfoRow(
                            'Grade Level:',
                            _getGradeLevel(),
                            icon: Icons.grade,
                          ),
                          if (_getStrand().isNotEmpty)
                            _buildInfoRow(
                              'Strand:',
                              _getStrand(),
                              icon: Icons.school,
                            ),
                          if (_getCourse().isNotEmpty)
                            _buildInfoRow(
                              'Course:',
                              _getCourse(),
                              icon: Icons.school,
                            ),
                          if (widget.user.lrn != null &&
                              widget.user.lrn!.isNotEmpty)
                            _buildInfoRow(
                              'LRN:',
                              widget.user.lrn ?? '',
                              icon: Icons.confirmation_number,
                            ),
                          const SizedBox(height: 32),
                          _buildSectionHeader('Personal Information'),
                          _buildInfoRow(
                            'First Name:',
                            widget.user.firstname ?? '',
                            icon: Icons.badge,
                          ),
                          _buildInfoRow(
                            'Middle Name:',
                            widget.user.middlename ?? '',
                            icon: Icons.badge,
                          ),
                          _buildInfoRow(
                            'Last Name:',
                            widget.user.lastname ?? '',
                            icon: Icons.badge,
                          ),
                          _buildInfoRow(
                            'Suffix:',
                            widget.user.suffix,
                            icon: Icons.badge,
                          ),
                          _buildInfoRow(
                            'Student ID:',
                            widget.user.sid ?? '',
                            icon: Icons.tag,
                          ),
                          _buildInfoRow(
                            'Date of Birth:',
                            widget.user.dob ?? '',
                            icon: Icons.calendar_month,
                          ),
                          _buildInfoRow(
                            'Gender:',
                            widget.user.gender ?? '',
                            icon: Icons.man,
                          ),
                          // _buildInfoRow(
                          //   'Nationality:',
                          //   '${widget.user.nationality ?? ''}',
                          //   icon: Icons.map,
                          // ),
                          _buildInfoRow(
                            'Mobile Number:',
                            widget.user.contactno ?? '',
                            icon: Icons.phone_iphone,
                          ),
                          _buildInfoRow(
                            'Email Address:',
                            widget.user.semail ?? '',
                            icon: Icons.mail,
                          ),
                          const SizedBox(height: 32),
                          _buildSectionHeader('Parent/Guardian Information'),
                          _buildInfoRow(
                            'Father\'s Full Name:',
                            widget.user.fathername ?? '',
                            icon: Icons.badge,
                          ),
                          _buildInfoRow(
                            'Father\'s Occupation:',
                            widget.user.foccupation ?? '',
                            icon: Icons.work,
                          ),
                          _buildInfoRow(
                            'Father\'s Contact Number:',
                            widget.user.fcontactno ?? '',
                            icon: Icons.phone_iphone,
                          ),
                          _buildInfoRow(
                            'Mother\'s Full Maiden Name:',
                            widget.user.mothername ?? '',
                            icon: Icons.badge,
                          ),
                          _buildInfoRow(
                            'Mother\'s Occupation:',
                            widget.user.moccupation ?? '',
                            icon: Icons.work,
                          ),
                          _buildInfoRow(
                            'Mother\'s Contact Number:',
                            widget.user.mcontactno ?? '',
                            icon: Icons.phone_iphone,
                          ),
                          _buildInfoRow(
                            'Guardian\'s Full Name:',
                            widget.user.guardianname ?? '',
                            icon: Icons.badge,
                          ),
                          _buildInfoRow(
                            'Guardian\'s Relationship:',
                            widget.user.guardianrelation ?? '',
                            icon: Icons.supervised_user_circle,
                          ),
                          _buildInfoRow(
                            'Guardian\'s Contact Number:',
                            widget.user.gcontactno ?? '',
                            icon: Icons.phone_iphone,
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: () => _logout(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 133, 13, 22),
                            ),
                            child: const Text(
                              'Logout',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      child: Column(
        children: [
          Container(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 5),
                  (user.picurl != null && user.picurl!.isNotEmpty)
                      ? CachedNetworkImage(
                          imageUrl: "$host${user.picurl}",
                          imageBuilder: (context, imageProvider) =>
                              CircleAvatar(
                            radius: 70,
                            backgroundImage: imageProvider,
                          ),
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) =>
                              const CircleAvatar(
                            radius: 70,
                            backgroundImage: AssetImage("assets/ldcu.png"),
                          ),
                        )
                      : const CircleAvatar(
                          radius: 70,
                          backgroundImage: AssetImage("assets/ldcu.png"),
                        ),
                ],
              ),
            ),
          ),
          Text(
            widget.user.firstname ?? '',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.user.lastname ?? '',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  getUserInfo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('user');

    setState(() {
      user = json == null ? UserData.myUser : User.fromJson(jsonDecode(json));
    });
  }

  void isImageUrlValid() async {
    try {
      final response = await http.head(Uri.parse('$host${user.picurl}'));
      setState(() {
        isValid = response.statusCode == 200;
      });
    } catch (e) {
      setState(() {
        isValid = false;
      });
    }
  }

  String _getGradeLevel() {
    final latestInfo = getSelectedEnrollmentInfo();
    return latestInfo?.levelname ?? 'Not Available';
  }

  String _getStrand() {
    final latestInfo = getSelectedEnrollmentInfo();
    return latestInfo?.strandcode ?? 'Not Available';
  }

  String _getCourse() {
    final latestInfo = getSelectedEnrollmentInfo();
    return latestInfo?.courseabrv ?? '';
  }

  EnrollmentInfo? getSelectedEnrollmentInfo() {
    if (selectedYear.isEmpty) return null;

    return enInfoData.firstWhere(
      (enrollment) => enrollment.sydesc.contains(selectedYear),
      orElse: () => EnrollmentInfo(
        sydesc: '',
        levelname: '',
        sectionname: 'Not Found',
        semid: 0,
        dateenrolled: '',
        syid: 0,
        levelid: 0,
        sectionid: 0,
        isactive: 0,
        strandid: 0,
        semester: '',
        strandcode: '',
        courseabrv: '',
      ),
    );
  }

  Future<void> getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('studid');

    if (json != null) {
      setState(() {
        id = json;
        loading = true;
      });
      await getEnrollment();
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> getEnrollment() async {
    final response = await CallApi().getEnrollmentInfo(id);
    setState(() {
      Iterable list = json.decode(response.body);
      enInfoData = list.map((model) => EnrollmentInfo.fromJson(model)).toList();

      if (enInfoData.isNotEmpty) {
        selectedYear = enInfoData.last.sydesc;
        syDesc = selectedYear;

        var latestInfo =
            enInfoData.firstWhere((element) => element.sydesc == selectedYear,
                orElse: () => EnrollmentInfo(
                      sydesc: '',
                      levelname: '',
                      sectionname: 'Not Found',
                      semid: 0,
                      dateenrolled: '',
                      syid: 0,
                      levelid: 0,
                      sectionid: 0,
                      isactive: 0,
                      strandid: 0,
                      semester: '',
                      strandcode: '',
                      courseabrv: '',
                    ));
        sem = latestInfo.semester;
      }
    });
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) Icon(icon, size: 16, color: Colors.grey),
          if (icon != null) const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      final user = User.fromJson(jsonDecode(userJson));
      final studid = user.id;

      //   final fcmtoken = await _firebaseMessaging.getToken();

      //   try {
      //     final response = await CallApi().getDeleteToken(
      //       studid,
      //       fcmtoken,
      //     );

      //     if (response.statusCode == 200) {
      //       print('FCM Token deleted successfully');
      //     } else {
      //       print('Failed to delete FCM Token');
      //     }
      //   } catch (e) {
      //     print('Exception occurred while deleting FCM token: $e');
      //   }
    }

    await prefs.remove('user');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out successfully')),
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Login()),
        (route) => false,
      );
    });
  }
}
