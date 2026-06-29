import 'package:flutter/material.dart';

class MyAboutTile extends StatelessWidget {
  final Color appIconColor;
  final Color logoColor;
  final String appName;
  final String title;
  final String subtitle;

  MyAboutTile({this.appIconColor=Colors.amber, 
  this.logoColor=Colors.blue,this.appName,this.subtitle,this.title
  });

  @override
  Widget build(BuildContext context) {
    return AboutListTile(
      applicationIcon: FlutterLogo(
        textColor: appIconColor
      ),
      icon: FlutterLogo(
        textColor: logoColor,
      ),
      aboutBoxChildren: <Widget>[
        SizedBox(
          height: 10.0,
        ),
        Text(title,),
        Text(subtitle,),
      ],
      applicationName: appName,
      applicationVersion: "1.0.1",
      applicationLegalese: "Apache License 2.0",
    );
  }
}
