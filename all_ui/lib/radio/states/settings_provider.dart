import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RadioSettingsProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _autoPlayNextStream = true;
  bool _saveDataMode = false;
  String _preferredCategory = 'All';

  RadioSettingsProvider() {
    _initializeSettings();
  }

  bool get autoPlayNextStream => _autoPlayNextStream;
  bool get saveDataMode => _saveDataMode;
  String get preferredCategory => _preferredCategory;

  Future<void> _initializeSettings() async {
    _prefs = await SharedPreferences.getInstance();

    _autoPlayNextStream = _prefs.getBool('autoPlayNextStream') ?? true;
    _saveDataMode = _prefs.getBool('saveDataMode') ?? false;
    _preferredCategory = _prefs.getString('preferredCategory') ?? 'All';

    notifyListeners();
  }

  void setAutoPlayNextStream(bool value) {
    _autoPlayNextStream = value;
    _prefs.setBool('autoPlayNextStream', value);
    notifyListeners();
  }

  void setSaveDataMode(bool value) {
    _saveDataMode = value;
    _prefs.setBool('saveDataMode', value);
    notifyListeners();
  }

  void setPreferredCategory(String category) {
    _preferredCategory = category;
    _prefs.setString('preferredCategory', category);
    notifyListeners();
  }
}
