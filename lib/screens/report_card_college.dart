import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:pushtrial/models/enrollment_info.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pushtrial/api/api.dart';
import 'package:pushtrial/models/grades.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ReportCardCollege extends StatefulWidget {
  const ReportCardCollege({super.key});

  @override
  State<ReportCardCollege> createState() => _ReportCardCollegeState();
}

class _ReportCardCollegeState extends State<ReportCardCollege> {
  Color mainClr = Colors.white;
  @override
  void initState() {
    getUser();
    super.initState();
  }

  var id = '0';
  var studid = '0';
  var syid = 0;
  var semid = 1;
  var gradelevel = 0;
  var sectionid = 0;
  var strand = 0;
  String selectedYear = '';
  String selectedSem = '1st Sem';
  List<String> years = [];
  List<String> sem = ['1st Sem', '2nd Sem'];
  List<Grades> data = [];
  List<Grades> finalGrade = [];
  List<EnrollmentInfo> enInfoData = [];
  List<Grades> concatenatedArray = [];
  bool loading = true;

  Future<void> getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('studid');
    if (json != null) {
      setState(() {
        id = json;
        loading = true;
      });
      await getEnrollment();
      await getGrades(0);
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> getGrades(int index) async {
    Iterable gdList = [];
    Iterable gdFinal = [];

    await CallApi()
        .getStudGrade(id, gradelevel, syid, sectionid, strand, index)
        .then((response) {
      setState(() {
        Iterable list = json.decode(response.body);

        for (var gd in list) {
          gdList = gd['grades'];
          if (gradelevel < 17) {
            gdFinal = gd['finalgrade'];
          }
        }

        if (gradelevel < 17) {
          data = gdList.map((model) {
            return Grades.fromJson(model);
          }).toList();
        } else {
          data = gdList.map((model) {
            return Grades(
              subjcode: model['subjcode'] ?? '',
              subjdesc: model['subjdesc'] ?? '',
              q1: model['prelemgrade'] ?? 0,
              q2: model['midtermgrade'] ?? 0,
              q3: model['prefigrade'] ?? 0,
              q4: model['finalgrade'] ?? 0,
              fg: model['fg'] ?? '',
              finalrating: model['finalrating'] ?? '',
              actiontaken: model['actiontaken'] ?? '',
            );
          }).toList();
        }

        if (gradelevel == 14 || gradelevel == 15) {
          finalGrade = gdFinal.map((ave) {
            return ave['semid'].toString() == index.toString()
                ? Grades.parseAverage(ave)
                : Grades(
                    subjcode: '',
                    q1: '',
                    q2: '',
                    q3: '',
                    q4: '',
                    fg: '',
                    finalrating: '',
                    actiontaken: '',
                    subjdesc: '');
          }).toList();
        }

        semid = index;
        concatenatedArray = [...data, ...finalGrade];
        concatenatedArray = concatenatedArray
            .where((grade) => grade.subjcode.isNotEmpty)
            .toList();
      });
    });
  }

  getEnrollment() async {
    await CallApi().getEnrollmentInfo(id).then((response) {
      setState(() {
        Iterable list = json.decode(response.body);

        enInfoData = list.map((model) {
          return EnrollmentInfo.fromJson(model);
        }).toList();

        for (var element in enInfoData) {
          years.add(element.sydesc);
        }
        Set<String> uniqueSet = years.toSet();
        years = uniqueSet.toList();

        selectedYear = enInfoData[enInfoData.length - 1].sydesc;
        var lastindex = enInfoData[enInfoData.length - 1];

        setState(() {
          syid = lastindex.syid;
          semid = 1;
          gradelevel = lastindex.levelid;
          sectionid = lastindex.sectionid;
          strand = lastindex.strandid;
        });
        getGrades(1);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('REPORT CARD',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
      ),
      body: loading
          ? Center(
              child: LoadingAnimationWidget.prograssiveDots(
                color: const Color.fromARGB(255, 133, 13, 22),
                size: 100,
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(30),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: selectedYear.isNotEmpty
                          ? DropdownButtonFormField2<String>(
                              decoration: InputDecoration(
                                labelText: 'School Year',
                                labelStyle: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                border: OutlineInputBorder(),
                              ),
                              isExpanded: true,
                              hint: Text(
                                'Choose a school year',
                                style: TextStyle(
                                    fontSize: 14, fontFamily: 'Poppins'),
                              ),
                              value: selectedYear,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedYear = newValue!;
                                  for (var yr in enInfoData) {
                                    if (yr.sydesc == selectedYear) {
                                      syid = yr.syid;
                                      selectedSem = sem[0];
                                      gradelevel = yr.levelid;
                                      sectionid = yr.sectionid;
                                      strand = yr.strandid;
                                      getGrades(yr.semid);
                                    }
                                  }
                                });
                              },
                              items: years.map<DropdownMenuItem<String>>(
                                (String year) {
                                  return DropdownMenuItem<String>(
                                    value: year,
                                    child: Text(
                                      year,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                },
                              ).toList(),
                            )
                          : const CircularProgressIndicator(),
                    ),
                    SizedBox(width: 10.0),
                    if (gradelevel == 14 ||
                        gradelevel == 15 ||
                        gradelevel >= 17)
                      Expanded(
                        child: selectedSem.isNotEmpty
                            ? DropdownButtonFormField2<String>(
                                decoration: InputDecoration(
                                  labelText: 'Semester',
                                  labelStyle: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                                isExpanded: true,
                                value: selectedSem,
                                hint: const Text('Select Sem'),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedSem = newValue!;
                                    var index = sem.indexOf(selectedSem) + 1;
                                    getGrades(index);
                                  });
                                },
                                items: sem.map<DropdownMenuItem<String>>(
                                  (String semes) {
                                    return DropdownMenuItem<String>(
                                      value: semes,
                                      child: Text(
                                        semes,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  },
                                ).toList(),
                              )
                            : const CircularProgressIndicator(),
                      ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: DataTable(
                          columnSpacing: 30.0,
                          columns: [
                            const DataColumn(
                                label: Text(
                              'Subjects',
                              style: TextStyle(
                                fontSize: 11,
                              ),
                            )),
                            DataColumn(
                              label: MergeSemantics(
                                child: SizedBox(
                                  width: 112,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (gradelevel >= 17 || gradelevel == 0)
                                        const Text(
                                          'Subject Description',
                                          style: TextStyle(
                                            fontSize: 11,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const DataColumn(
                              label: Expanded(
                                child: Text(
                                  'Final\nRating',
                                  style: TextStyle(
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ),
                            const DataColumn(
                              label: Expanded(
                                child: Text(
                                  'Action \nTaken',
                                  style: TextStyle(
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ),
                          ],
                          rows: concatenatedArray.asMap().entries.map((entry) {
                            final index = entry.key;
                            final grade = entry.value;
                            final isEvenRow = index % 2 == 0;
                            final rowColor =
                                isEvenRow ? Colors.grey.shade200 : Colors.white;

                            return DataRow(
                                color: WidgetStateColor.resolveWith(
                                    (states) => rowColor),
                                cells: [
                                  DataCell(
                                    Container(
                                      width: 100,
                                      child: Text(
                                        grade.subjdesc,
                                        style: TextStyle(
                                          fontSize: 10,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        if (gradelevel >= 17)
                                          Container(
                                            width: 100,
                                            child: Text(
                                              grade.subjdesc,
                                              style: TextStyle(
                                                fontSize: 10,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  grade.finalrating != "null"
                                      ? DataCell(Text(
                                          grade.finalrating,
                                          style: TextStyle(
                                            fontSize: 11,
                                          ),
                                        ))
                                      : const DataCell(Text('')),
                                  DataCell(
                                    Text(
                                      grade.actiontaken.toString().isNotEmpty
                                          ? grade.actiontaken
                                          : '',
                                      style: TextStyle(
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ]);
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
