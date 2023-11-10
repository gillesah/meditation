import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ConsecutiveDaysManager {
  int consecutiveDays = 0;
  DateTime? lastMeditationDate;

  Future<void> loadConsecutiveDays() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    consecutiveDays = prefs.getInt('consecutiveDays') ?? 0;
    String? lastMeditationDateString = prefs.getString('lastMeditationDate');
    lastMeditationDate = lastMeditationDateString != null
        ? DateTime.parse(lastMeditationDateString)
        : null;
  }

  Future<void> saveConsecutiveDays() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('consecutiveDays', consecutiveDays);
    if (lastMeditationDate != null) {
      await prefs.setString(
          'lastMeditationDate', DateFormat('yyyy-MM-dd').format(lastMeditationDate!));
    }
  }

  Future<void> resetConsecutiveDays() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('consecutiveDays');
    await prefs.remove('lastMeditationDate');
    consecutiveDays = 0;
    lastMeditationDate = null;
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  void incrementConsecutiveDays() {
    if (lastMeditationDate != null && isSameDay(lastMeditationDate!, DateTime.now())) {
      // Si ce n'est pas un nouveau jour (c'est-à-dire le même jour), ne faites rien
    } else {
      // Si c'est un nouveau jour ou la première méditation, augmenter le nombre de jours consécutifs
      consecutiveDays++;
      lastMeditationDate = DateTime.now();
      saveConsecutiveDays(); // Sauvegarder la nouvelle valeur du nombre de jours consécutifs et la date de la dernière méditation
    }
  }
}
