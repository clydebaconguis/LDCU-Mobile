import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:pushtrial/api/api.dart';
import 'package:pushtrial/models/payments.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pushtrial/models/user.dart';
import 'package:pushtrial/models/user_data.dart';
import 'package:intl/intl.dart';
import 'package:date_field/date_field.dart';

class PaymentForm extends StatefulWidget {
  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  User user = UserData.myUser;
  String? _selectedPaymentType;
  String? _selectedSY;
  String? _selectedSem;
  List<PaymentOptions> _paymentOptions = [];
  List<Bank> _bankOptions = [];
  List<SY> _syOptions = [];
  List<Semester> _semesterOptions = [];
  List<Contact> _contactOptions = [];
  File? _receiptImage;
  int id = 0;
  bool loading = true;

  final List<String> _messageReceiverOptions = [
    'Student',
    'Mother',
    'Father',
    'Guardian',
  ];

  String? getContactNumber(String receiver) {
    if (_contactOptions.isEmpty) return null;

    final contact = _contactOptions.first;
    switch (receiver) {
      case 'Student':
        return contact.contactno;
      case 'Mother':
        return contact.mcontactno;
      case 'Father':
        return contact.fcontactno;
      case 'Guardian':
        return contact.gcontactno;
      default:
        return null;
    }
  }

  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _transactionDateController =
      TextEditingController();
  final TextEditingController _referenceNumberController =
      TextEditingController();
  final TextEditingController _paymentAmountController =
      TextEditingController();
  final TextEditingController _messageReceiverController =
      TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      loading = true;
    });

    await getUser();
    await getOnlinePayments();

    setState(() {
      loading = false;
    });
  }

  Future<void> getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final json = preferences.getString('user');
    user = json == null ? UserData.myUser : User.fromJson(jsonDecode(json));
    print('User data in payment form screen: $user');

    setState(() {
      id = user.id;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _receiptImage = File(pickedFile.path);
      });
    }
  }

  Future<void> getOnlinePayments() async {
    final response = await CallApi().getOnlinePayments(id);
    final Map<String, dynamic> responseData = json.decode(response.body);

    _paymentOptions = (responseData['onlinepaymentoptions'] as List)
        .map((data) => PaymentOptions.fromJson(data))
        .toList();

    _bankOptions = (responseData['bank'] as List)
        .map((data) => Bank.fromJson(data))
        .toList();

    _syOptions =
        (responseData['sy'] as List).map((data) => SY.fromJson(data)).toList();

    _semesterOptions = (responseData['semester'] as List)
        .map((data) => Semester.fromJson(data))
        .toList();

    _contactOptions = (responseData['contact'] as List)
        .map((data) => Contact.fromJson(data))
        .toList();

    if (_paymentOptions.isNotEmpty) {
      _selectedPaymentType = _paymentOptions.first.description;
    }

    if (_syOptions.isNotEmpty && _semesterOptions.isNotEmpty) {
      _selectedSY = _syOptions.first.sydesc;
      _selectedSem = _semesterOptions.first.semester;
    }

    setState(() {});

    print('Filtered Payment Options: $_paymentOptions');
    print('Bank Names: $_bankOptions');
    print('School Years: $_syOptions');
    print('Semesters: $_semesterOptions');
    print('Contacts: $_contactOptions');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Payment Form',
            style: TextStyle(fontFamily: 'Poppins')),
      ),
      body: loading
          ? Center(
              child: LoadingAnimationWidget.prograssiveDots(
                color: const Color.fromARGB(255, 109, 17, 10),
                size: 100,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(30),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField2<String>(
                            value: _selectedSY,
                            items: _syOptions
                                .map((option) => DropdownMenuItem(
                                      child: Text(
                                        option.sydesc,
                                        style: TextStyle(fontSize: 10),
                                      ),
                                      value: option.sydesc,
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPaymentType = value!;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Enrollment',
                              labelStyle: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField2<String>(
                            value: _selectedSem,
                            items: _semesterOptions
                                .map((option) => DropdownMenuItem(
                                      child: Text(
                                        option.semester,
                                        style: TextStyle(fontSize: 10),
                                      ),
                                      value: option.semester,
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPaymentType = value!;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Semester',
                              labelStyle: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField2<String>(
                      value: _selectedPaymentType,
                      items: _paymentOptions
                          .map((option) => DropdownMenuItem(
                                child: Text(
                                  option.description,
                                  style: TextStyle(fontSize: 12),
                                ),
                                value: option.description,
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentType = value!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Payment Type',
                        labelStyle: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Icon(Icons.payments),
                        border: OutlineInputBorder(),
                      ),
                      buttonStyleData: const ButtonStyleData(
                        height: 20,
                      ),
                    ),
                    SizedBox(height: 12),
                    if (_selectedPaymentType == 'BANK') ...[
                      DropdownButtonFormField2<String>(
                        items: _bankOptions
                            .map((option) => DropdownMenuItem(
                                  child: Text(option.optionDescription,
                                      style: TextStyle(
                                        fontSize: 12,
                                      )),
                                  value: option.optionDescription,
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _bankNameController.text = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Bank Name',
                          labelStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon:
                              Icon(Icons.account_balance, color: Colors.grey),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Bank Transaction Date',
                          hintText: "MM/DD/YYYY",
                          labelStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon:
                              Icon(Icons.date_range, color: Colors.grey),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    GestureDetector(
                      onTap: _pickImage,
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Receipt Image',
                            labelStyle: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            prefixIcon:
                                const Icon(Icons.image, color: Colors.grey),
                            border: const OutlineInputBorder(),
                            suffixIcon: _receiptImage != null
                                ? Image.file(
                                    _receiptImage!,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Reference Number',
                        labelStyle: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Icon(Icons.numbers, color: Colors.grey),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Payment Amount',
                        labelStyle: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Icon(Icons.money, color: Colors.grey),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField2<String>(
                      items: _messageReceiverOptions
                          .map((option) => DropdownMenuItem(
                                child: Text(
                                  option,
                                  style: TextStyle(fontSize: 12),
                                ),
                                value: option,
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _messageReceiverController.text = value!;
                          _contactNumberController.text =
                              getContactNumber(value)!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Message Receiver',
                        labelStyle: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Icon(Icons.message, color: Colors.grey),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _contactNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Number',
                        labelStyle: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Icon(Icons.phone, color: Colors.grey),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text(
                          'Submit Payment',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 109, 17, 10),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
