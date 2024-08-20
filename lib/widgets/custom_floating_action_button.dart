import 'package:flutter/material.dart';

class CustomFloatingMenu extends StatefulWidget {
  @override
  _CustomFloatingMenuState createState() => _CustomFloatingMenuState();
}

class _CustomFloatingMenuState extends State<CustomFloatingMenu> {
  bool _isMenuOpen = false;

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  void _handleMenuAction(String label) {
    Navigator.pop(context); // Close the menu
    if (label == 'Scholarship Request') {
      // Handle Scholarship Request action
    } else if (label == 'School Calendar') {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => SchoolCalendar()),
      // );
    } else if (label == 'Clearance') {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => ClearanceScreen()),
      // );
    } else if (label == 'Enrollment') {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => EnrollmentScreen()),
      // );
    } else if (label == 'Payment') {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => PaymentPage()),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isMenuOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleMenu,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    width: MediaQuery.of(context).size.width *
                        0.7, // Adjust width as needed
                    height: 350,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildMenuRow(
                          iconData: [
                            Icons.school,
                            Icons.assessment,
                            Icons.calendar_today,
                          ],
                          labels: [
                            'Scholarship Request',
                            'Teacher Evaluation',
                            'School Calendar',
                          ],
                        ),
                        SizedBox(height: 16.0),
                        _buildMenuRow(
                          iconData: [
                            Icons.check_circle,
                            Icons.subscriptions,
                            Icons.payments,
                          ],
                          labels: [
                            'Clearance',
                            'Enrollment',
                            'Payment',
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 16,
          right: 16, // Move button to the right
          child: FloatingActionButton(
            onPressed: _toggleMenu,
            child: Icon(
              _isMenuOpen ? Icons.close : Icons.menu,
              color: Colors.white,
            ),
            backgroundColor: Color.fromARGB(255, 109, 17, 10),
            shape: CircleBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuRow({
    required List<IconData> iconData,
    required List<String> labels,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(iconData.length, (index) {
        return GestureDetector(
          onTap: () => _handleMenuAction(labels[index]),
          child: Column(
            children: [
              CircleAvatar(
                radius: 30.0,
                backgroundColor: Color.fromARGB(255, 109, 17, 10),
                child: Icon(
                  iconData[index],
                  color: Colors.white,
                  size: 30.0,
                ),
              ),
              SizedBox(height: 8.0),
              Container(
                constraints: BoxConstraints(maxWidth: 80.0),
                child: Text(
                  labels[index],
                  style: TextStyle(
                    fontSize: 12.0,
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
