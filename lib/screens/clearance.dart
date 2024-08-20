import 'package:flutter/material.dart';

class ClearanceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Clearance',
          style: TextStyle(
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ClearanceScreen(),
  ));
}
