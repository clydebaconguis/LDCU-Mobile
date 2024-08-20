import 'package:flutter/material.dart';
import '../widgets/menu_button.dart';

class RemedialClassScreen extends StatefulWidget {
  const RemedialClassScreen({super.key});

  @override
  _RemedialClassScreenState createState() => _RemedialClassScreenState();
}

class _RemedialClassScreenState extends State<RemedialClassScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Remedial Class',
          style: TextStyle(
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Center(
              child: Text('Content goes here'),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: CustomFloatingMenu(),
            ),
          ),
        ],
      ),
    );
  }
}
