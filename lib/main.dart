import 'package:flutter/material.dart';
import 'package:sidialichbeb/pages/prayerTimePage.dart';
import 'package:sidialichbeb/service/prayerTimeService.dart';


Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await PrayerTimeService().launchPrayerTimeData();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sidi Ali Chebeb',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PrayerTimePage(),
    );
  }
}

