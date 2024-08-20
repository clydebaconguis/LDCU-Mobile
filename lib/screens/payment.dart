import 'package:flutter/material.dart';
import 'payment_form.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:pushtrial/models/transactions.dart';
import 'package:pushtrial/api/api.dart';
import 'package:intl/intl.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});
  @override
  State<PaymentPage> createState() => PaymentPageState();
}

class PaymentPageState extends State<PaymentPage> {
  String id = '0';
  String amountpaid = '0.00';
  List<Transactions> trans = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await getUser();
    getTransactions();
  }

  Future<void> getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('studid');

    print(json);

    if (json != null) {
      setState(() {
        id = json;
      });
    }
    setState(() {});
  }

  getTransactions() async {
    final response = await CallApi().getTransactions(id);
    // print('Student ID: $id');
    // print('Request URL: ${response.request?.url}');

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        print('No Transactions found');
        return;
      }

      try {
        Iterable list = json.decode(response.body);

        setState(() {
          trans = list.map((model) => Transactions.fromJson(model)).toList();
        });
        print('Retrieved transactions: $trans');
      } catch (e) {
        print('Error parsing JSON: $e');
      }
    } else {
      print(
          'Failed to retrieve transactions. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
      ),
      body: DefaultTabController(
        length: 2,
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
                    color: const Color.fromARGB(255, 109, 17, 10),
                  ),
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: Color.fromARGB(255, 219, 154, 149),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.white,
                    tabs: [
                      Tab(text: 'Uploaded Payment'),
                      Tab(text: 'Transactions'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: TabBarView(
            children: [
              _buildUploadedPaymentTab(),
              _buildTransactionsTab(),
            ],
          ),
          floatingActionButton: ClipOval(
            child: Material(
              color: Color.fromARGB(255, 109, 17, 10),
              child: InkWell(
                splashColor: const Color.fromARGB(255, 109, 17, 10),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PaymentForm()),
                  );
                },
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadedPaymentTab() {
    return Center(
      child: Text('Uploaded Payment Content', style: TextStyle(fontSize: 18)),
    );
  }

  Widget _buildTransactionsTab() {
    final dateFormat = DateFormat('MMMM d, yyyy HH:mm:ss');
    final amountFormat = NumberFormat('#,##0.00', 'en_US');
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView.builder(
        itemCount: trans.length,
        itemBuilder: (context, index) {
          final transaction = trans[index];
          final formattedDate =
              dateFormat.format(DateTime.parse(transaction.transdate));
          final double amountPaid = double.parse(transaction.amountpaid);
          final formattedAmount = amountFormat.format(amountPaid);

          return Card(
            margin: const EdgeInsets.all(5.0),
            elevation: 10.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Container(
              color: const Color.fromARGB(255, 14, 19, 29),
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${transaction.paytype} - OR#: ${transaction.ornum}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedDate,
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Php $formattedAmount',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
