import 'package:flutter/material.dart';

class PosFooter extends StatelessWidget {
  const PosFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
       // height: 100,
        color: Colors.black12,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
  
            const BackButton(),
            
            const CloseButton(),
            
                ElevatedButton.icon(
                onPressed: () => print(''),
                icon: const Icon(Icons.data_object),
                label: const Text('Calculator')),
                ElevatedButton.icon(
                onPressed: () => print(''),
                icon: const Icon(Icons.data_exploration),
                label: const Text('Calculator')),
           
            ElevatedButton.icon(
                onPressed: () => print(''),
                icon: const Icon(Icons.search),
                label: const Text('Stock'))
          ],
        ));
  }
}
