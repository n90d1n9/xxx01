enum Prayer { fajr, sunrise, dhuhr, asr, maghrib, isha }

class PrayerTimes {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final DateTime date;

  PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
  });

  Prayer getNextPrayer() {
    final now = DateTime.now();
    if (now.isBefore(fajr)) return Prayer.fajr;
    if (now.isBefore(sunrise)) return Prayer.sunrise;
    if (now.isBefore(dhuhr)) return Prayer.dhuhr;
    if (now.isBefore(asr)) return Prayer.asr;
    if (now.isBefore(maghrib)) return Prayer.maghrib;
    if (now.isBefore(isha)) return Prayer.isha;
    return Prayer.fajr;
  }

  DateTime getTimeForPrayer(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return fajr;
      case Prayer.sunrise:
        return sunrise;
      case Prayer.dhuhr:
        return dhuhr;
      case Prayer.asr:
        return asr;
      case Prayer.maghrib:
        return maghrib;
      case Prayer.isha:
        return isha;
    }
  }

  Duration getTimeUntilNext() {
    final next = getNextPrayer();
    final nextTime = getTimeForPrayer(next);
    return nextTime.difference(DateTime.now());
  }

  Map<String, dynamic> toJson() => {
    'fajr': fajr.toIso8601String(),
    'sunrise': sunrise.toIso8601String(),
    'dhuhr': dhuhr.toIso8601String(),
    'asr': asr.toIso8601String(),
    'maghrib': maghrib.toIso8601String(),
    'isha': isha.toIso8601String(),
    'date': date.toIso8601String(),
  };

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    return PrayerTimes(
      fajr: DateTime.parse(json['fajr']),
      sunrise: DateTime.parse(json['sunrise']),
      dhuhr: DateTime.parse(json['dhuhr']),
      asr: DateTime.parse(json['asr']),
      maghrib: DateTime.parse(json['maghrib']),
      isha: DateTime.parse(json['isha']),
      date: DateTime.parse(json['date']),
    );
  }
}
