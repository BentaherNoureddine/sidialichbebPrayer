import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sidialichbeb/model/prayerTime.dart';
import 'package:sidialichbeb/utils/constants/api_keys.dart';




class MuslimSalatApiService {


  Future<PrayerTime?> fetchPrayerData() async {
    final response = await http.get(
      Uri.parse('https://muslimsalat.com/bizerte.json?key=$API_KEY'),
    );

    try {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print(data);

        if (data['items'] != null && data['items'] is List && data['items'].isNotEmpty) {
          final items = data['items'][0];
          return PrayerTime.fromJson(items);
        }
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching data from Muslim Salat API: $e");
    }

    return null;
  }
}
