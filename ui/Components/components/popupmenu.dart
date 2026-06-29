import 'package:flutter/material.dart';

class Popupmenu extends StatelessWidget {
  const Popupmenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Expanded(
        flex: 1,
          child: ListView(
        children: <Widget>[
          // Create a ListView with a list of items, each having a PopupMenuButton
          for (int i = 1; i <= 5; i++)
            ListTile(
              title: Text("List Item $i"),
              trailing: PopupMenuButton<int>(
                onSelected: (value) {
                  // Handle the selection from the PopupMenuButton
                  if (value == 0) {
                    _showSnackbar(context, "Option 1 selected");
                  } else if (value == 1) {
                    _showSnackbar(context, "Option 2 selected");
                  }
                },
                itemBuilder: (BuildContext context) {
                  // Define the menu items for the PopupMenuButton
                  return <PopupMenuEntry<int>>[
                    const PopupMenuItem<int>(
                      value: 0,
                      child: Text("Option 1"),
                    ),
                    const PopupMenuItem<int>(
                      value: 1,
                      child: Text("Option 2"),
                    ),
                  ];
                },
              ),
            ),
        ],
      ))
    ]);
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
