import 'package:flutter/material.dart';

class FnbLoyaltyWidget extends StatefulWidget {
  const FnbLoyaltyWidget({Key? key}) : super(key: key);

  @override
  State<FnbLoyaltyWidget> createState() => _FnbLoyaltyWidgetState();
}

class _FnbLoyaltyWidgetState extends State<FnbLoyaltyWidget> {
  int _currentStamp = 0;
  int _totalStamps = 10;

  void _collectStamp() {
    setState(() {
      _currentStamp++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FNB Loyalty'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (int i = 1; i <= _totalStamps; i++)
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i <= _currentStamp
                                ? Colors.green
                                : Colors.grey,
                          ),
                          child: Text(
                            i.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        const Text('Stamp'),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _collectStamp,
              child: const Text('Collect Stamp'),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Order Again',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            // ... (Add order history or other relevant content)
          ],
        ),
      ),
    );
  }
}