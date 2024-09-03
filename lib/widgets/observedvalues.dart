import 'dart:convert';
import 'package:pushtrial/models/observedvalues.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:pushtrial/api/api.dart';

class ObservedValuesScreen extends StatefulWidget {
  const ObservedValuesScreen({super.key});

  @override
  State<ObservedValuesScreen> createState() => _ObservedValuesState();
}

class _ObservedValuesState extends State<ObservedValuesScreen> {
  String studid = '0';
  List<RatingValues> _ratingValues = [];
  List<Setup> _setup = [];
  List<StudentObservedValues> _studentObservedValues = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await getUser();
    getObservedValues();
    setState(() {});
  }

  Future<void> getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('studid');

    if (json != null) {
      setState(() {
        studid = json;
      });
    }
  }

  Future<void> getObservedValues() async {
    final response = await CallApi().getObservedValues(studid);
    final Map<String, dynamic> responseData = json.decode(response.body);

    _ratingValues = (responseData['ob_rv'] as List)
        .map((data) => RatingValues.fromJson(data))
        .toList();

    _setup = (responseData['ob_setup'] as List)
        .map((data) => Setup.fromJson(data))
        .toList();

    _studentObservedValues = (responseData['student_ob'] as List)
        .map((data) => StudentObservedValues.fromJson(data))
        .toList();

    setState(() {});
    // print('Rating values: $_ratingValues');
    // print('Setup: $_setup');
    // print('Student observed values: $_studentObservedValues');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(0.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                ),
                child: DataTable(
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Description',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Q1',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Q2',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Q3',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Q4',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                  rows: _setup.map((setup) {
                    final studentObserved = _studentObservedValues.firstWhere(
                      (obs) => obs.gsdid == setup.id,
                      orElse: () => StudentObservedValues(
                        gsdid: setup.id,
                        q1eval: 0,
                        q2eval: 0,
                        q3eval: 0,
                        q4eval: 0,
                      ),
                    );

                    String getRatingValue(int evalId) {
                      return _ratingValues
                          .firstWhere(
                            (rating) => rating.id == evalId,
                            orElse: () => RatingValues(
                              id: 0,
                              sort: '',
                              gsid: 0,
                              description: '',
                              value: '',
                            ),
                          )
                          .value;
                    }

                    return DataRow(
                      cells: [
                        DataCell(
                          Container(
                            width: 300,
                            child: Text(
                              setup.description,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                          ),
                        ),
                        DataCell(Text(
                          getRatingValue(studentObserved.q1eval),
                          softWrap: false,
                        )),
                        DataCell(Text(
                          getRatingValue(studentObserved.q2eval),
                          softWrap: false,
                        )),
                        DataCell(Text(
                          getRatingValue(studentObserved.q3eval),
                          softWrap: false,
                        )),
                        DataCell(Text(
                          getRatingValue(studentObserved.q4eval),
                          softWrap: false,
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}