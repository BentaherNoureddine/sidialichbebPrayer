class PrayerTime {
  final String dateFor;
  final String fajr;
  final String shurooq;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  PrayerTime(
      this.dateFor,
      this.fajr,
      this.shurooq,
      this.dhuhr,
      this.asr,
      this.maghrib,
      this.isha,
      );

  factory PrayerTime.fromJson(Map<String, dynamic> json) {
    return PrayerTime(
      json['date_for'] ?? '',
      json['fajr'] ?? '',
      json['shurooq'] ?? '',
      json['dhuhr'] ?? '',
      json['asr'] ?? '',
      json['maghrib'] ?? '',
      json['isha'] ?? '',
    );
  }
}
