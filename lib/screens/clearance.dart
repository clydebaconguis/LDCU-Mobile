import 'package:flutter/material.dart';

class ClearanceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CLEARANCE',
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
    home: ClearanceScreen(),
  ));
}
