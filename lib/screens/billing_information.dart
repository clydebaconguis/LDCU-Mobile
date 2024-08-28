import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pushtrial/models/enrollment_info.dart';
import 'package:pushtrial/api/api.dart';
import '../widgets/credit_card.dart';
import 'package:pushtrial/models/ledger.dart';
import 'dart:convert';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class BillingInformationPage extends StatefulWidget {
  const BillingInformationPage({super.key});

  @override
  State<BillingInformationPage> createState() => BillingInformationState();
}

class BillingInformationState extends State<BillingInformationPage> {
  String id = '0';
  int syid = 1;
  int semid = 1;
  String selectedYear = '';
  List<String> years = [];
  List<Ledger> data = [];
  List<EnrollmentInfo> enInfoData = [];
  String syDesc = '';
  String sem = '';
  String totalBalance = 'Php 0.00';
  String totalPayment = 'Php 100.00';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BILLING INFORMATION',
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
          : Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(child: CreditCard()),
                  const SizedBox(height: 20),
                  Center(
                    child: Card(
                      color: const Color.fromARGB(255, 14, 19, 29),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.money, color: Colors.white),
                                SizedBox(width: 6),
                                Text(
                                  'Deductions',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              totalPayment,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // const SizedBox(height: 10),
                  Center(
                    child: Container(
                      width: double.infinity,
                      height: 350,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 40.0,
                            dividerThickness: 0,
                            columns: const [
                              DataColumn(
                                  label: Text('Particulars',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 11,
                                      ))),
                              DataColumn(
                                  label: Text('Amount',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 11,
                                      ))),
                              DataColumn(
                                  label: Text('Deductions',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 11,
                                      ))),
                            ],
                            rows: data.map((ledger) {
                              return DataRow(cells: [
                                DataCell(
                                  Container(
                                    width: 90,
                                    child: Text(
                                      ledger.particulars,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 11,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                                DataCell(Text(ledger.amount,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 11,
                                    ),
                                    textAlign: TextAlign.right)),
                                DataCell(Text(ledger.payment,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 11,
                                    ),
                                    textAlign: TextAlign.right)),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
      await getLedger();
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> getLedger() async {
    final response = await CallApi().getStudLedger(id, syid, semid);
    setState(() {
      Iterable list = json.decode(response.body);
      data = list.map((model) => Ledger.fromJson(model)).toList();

      Ledger? totalLedger = data.firstWhere(
        (item) => item.particulars.startsWith('TOTAL:'),
      );

      totalBalance = 'Php ${totalLedger.balance}';
      totalPayment = 'Php ${totalLedger.payment}';
    });
  }

  Future<void> getEnrollment() async {
    final response = await CallApi().getEnrollmentInfo(id);
    setState(() {
      Iterable list = json.decode(response.body);
      enInfoData = list.map((model) => EnrollmentInfo.fromJson(model)).toList();

      years = enInfoData.map((e) => e.sydesc).toSet().toList();
      selectedYear = enInfoData.last.sydesc;

      var latestInfo =
          enInfoData.firstWhere((element) => element.sydesc == selectedYear);
      syid = latestInfo.syid;
      semid = latestInfo.semid;

      syDesc = selectedYear;
      sem = latestInfo.semester;
    });
  }
}
