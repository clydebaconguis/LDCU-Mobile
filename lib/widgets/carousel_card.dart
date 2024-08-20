import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CarouselCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> cardData = [
      {
        'title': 'Enrollment Information',
        'description': 'ID No.:\nGrade Level:\nSection:\nAdviser:',
      },
      {
        'title': 'Current Class',
        'description':
            'Information about your current class, including schedules and assignments.',
      },
      {
        'title': 'Next Class',
        'description':
            'Details about your next class, including time and location.',
      },
      {
        'title': 'Calendar Activities',
        'description': 'Upcoming activities and events on your calendar.',
      },
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 150.0),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 200,
          // autoPlay: true,
          // autoPlayInterval: Duration(seconds: 3),
          // autoPlayAnimationDuration: Duration(milliseconds: 800),
          enlargeCenterPage: true,
          aspectRatio: 16 / 9,
          viewportFraction: 0.8,
        ),
        items: cardData
            .map((data) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: const Color.fromARGB(255, 14, 19, 29),
                  ),
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                data['title']!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              data['description']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}
