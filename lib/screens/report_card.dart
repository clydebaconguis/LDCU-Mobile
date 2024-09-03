import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:pushtrial/models/enrollment_info.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pushtrial/api/api.dart';
import 'package:pushtrial/models/grades.dart';
import '../widgets/studentattendance.dart';
import '../widgets/observedvalues.dart';

class ReportCard extends StatefulWidget {
  const ReportCard({super.key});

  @override
  State<ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<ReportCard> {
  Color mainClr = Colors.white;
  @override
  void initState() {
    getUser();
    super.initState();
  }

  var id = '0';
  var studid = '0';
  var syid = 0;
  var semid = 0;
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

  Future<void> getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('studid');
    if (json != null) {
      setState(() {
        id = json;
      });
      getEnrollment();
    }
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

          // print(data);
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
      body: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: null,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(10),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: Container(
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: const Color.fromARGB(255, 133, 13, 22),
                  ),
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: Color.fromARGB(255, 219, 154, 149),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.white,
                    labelStyle: TextStyle(fontSize: 12),
                    tabs: [
                      Tab(text: 'Grades'),
                      Tab(text: 'Attendance'),
                      Tab(text: 'Core Values'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: TabBarView(
            children: [
              _buildGrades(),
              _buildAttendance(),
              _buildCoreValues(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrades() {
    return ListView(
      padding: const EdgeInsets.all(30),
      children: [
        selectedYear.isNotEmpty
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
                  style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
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
        if (gradelevel == 14 || gradelevel == 15 || gradelevel >= 17) ...[
          SizedBox(height: 10.0),
          selectedSem.isNotEmpty
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
        ],
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
                              if (gradelevel < 17 && gradelevel != 0)
                                const Text(
                                  'Periodic Ratings',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(fontSize: 11),
                                ),
                              if (gradelevel < 17 && gradelevel != 0)
                                const Divider(
                                  height: 5,
                                  thickness: 1,
                                  color: Colors.grey,
                                ),
                              if (gradelevel == 14 ||
                                  gradelevel == 15 && gradelevel != 0)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    if (semid == 1) const Text('Q1'),
                                    if (semid == 1) const Text('Q2'),
                                    if (semid == 2) const Text('Q3'),
                                    if (semid == 2) const Text('Q4'),
                                  ],
                                ),
                              if (gradelevel != 14 &&
                                  gradelevel != 15 &&
                                  gradelevel != 17 &&
                                  gradelevel < 17 &&
                                  gradelevel != 0)
                                const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text('Q1'),
                                    Text('Q2'),
                                    Text('Q3'),
                                    Text('Q4'),
                                  ],
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
                        color:
                            WidgetStateColor.resolveWith((states) => rowColor),
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                if (gradelevel == 14 || gradelevel == 15)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      if (semid == 1)
                                        Text(
                                          grade.q1 != "null" ? grade.q1 : '  ',
                                          style: TextStyle(
                                            fontSize: 11,
                                          ),
                                        ),
                                      if (semid == 1)
                                        Text(
                                          grade.q2 != "null" ? grade.q2 : '  ',
                                          style: TextStyle(
                                            fontSize: 11,
                                          ),
                                        ),
                                      if (semid == 2)
                                        Text(
                                          grade.q3 != "null" ? grade.q3 : '  ',
                                          style: TextStyle(
                                            fontSize: 11,
                                          ),
                                        ),
                                      if (semid == 2)
                                        Text(
                                          grade.q4 != "null" ? grade.q4 : '  ',
                                          style: TextStyle(
                                            fontSize: 11,
                                          ),
                                        ),
                                    ],
                                  ),
                                if (gradelevel != 14 &&
                                    gradelevel != 15 &&
                                    gradelevel != 17 &&
                                    gradelevel < 17)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        grade.q1 != "null" ? grade.q1 : '  ',
                                        style: TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                      Text(
                                        grade.q2 != "null" ? grade.q2 : '  ',
                                        style: TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                      Text(
                                        grade.q3 != "null" ? grade.q3 : '  ',
                                        style: TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                      Text(
                                        grade.q4 != "null" ? grade.q4 : '  ',
                                        style: TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
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
    );
  }

  Widget _buildAttendance() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: StudentAttendanceScreen(),
    );
  }

  Widget _buildCoreValues() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: ObservedValuesScreen(),
    );
  }
}
