import 'package:flutter/material.dart';

class PickupWidget extends StatelessWidget {
  const PickupWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Pick up at?'),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_pin),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              child: Image.asset('assets/map.png'),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TripleOne Somerset',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '111 Somerset Road, Singapore, 238164',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 16),
                  _PickupLocation(
                    title: 'Somerset Rd Entrance',
                    distance: '0.0km',
                  ),
                  SizedBox(height: 16),
                  _PickupLocation(
                    title: 'Exeter Rd Entrance',
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Add pickup details (e.g. near the gate)',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 32,
                      ),
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Text('Choose This Pickup'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickupLocation extends StatelessWidget {
  final String title;
  final String? distance;

  const _PickupLocation({
    Key? key,
    required this.title,
    this.distance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.location_pin),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              if (distance != null)
                Text(
                  distance!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.more_vert),
          onPressed: () {},
        ),
      ],
    );
  }
}