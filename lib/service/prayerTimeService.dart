import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sidialichbeb/model/prayerTime.dart';
import 'package:sidialichbeb/service/MuslimSalatApiService.dart';
import 'package:sidialichbeb/utils/helper/helper.dart';





class PrayerTimeService {

  final helper = Helper();


  Future<void> savePrayerTimesToSharedPref(PrayerTime prayerTimes) async {
    final prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.setString('date_for', prayerTimes.dateFor),
      prefs.setString('fajr',helper.formatTimeTo24Hour(prayerTimes.fajr)),
      prefs.setString('shurooq',helper.formatTimeTo24Hour(prayerTimes.shurooq)),
      prefs.setString('dhuhr', helper.formatTimeTo24Hour(prayerTimes.dhuhr)),
      prefs.setString('asr', helper.formatTimeTo24Hour(prayerTimes.asr)),
      prefs.setString('maghrib', helper.formatTimeTo24Hour(prayerTimes.maghrib)),
      prefs.setString('isha', helper.formatTimeTo24Hour(prayerTimes.isha)),
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


  Future<void> launchPrayerTimeData() async {
    try {
      PrayerTime? prayerTime = await MuslimSalatApiService().fetchPrayerData();

      print(prayerTime);
      for(int i=0 ;i<10; i++){
        print("prayer time data : ");
        print(prayerTime?.asr);

      }
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
      'fajr': helper.parseTime(today,prayerTime.fajr),
      'dhuhr': helper.parseTime(today,prayerTime.dhuhr),
      'asr': helper.parseTime(today,prayerTime.asr),
      'maghrib': helper.parseTime(today,prayerTime.maghrib),
      'isha': helper.parseTime(today,prayerTime.isha),
    };


    print(helper.parseTime(today,prayerTime.asr));

    for (final entry in times.entries) {
      if (now.isBefore(entry.value)) {

        return entry.key;
      }
    }

    // If all today's prayers passed, Fajr is the next one tomorrow
    return 'Fajr';
  }




}
