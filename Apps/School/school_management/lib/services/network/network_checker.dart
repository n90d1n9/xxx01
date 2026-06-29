import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkChecker {
  Future<bool> hasConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }
}


