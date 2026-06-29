import 'package:flutter/material.dart';

class CalendarHard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
        leading: Icon(Icons.arrow_back),
        actions: [
          Icon(Icons.star),
          Icon(Icons.search),
          Icon(Icons.settings),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('Daily'),
              Text('Calendar'),
              Text('Weekly'),
              Text('Monthly'),
              Text('Total'),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text('Income'),
                  Text('4,831.89'),
                ],
              ),
              Column(
                children: [
                  Text('Expenses'),
                  Text('2,442.93'),
                ],
              ),
              Column(
                children: [
                  Text('Total'),
                  Text('2,388.96'),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 7,
              children: List.generate(42, (index) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text((index + 1).toString()),
                      if (index == 10)
                        Column(
                          children: [
                            SizedBox(height: 8),
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.orange,
                              ),
                            ),
                            SizedBox(height: 4),
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      if (index == 13)
                        Column(
                          children: [
                            SizedBox(height: 8),
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.cyan,
                              ),
                            ),
                            SizedBox(height: 4),
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                              ),
                            ),
                            SizedBox(height: 4),
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.teal,
                              ),
                            ),
                            SizedBox(height: 4),
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.purple,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text('+2'),
                          ],
                        ),
                      if (index == 2)
                        Text('4,586.89'),
                      if (index == 9)
                        Text('190.60'),
                      if (index == 11)
                        Text('60.00'),
                      if (index == 12)
                        Text('54.99'),
                      if (index == 13)
                        Text('86.37'),
                      if (index == 15)
                        Text('67.99'),
                      if (index == 22)
                        Text('245.00'),
                      if (index == 24)
                        Text('391.34'),
                      if (index == 25)
                        Text('0.00'),
                      if (index == 31)
                        Text('8.1'),
                      if (index == 32)
                        Text('0.00'),
                      if (index == 38)
                        Text('34.39'),
                      if (index == 26)
                        Text('1,241.77'),
                      if (index == 13)
                        Text('0.00'),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}