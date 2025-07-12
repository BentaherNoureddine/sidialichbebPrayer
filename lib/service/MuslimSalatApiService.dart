


import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sidialichbeb/utils/constants/api_keys.dart';





class MuslimSalatApiService {


  Future<Map<String,dynamic>?> fetchPrayerData() async{


    final response = await http.get(Uri.parse('https://muslimsalat.com/bizerte.json?key=$API_KEY'));

    try{
      if (response.statusCode == 200){
        return jsonDecode(response.body);

      }

    }catch(e){
      print("error fetching fata from muslim salat api");
    }
    return null;

  }



}