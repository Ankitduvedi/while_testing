import 'package:shared_preferences/shared_preferences.dart';

class LivesManager {
  static const String _livesKey = 'user_lives';
  static const String _lastRenewalKey = 'last_renewal_time';

  static Future<int> getLives() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_livesKey) ?? 3; // Default to 3 lives if not set
  }

  static Future<DateTime?> getLastRenewalTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? timestamp = prefs.getInt(_lastRenewalKey);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  static Future<void> renewLives() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_livesKey, 3);
    await prefs.setInt(_lastRenewalKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<void> decrementLife() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int lives = prefs.getInt(_livesKey) ?? 3;

    if (lives > 0) {
      lives--;
      await prefs.setInt(_livesKey, lives);
    }
  }
}

// Example usage:

// Future<void> main() async {
//   await LivesManager
//       .decrementLife(); // Decrement life when user attempts a quiz question

//   int remainingLives = await LivesManager.getLives();
//   print('Remaining lives: $remainingLives');

//   DateTime? lastRenewalTime = await LivesManager.getLastRenewalTime();
//   print('Last renewal time: $lastRenewalTime');

//   // Check if 24 hours have passed since the last renewal
//   if (lastRenewalTime != null) {
//     Duration timePassed = DateTime.now().difference(lastRenewalTime);
//     if (timePassed.inHours >= 24) {
//       await LivesManager.renewLives(); // Renew lives if 24 hours have passed
//       print('Lives renewed!');
//     }
//   }
// }
