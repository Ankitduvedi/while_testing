import 'package:flutter_secure_storage/flutter_secure_storage.dart';
/// for deleting any data
// deleteSecureData(String key) async {
//   await storage.delete(key: key);
// }

class SecureStorage {
  final FlutterSecureStorage storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  /// Saving Language
  Future setLanguage(String key, String language) async {
    await storage.write(key: key, value: language);
  }

  /// Fetching Language
  Future<String> getLanguage(String key) async {
    String value = await storage.read(key: key) ?? "Hindi";
    return value;
  }

  /// ************************* [User Credentials] **********************
  // Saving Access Token
  Future setUserAccessToken(String key, String accessToken) async {
    await storage.write(key: key, value: accessToken);
  }

  // Fetching Access Token
  Future<String> getUserAccessToken(String key) async {
    String value = await storage.read(key: key) ?? "";
    return value;
  }

  // Saving Access Token
  Future setTempAccessToken(String key, String accessToken) async {
    await storage.write(key: key, value: accessToken);
  }

  // Fetching Access Token
  Future<String> getTempAccessToken(String key) async {
    String value = await storage.read(key: key) ?? "";
    return value;
  }
}
