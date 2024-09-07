import 'package:flutter/material.dart';
import 'package:pushtrial/schools/api/school_api.dart';
import 'package:pushtrial/schools/models/schools.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pushtrial/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SchoolScreen extends StatefulWidget {
  @override
  _SchoolScreenState createState() => _SchoolScreenState();
}

class _SchoolScreenState extends State<SchoolScreen> {
  List<School> schoolNames = [];
  List<School> filteredSchoolNames = [];
  String? selectedSchool;
  String host = SchoolApi().getImage();
  TextEditingController searchController = TextEditingController();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
    searchController.addListener(_filterSchools);
  }

  Future<void> _initializeData() async {
    setState(() {
      loading = true;
    });

    await getSchools();

    setState(() {
      loading = false;
    });
  }

  Future<void> getSchools() async {
    final response = await SchoolApi().getSchoolList();
    Iterable list = json.decode(response.body);

    setState(() {
      schoolNames = list.map((model) => School.fromJson(model)).toList();
      schoolNames.sort((a, b) => a.schoolname.compareTo(b.schoolname));
      filteredSchoolNames = schoolNames;
    });
  }

  void _filterSchools() {
    setState(() {
      filteredSchoolNames = schoolNames
          .where((school) => school.schoolname
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  Future<void> _storeSelectedSchool(String eslink) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedSchool', eslink);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? Center(
              child: LoadingAnimationWidget.prograssiveDots(
                color: Colors.black,
                size: 100,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Image.asset(
                    'assets/cklogo.png',
                    width: 200,
                    height: 200,
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 50, right: 50),
                    child: SizedBox(
                      height: 50,
                      child: TextFormField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          labelText: 'Search School',
                          labelStyle: TextStyle(fontSize: 12),
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                      ),
                    )),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: filteredSchoolNames.length,
                      itemBuilder: (context, index) {
                        final school = filteredSchoolNames[index];
                        return GestureDetector(
                          onTap: () async {
                            setState(() {
                              selectedSchool = school.eslink;
                            });

                            if (selectedSchool != null &&
                                selectedSchool!.isNotEmpty) {
                              await _storeSelectedSchool(selectedSchool!);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()),
                              );
                            } else {
                              print('Selected school is null or empty.');
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: "$host${school.schoollogo}",
                                    width: 80,
                                    height: 80,
                                    placeholder: (context, url) =>
                                        CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                      'assets/cklogo.png',
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  school.schoolname,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
