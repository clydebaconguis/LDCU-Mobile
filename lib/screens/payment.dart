import 'package:flutter/material.dart';
import 'payment_form.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:pushtrial/models/transactions.dart';
import 'package:pushtrial/api/api.dart';
import 'package:intl/intl.dart';
import 'package:pushtrial/models/user.dart';
import 'package:pushtrial/models/user_data.dart';
import 'package:pushtrial/models/onlinepayments.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});
  @override
  State<PaymentPage> createState() => PaymentPageState();
}

class PaymentPageState extends State<PaymentPage> {
  User user = UserData.myUser;
  int id = 0;
  String sid = '0';
  String amountpaid = '0.00';
  List<Transactions> trans = [];
  List<Payments> payments = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await getUser();
    getTransactions();
    getOnlinePayments();
  }

  Future<void> getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('user');
    user = json == null ? UserData.myUser : User.fromJson(jsonDecode(json));
    print('User data in payment section screen: $user');

    setState(() {
      id = user.id;
      sid = user.sid!;
    });
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
        // print('Retrieved transactions: $trans');
      } catch (e) {
        print('Error parsing JSON: $e');
      }
    } else {
      print(
          'Failed to retrieve transactions. Status code: ${response.statusCode}');
    }
  }

  getOnlinePayments() async {
    final response = await CallApi().getOnlinePayments(sid);

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        print('No data returned');
        return;
      }
      Iterable list = json.decode(response.body);
      setState(() {
        payments = list.map((model) => Payments.fromJson(model)).toList();
      });

      payments.forEach((payment) {
        // print('Payment ID: ${payment.id}, Status: ${payment.getStatus()}');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PAYMENT',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
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
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Color.fromARGB(255, 133, 13, 22),
                  ),
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.white,
                    labelStyle: TextStyle(fontSize: 12),
                    tabs: const [
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
              color: const Color.fromARGB(255, 133, 13, 22),
              child: InkWell(
                splashColor: const Color.fromARGB(255, 133, 13, 22),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PaymentForm()),
                  );
                },
                child: const SizedBox(
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
    final dateFormat = DateFormat('MMMM d, yyyy');
    final amountFormat = NumberFormat('#,##0.00', 'en_US');

    // Sort payments by date in descending order
    payments.sort((a, b) =>
        DateTime.parse(b.paymentDate).compareTo(DateTime.parse(a.paymentDate)));

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView.builder(
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final payment = payments[index];
          final formattedDate =
              dateFormat.format(DateTime.parse(payment.paymentDate));
          final double amountPaid = double.parse(payment.amount);
          final formattedAmount = amountFormat.format(amountPaid);

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 133, 13, 22),
                  Color.fromARGB(255, 14, 19, 29),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(15.0),
            ),
            margin: const EdgeInsets.all(5.0),
            child: Card(
              color: Colors.transparent,
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Container(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          payment.description,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          'RN: ${payment.refNum}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    // const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formattedDate,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                        Text(
                          'Php $formattedAmount',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          '(${payment.getStatus()})',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionsTab() {
    final dateFormat = DateFormat('MMMM d, yyyy h:mm a');
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
            color: const Color.fromARGB(255, 14, 19, 29),
            margin: const EdgeInsets.all(5.0),
            elevation: 10.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Container(
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
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        'Php $formattedAmount',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
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
