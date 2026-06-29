import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trendy Sliver Header',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const SliverHeaderDemo(),
    );
  }
}

class SliverHeaderDemo extends StatelessWidget {
  const SliverHeaderDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            snap: true,
            floating: true,
            elevation: 10,
            backgroundColor: Colors.black,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                // Calculate percentage of scroll
                var percent = ((constraints.maxHeight - kToolbarHeight) /
                        (300 - kToolbarHeight))
                    .clamp(0.0, 1.0);

                return FlexibleSpaceBar(
                  title: Opacity(
                    opacity: 1.0 - percent,
                    child: const Text("Sliver Header"),
                  ),
                  centerTitle: true,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://images.unsplash.com/photo-1557683316-973673baf926?auto=format&fit=crop&w=1950&q=80',
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(title: Text("Item #$index")),
              childCount: 30,
            ),
          ),
        ],
      ),
    );
  }
}
