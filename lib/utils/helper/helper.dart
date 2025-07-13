import 'package:intl/intl.dart';

class helper {

  DateTime parseTime(String dateString, String timeString) {
    final format = DateFormat('yyyy-M-d H:mm'); // H = 24-hour format (0-23)
    return format.parse('$dateString $timeString');
  }




  // function to format time to 24-hour
  String formatTimeTo24Hour(String time12Hour) {
    try {
      // Handle cases where the input might not strictly follow "HH:MM AM/PM"
      // or might already be 24-hour.
      // For example, some APIs might return "05:30 (AM)" or just "05:30".
      // We'll try to parse it assuming it's in a common 12-hour format.

      // First, try to parse with a standard 12-hour format
      final inputFormat12Hour = DateFormat("hh:mm a");
      final dateTime = inputFormat12Hour.parse(time12Hour.toUpperCase().replaceAll("AM", "AM").replaceAll("PM", "PM"));

      // Then format to 24-hour
      final outputFormat24Hour = DateFormat("HH:mm");
      return outputFormat24Hour.format(dateTime);
    } catch (e) {
      // If parsing fails (e.g., if the time is already in 24-hour format
      // or an unexpected format), try to just return the original string
      // or handle it as an error. For robustness, we'll try to parse as 24-hour
      // if 12-hour parsing fails.
      try {
        final inputFormat24Hour = DateFormat("HH:mm");
        final dateTime = inputFormat24Hour.parse(time12Hour);
        return time12Hour; // It was already 24-hour
      } catch (e2) {
        print("Error formatting time: $time12Hour - $e2");
        return time12Hour; // Fallback to original if all else fails
      }
    }
  }





}
