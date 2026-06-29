import 'package:flutter/material.dart';

class Absensi01 extends StatelessWidget {
  const Absensi01({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        leading: const Icon(Icons.arrow_back),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Me'),
                      const Text('Your Subordinate'),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 24.0,
                            backgroundImage: NetworkImage('https://picsum.photos/200/300'),
                          ),
                          const SizedBox(height: 8.0),
                          const Text('Paolo'),
                        ],
                      ),
                      Row(
                        children: [
                          Column(
                            children: [
                              CircleAvatar(
                                radius: 24.0,
                                backgroundImage: NetworkImage('https://picsum.photos/200/300'),
                              ),
                              const SizedBox(height: 8.0),
                              const Text('Albert'),
                            ],
                          ),
                          const SizedBox(width: 16.0),
                          Column(
                            children: [
                              CircleAvatar(
                                radius: 24.0,
                                backgroundImage: NetworkImage('https://picsum.photos/200/300'),
                              ),
                              const SizedBox(height: 8.0),
                              const Text('Bessie'),
                            ],
                          ),
                          const SizedBox(width: 16.0),
                          Column(
                            children: [
                              CircleAvatar(
                                radius: 24.0,
                                backgroundImage: NetworkImage('https://picsum.photos/200/300'),
                              ),
                              const SizedBox(height: 8.0),
                              const Text('Jean'),
                            ],
                          ),
                          const SizedBox(width: 16.0),
                          Column(
                            children: [
                              CircleAvatar(
                                radius: 24.0,
                                backgroundImage: NetworkImage('https://picsum.photos/200/300'),
                              ),
                              const SizedBox(height: 8.0),
                              const Text('Marie'),
                            ],
                          ),
                          const SizedBox(width: 16.0),
                          Column(
                            children: [
                              CircleAvatar(
                                radius: 24.0,
                                backgroundImage: NetworkImage('https://picsum.photos/200/300'),
                              ),
                              const SizedBox(height: 8.0),
                              const Text('Vienna'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Feb 2022'),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.calendar_today),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.arrow_back_ios),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.arrow_forward_ios),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('SUN'),
                      const Text('MON'),
                      const Text('TUE'),
                      const Text('WED'),
                      const Text('THU'),
                      const Text('FRI'),
                      const Text('SAT'),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                        ),
                        child: const Center(
                          child: Text('13'),
                        ),
                      ),
                      Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                        ),
                        child: const Center(
                          child: Text('14'),
                        ),
                      ),
                      Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                        ),
                        child: const Center(
                          child: Text('15'),
                        ),
                      ),
                      Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.lightBlue[200],
                        ),
                        child: const Center(
                          child: Text('16'),
                        ),
                      ),
                      Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                        ),
                        child: const Center(
                          child: Text('17'),
                        ),
                      ),
                      Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                        ),
                        child: const Center(
                          child: Text('18'),
                        ),
                      ),
                      Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                        ),
                        child: const Center(
                          child: Text('19'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[200],
                    ),
                    child: const Text('Activity Record'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Tracking'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Patrol'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Timesheet'),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.circle),
                    title: const Text('Create a micro business'),
                    subtitle: const Text('Record Activity'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Offline'),
                        const Icon(Icons.error),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.circle),
                    title: const Text('Create a micro business planning'),
                    subtitle: const Text('Record Activity'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Offline'),
                        const Icon(Icons.error),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.circle),
                    title: const Text('Create a micro business planning'),
                    subtitle: const Text('Record Activity'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Offline'),
                        const Icon(Icons.error),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Failed to send your attendance',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'There seems to be a problem with the network. Click the Resend button to try again. If you see that everything is not OK, please report to us via email.',
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Send from Email'),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Resend All'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}