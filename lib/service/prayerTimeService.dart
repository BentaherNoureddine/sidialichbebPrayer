import 'package:shared_preferences/shared_preferences.dart';
import 'package:sidialichbeb/model/prayerTime.dart';





class PrayerTimeService {


  Future<void> savePrayerTimesToSharedPref(PrayerTime prayerTimes) async {
    final prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.setString('date_for', prayerTimes.dateFor),
      prefs.setString('fajr', prayerTimes.fajr),
      prefs.setString('shurooq', prayerTimes.shurooq),
      prefs.setString('dhuhr', prayerTimes.dhuhr),
      prefs.setString('asr', prayerTimes.asr),
      prefs.setString('maghrib', prayerTimes.maghrib),
      prefs.setString('isha', prayerTimes.isha),
    ]);
  }


  Future<PrayerTime?> getPrayerTimesFromSharedPref() async {
    final prefs = await SharedPreferences.getInstance();


    try {
      final dateFor = prefs.getString('date_for');
      final fajr = prefs.getString('fajr');
      final shurooq = prefs.getString('shurooq');
      final dhuhr = prefs.getString('dhuhr');
      final asr = prefs.getString('asr');
      final maghrib = prefs.getString('maghrib');
      final isha = prefs.getString('isha');

      // Check if any value is missing
      if ([dateFor, fajr, shurooq, dhuhr, asr, maghrib, isha].contains(null)) {
        return null;
      }

      return PrayerTime(
        dateFor!,
        fajr!,
        shurooq!,
        dhuhr!,
        asr!,
        maghrib!,
        isha!,
      );
    } catch (e) {
      print("failed to load data from shared preferences");
    }
    return null;
  }

}
