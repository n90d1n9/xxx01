import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  AboutPage({Key? key}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String appName = "";
  String packageName = "";
  String version = "";
  String buildNumber = "";

  @override
  void initState() {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      appName = packageInfo.appName;
      packageName = packageInfo.packageName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('About Page'),
        ),
        body: Column(children: [
          Center(
              child: Column(children: [
            Text("Apps Name: " + appName),
            Text("Package Name: " + packageName),
            Text("Version: " + version),
            Text("Build Number: " + buildNumber),
          ])),
         Expanded(child: 
          const Drawer(
            surfaceTintColor: Colors.blue,
        backgroundColor:
            Colors.amber,
        width: 200,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Side menu header
              DrawerHeader(
                child: Center(
                    child: Column(children: [
                  
                 
                ])),
              ),
Text('-------')
              // Menu list
              
            ],
          ),
        ))),
        ]));
  }
}
