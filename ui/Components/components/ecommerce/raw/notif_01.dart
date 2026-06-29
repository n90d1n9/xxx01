/* import 'package:flutter/material.dart';

import 'notif_services.dart';

class NotifSample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification contoh'),
      ),
      body: Column( children: [
        TextButton(onPressed: (){print('ini contoh');}, child: Text('ini contoh')),
      Center(
        child: ElevatedButton(
          onPressed: () {
            print('notiiiif...');
            NotificationService().showNotification(
              0,
              'Test Notification',
              'This is a test notification',
            );
            
          },
          child: Text('coba Notification'),
        ),
      ),
      ])
    );
  }
}
 */