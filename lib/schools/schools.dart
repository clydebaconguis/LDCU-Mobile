import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class SchoolScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SCHOOLS',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SchoolScreen(),
  ));
}
