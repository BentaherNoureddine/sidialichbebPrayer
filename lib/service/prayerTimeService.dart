import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sidialichbeb/model/prayerTime.dart';
import 'package:sidialichbeb/service/MuslimSalatApiService.dart';
import 'package:sidialichbeb/utils/helper/helper.dart';






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

    for(int i=0;i<10;i++){
    print(prayerTimes.dateFor);
    print("\n");
    print(prayerTimes.fajr);
    print("\n");
    print(prayerTimes.shurooq);
    print("\n");
    print(prayerTimes.dhuhr);
    print("\n");
    print(prayerTimes.asr);
    print("\n");
    print(prayerTimes.asr);
    }
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


  Future<void> launchPrayerTimeData() async {
    try {
      PrayerTime? prayerTime = await MuslimSalatApiService().fetchPrayerData();

      print(prayerTime);

      if (prayerTime != null) {

        prayerTime = PrayerTime(
          prayerTime.dateFor,
          prayerTime.fajr,
          prayerTime.shurooq,
          prayerTime.dhuhr,
          prayerTime.asr,
         prayerTime.maghrib,
          prayerTime.isha,
        );

        print(prayerTime);
        print(prayerTime);

        await savePrayerTimesToSharedPref(prayerTime);
      }
    } catch (e) {
      print("Error occurred");
    }
  }





  String getNextPrayer(PrayerTime prayerTime) {
    final now = DateTime.now();
    final today = DateFormat('yyyy-M-d').format(now);



    final times = {
      'Fajr': helper().parseTime(today,prayerTime.fajr),
      'Shurooq': helper().parseTime(today,prayerTime.shurooq),
      'Dhuhr': helper().parseTime(today,prayerTime.dhuhr),
      'Asr': helper().parseTime(today,prayerTime.asr),
      'Maghrib': helper().parseTime(today,prayerTime.maghrib),
      'Isha': helper().parseTime(today,prayerTime.isha),
    };

    for (final entry in times.entries) {
      if (now.isBefore(entry.value)) {
        return entry.key;
      }
    }

    // If all today's prayers passed, Fajr is the next one tomorrow
    return 'Fajr (tomorrow)';
  }




}
