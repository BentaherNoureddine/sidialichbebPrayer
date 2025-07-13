import 'dart:async'; // Import for Timer
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sidialichbeb/model/prayerTime.dart';
import 'package:sidialichbeb/service/prayerTimeService.dart';
import 'package:sidialichbeb/utils/constants/constants.dart';
import 'package:sidialichbeb/utils/helper/helper.dart';
import 'dart:ui';

class PrayerTimePage extends StatefulWidget {
  const PrayerTimePage({super.key});

  @override
  State<PrayerTimePage> createState() => _PrayerTimePage();
}

class _PrayerTimePage extends State<PrayerTimePage> {
  final helper = Helper();

  PrayerTime? _prayerTime;
  bool _isLoading = true;
  String _countdownText = "";
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _loadPrayerData();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> _loadPrayerData() async {
    final prayerService = PrayerTimeService();
    PrayerTime? data = await prayerService.getPrayerTimesFromSharedPref();

    setState(() {
      _prayerTime = data;
      _isLoading = false;
      if (_prayerTime != null) {
        _startCountdownTimer(); // Start the timer once data is loaded
      }
    });
  }



  void _startCountdownTimer() {
    _countdownTimer?.cancel(); // Cancel any existing timer before starting a new one
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_prayerTime == null) {
        timer.cancel(); // If prayer data is null, stop the timer
        setState(() {
          _countdownText = "N/A";
        });
        return;
      }

      final nextPrayerEnglishName = PrayerTimeService().getNextPrayer(_prayerTime!);
      String? nextPrayerTime24Hour;

      // Get the 24-hour time for the next prayer
      switch (nextPrayerEnglishName.toLowerCase()) {
        case "fajr":
          nextPrayerTime24Hour = helper.formatTimeTo24Hour(_prayerTime!.fajr);
          break;
        case "shurooq":
          nextPrayerTime24Hour = helper.formatTimeTo24Hour(_prayerTime!.shurooq);
          break;
        case "dhuhr":
          nextPrayerTime24Hour = helper.formatTimeTo24Hour(_prayerTime!.dhuhr);
          break;
        case "asr":
          nextPrayerTime24Hour = helper.formatTimeTo24Hour(_prayerTime!.asr);
          break;
        case "maghrib":
          nextPrayerTime24Hour = helper.formatTimeTo24Hour(_prayerTime!.maghrib);
          break;
        case "isha":
          nextPrayerTime24Hour = helper.formatTimeTo24Hour(_prayerTime!.isha);
          break;
        default:
          nextPrayerTime24Hour = null;
          break;
      }

      if (nextPrayerTime24Hour != null) {
        final remaining = helper.calculateTimeUntilPrayer(nextPrayerTime24Hour);

        if (remaining.isNegative || remaining.inSeconds <= 0) {
          // If time is negative or zero, it means the prayer has just passed.
          // We need to reload data to get the *next* next prayer.
          _loadPrayerData(); // This will restart the timer after fetching new data
          setState(() {
            _countdownText = "Calculating next prayer...";
          });
        } else {
          final hours = remaining.inHours;
          final minutes = remaining.inMinutes.remainder(60);
          final seconds = remaining.inSeconds.remainder(60);
          setState(() {
            _countdownText = "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
          });
        }
      } else {
        setState(() {
          _countdownText = "N/A";
        });
      }
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
        statusBarColor: Colors.black12, // For a subtle transparency or set your desired color
        statusBarIconBrightness: Brightness.dark, // For Android status bar icons
        statusBarBrightness: Brightness.light, // For iOS status bar icons
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea( // Use SafeArea to avoid content overlapping system UIs like notches
        child: _isLoading
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
                      ":الصلاة القادمة ",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${arabicPrayerNames[_getNextPrayerName(_prayerTime!).toLowerCase()]}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8), // Spacing for countdown
                    Text(
                      _countdownText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40, // Make it big and prominent
                        fontWeight: FontWeight.bold,
                        fontFeatures: [FontFeature.tabularFigures()], // Keeps digits aligned
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildPrayerCard("الفجر", helper.formatTimeTo24Hour(_prayerTime!.fajr), Icons.nights_stay, const Color(0xFF1A237E)),
                    _buildPrayerCard("شروق الشمس", helper.formatTimeTo24Hour(_prayerTime!.shurooq), Icons.wb_sunny, const Color(0xFFFF8F00)),
                    _buildPrayerCard("الظهر", helper.formatTimeTo24Hour(_prayerTime!.dhuhr), Icons.wb_sunny_outlined, const Color(0xFFE65100)),
                    _buildPrayerCard("العصر", helper.formatTimeTo24Hour(_prayerTime!.asr), Icons.wb_twilight, const Color(0xFFBF360C)),
                    _buildPrayerCard("المغرب", helper.formatTimeTo24Hour(_prayerTime!.maghrib), Icons.brightness_3, const Color(0xFF4A148C)),
                    _buildPrayerCard("العشاء", helper.formatTimeTo24Hour(_prayerTime!.isha), Icons.bedtime, const Color(0xFF263238)),
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