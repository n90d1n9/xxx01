import 'package:shared_preferences/shared_preferences.dart';

import '../models/surah.dart';

class ReciterManagementService {
  static const String _selectedReciterKey = 'selected_reciter';

  static final List<ReciterInfo> _availableReciters = [
    ReciterInfo(
      id: 'ar.alafasy',
      name: 'Mishary Rashid Alafasy',
      style: 'Hafs',
      baseUrl: 'https://cdn.islamic.network/quran/audio/128/ar.alafasy',
      downloadSizeMB: 380.0,
    ),
    ReciterInfo(
      id: 'ar.abdulbasit',
      name: 'Abdul Basit Abdus Samad',
      style: 'Hafs (Mujawwad)',
      baseUrl: 'https://cdn.islamic.network/quran/audio/128/ar.abdulbasit',
      downloadSizeMB: 420.0,
    ),
    ReciterInfo(
      id: 'ar.husary',
      name: 'Mahmoud Khalil Al-Hussary',
      style: 'Hafs',
      baseUrl: 'https://cdn.islamic.network/quran/audio/128/ar.husary',
      downloadSizeMB: 365.0,
    ),
    ReciterInfo(
      id: 'ar.minshawi',
      name: 'Mohamed Siddiq El-Minshawi',
      style: 'Hafs (Mujawwad)',
      baseUrl: 'https://cdn.islamic.network/quran/audio/128/ar.minshawi',
      downloadSizeMB: 410.0,
    ),
    ReciterInfo(
      id: 'ar.shaatree',
      name: 'Abu Bakr al-Shatri',
      style: 'Hafs',
      baseUrl: 'https://cdn.islamic.network/quran/audio/128/ar.shaatree',
      downloadSizeMB: 340.0,
    ),
    ReciterInfo(
      id: 'ar.sudais',
      name: 'Abdur Rahman as-Sudais',
      style: 'Hafs',
      baseUrl:
          'https://cdn.islamic.network/quran/audio/128/ar.abdurrahmansudais',
      downloadSizeMB: 355.0,
    ),
    ReciterInfo(
      id: 'ar.ghamadi',
      name: 'Saad Al-Ghamadi',
      style: 'Hafs',
      baseUrl: 'https://cdn.islamic.network/quran/audio/128/ar.saadalghamadi',
      downloadSizeMB: 345.0,
    ),
  ];

  List<ReciterInfo> getAvailableReciters() {
    return _availableReciters;
  }

  Future<String> getSelectedReciter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedReciterKey) ?? 'ar.alafasy';
  }

  Future<void> selectReciter(String reciterId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedReciterKey, reciterId);
  }

  String getAudioUrl(String reciterId, int surahNumber) {
    final reciter = _availableReciters.firstWhere(
      (r) => r.id == reciterId,
      orElse: () => _availableReciters.first,
    );
    final surahStr = surahNumber.toString().padLeft(3, '0');
    return '${reciter.baseUrl}/$surahStr.mp3';
  }
}
