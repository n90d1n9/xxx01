import 'package:flutter/material.dart';

class LoyaltyProgramWidget extends StatefulWidget {
  const LoyaltyProgramWidget({Key? key}) : super(key: key);

  @override
  State<LoyaltyProgramWidget> createState() => _LoyaltyProgramWidgetState();
}

class _LoyaltyProgramWidgetState extends State<LoyaltyProgramWidget> {
  int _starBalance = 400;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Good Morning, Fendy'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.person),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.mail),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.local_offer),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$_starBalance',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(Icons.star, size: 32),
            const SizedBox(height: 8),
            const Text('Star balance'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Details'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Redeem'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  // Reward card
                  Card(
                    child: Column(
                      children: [
                        Image.asset('assets/images/reward_card.png'),
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'More choices of rewards for everyone, however you pay',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Exclusive perks card
                  Card(
                    child: Column(
                      children: [
                        Image.asset('assets/images/exclusive_perks.png'),
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Get Exclusive Perks',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Enjoy a delicious Birthday Treat. VIP Access to pre-sale and other exclusive perks.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('Pay'),
                        ),
                      ],
                    ),
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