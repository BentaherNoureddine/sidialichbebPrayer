import 'package:flutter/material.dart';
import 'package:sidialichbeb/model/prayerTime.dart';
import 'package:sidialichbeb/service/prayerTimeService.dart';
import 'package:sidialichbeb/utils/constants/constants.dart';
import 'package:sidialichbeb/utils/helper/helper.dart';
import 'package:flutter/services.dart';



class PrayerTimePage extends StatefulWidget {
  const PrayerTimePage({super.key});

  @override
  State<PrayerTimePage> createState() => _PrayerTimePage();
}

class _PrayerTimePage extends State<PrayerTimePage> {
  PrayerTime? _prayerTime;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrayerData();
  }

  Future<void> _loadPrayerData() async {
    final prayerService = PrayerTimeService();
    PrayerTime? data = await prayerService.getPrayerTimesFromSharedPref();

    setState(() {
      _prayerTime = data;
      _isLoading = false;
    });
  }

  String _getNextPrayerName(PrayerTime prayerTime) {
    return PrayerTimeService().getNextPrayer(prayerTime);
  }

  bool _isNextPrayer(String arabicPrayerName) {
    if (_prayerTime == null) return false;
    final next = _getNextPrayerName(_prayerTime!).toLowerCase();
    final arabicName = arabicPrayerNames[next];
    return arabicPrayerName == arabicName;
  }




  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black12, // keep it transparent or set a color
        statusBarIconBrightness: Brightness.dark, // for Android
        statusBarBrightness: Brightness.light, // for iOS
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: _isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
            ),
            SizedBox(height: 16),
            Text(
              "Loading prayer times...",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      )
          : _prayerTime == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              "Failed to load prayer times",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Please check your internet connection",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });
                _loadPrayerData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
              ),
              child: const Text("Try Again"),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Text(
                    "الصلاة القادمة: ${arabicPrayerNames[_getNextPrayerName(_prayerTime!).toLowerCase()]}",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Apply the formatting function to each prayer time
                  _buildPrayerCard("الفجر", helper().formatTimeTo24Hour(_prayerTime!.fajr), Icons.nights_stay, const Color(0xFF1A237E)),
                  _buildPrayerCard("شروق الشمس", helper().formatTimeTo24Hour(_prayerTime!.shurooq), Icons.wb_sunny, const Color(0xFFFF8F00)),
                  _buildPrayerCard("الظهر", helper().formatTimeTo24Hour(_prayerTime!.dhuhr), Icons.wb_sunny_outlined, const Color(0xFFE65100)),
                  _buildPrayerCard("العصر", helper().formatTimeTo24Hour(_prayerTime!.asr), Icons.wb_twilight, const Color(0xFFBF360C)),
                  _buildPrayerCard("المغرب", helper().formatTimeTo24Hour(_prayerTime!.maghrib), Icons.brightness_3, const Color(0xFF4A148C)),
                  _buildPrayerCard("العشاء", helper().formatTimeTo24Hour(_prayerTime!.isha), Icons.bedtime, const Color(0xFF263238)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 25, color: Color(0xFF2E7D32)),
                  SizedBox(width: 8),
                  Text(
                    "مواقيت الصلات في سيدي علي الشباب",
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerCard(String prayerName, String time, IconData icon, Color color) {
    final isNext = _isNextPrayer(prayerName);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isNext ? 24 : 16),
      decoration: BoxDecoration(
        gradient: isNext
            ? const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        color: isNext ? null : Colors.white,
        borderRadius: BorderRadius.circular(isNext ? 20 : 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: isNext ? 15 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isNext ? Colors.white.withOpacity(0.2) : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isNext ? Colors.white : color,
              size: isNext ? 30 : 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isNext ? "⏰ $prayerName" : prayerName,
                  style: TextStyle(
                    fontSize: isNext ? 20 : 16,
                    fontWeight: FontWeight.bold,
                    color: isNext ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isNext ? Colors.white.withOpacity(0.2) : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              time,
              style: TextStyle(
                fontSize: isNext ? 18 : 16,
                fontWeight: FontWeight.bold,
                color: isNext ? Colors.white : color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}