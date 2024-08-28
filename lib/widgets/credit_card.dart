import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pushtrial/api/api.dart';
import 'package:pushtrial/models/enrollment_info.dart';
import 'package:pushtrial/models/ledger.dart';
import 'dart:convert';

class CreditCard extends StatefulWidget {
  const CreditCard({super.key});

  @override
  State<CreditCard> createState() => _CreditCardState();
}

class _CreditCardState extends State<CreditCard> {
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

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                color: const Color.fromARGB(255, 14, 19, 29),
                child: Stack(
                  children: [
                    const Positioned(
                      top: 16,
                      left: 16,
                      child: Row(
                        children: [
                          Icon(Icons.credit_card,
                              size: 30, color: Colors.white),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Text(
                        "SY: $syDesc",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    const Positioned(
                      bottom: 16,
                      left: 16,
                      child: Text(
                        "Total Balance",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: const Color.fromARGB(255, 133, 13, 22),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        totalBalance,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white.withOpacity(0.8),
                          ),
                          const SizedBox(width: 10),
                          CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white.withOpacity(0.8),
                          ),
                        ],
                      ),
                    ],
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
      });
      getEnrollment();
    }
  }

  Future<void> getLedger() async {
    await CallApi().getStudLedger(id, syid, semid).then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        data = list.map((model) => Ledger.fromJson(model)).toList();

        Ledger? totalLedger = data.firstWhere(
          (item) => item.particulars.startsWith('TOTAL:'),
        );

        totalBalance = 'Php ${totalLedger.balance}';
      });
    });
  }

  Future<void> getEnrollment() async {
    await CallApi().getEnrollmentInfo(id).then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        enInfoData =
            list.map((model) => EnrollmentInfo.fromJson(model)).toList();

        years = enInfoData.map((e) => e.sydesc).toSet().toList();
        selectedYear = enInfoData.last.sydesc;

        var latestInfo =
            enInfoData.firstWhere((element) => element.sydesc == selectedYear);
        syid = latestInfo.syid;
        semid = latestInfo.semid;

        syDesc = selectedYear;
        getLedger();
      });
    });
  }
}
