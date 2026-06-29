import '../models/station.dart';

class StreamQualityManager {
  final List<String> _qualityLevels = ['low', 'medium', 'high'];
  String _currentQuality = 'medium';

  String get currentQuality => _currentQuality;
  List<String> get qualityLevels => _qualityLevels;

  String getOptimizedStreamUrl(Station station, String quality) {
    // Logic to select appropriate stream based on quality
    switch (quality) {
      case 'low':
        return station.streamUrls.first;
      case 'medium':
        return station.streamUrls[station.streamUrls.length ~/ 2];
      case 'high':
        return station.streamUrls.last;
      default:
        return station.streamUrls[station.streamUrls.length ~/ 2];
    }
  }

  void setQuality(String quality) {
    if (_qualityLevels.contains(quality)) {
      _currentQuality = quality;
    }
  }
}
