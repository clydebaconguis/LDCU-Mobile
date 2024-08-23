import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PaymentForm extends StatefulWidget {
  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  String _selectedPaymentType = 'bank';
  File? _receiptImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _receiptImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Payment Form',
            style: TextStyle(fontFamily: 'Poppins')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField2<String>(
                value: _selectedPaymentType,
                items: [
                  DropdownMenuItem(child: Text('Bank'), value: 'bank'),
                  DropdownMenuItem(child: Text('GCash'), value: 'gcash'),
                  DropdownMenuItem(child: Text('Palawan'), value: 'palawan'),
                ],
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
                  height: 40,
                  padding: EdgeInsets.only(left: 14, right: 14),
                ),
                dropdownStyleData: const DropdownStyleData(
                  maxHeight: 200,
                ),
              ),
              SizedBox(height: 12),
              if (_selectedPaymentType == 'bank') ...[
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Bank Name',
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: Icon(Icons.account_balance, color: Colors.grey),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Bank Transaction Date',
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: Icon(Icons.date_range, color: Colors.grey),
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
                      prefixIcon: const Icon(Icons.image, color: Colors.grey),
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
              TextFormField(
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
                    backgroundColor: const Color.fromARGB(255, 109, 17, 10),
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
