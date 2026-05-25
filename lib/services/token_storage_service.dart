import 'package:shared_preferences/shared_preferences.dart';

class TokenStorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _sessionIdKey = 'session_id';
  static const String _userIdKey = 'user_id';
  static const String _tokenExpiryKey = 'token_expiry';

  // Token expires in 15 minutes (900 seconds)
  static const int _tokenLifetimeSeconds = 900;

  static Future<void> saveTokens({
    required String accessToken,
    required String sessionId,
    required String userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_sessionIdKey, sessionId);
    await prefs.setString(_userIdKey, userId);
    
    // Store expiration timestamp (current time + 15 minutes)
    final expiryTimestamp = DateTime.now().add(
      Duration(seconds: _tokenLifetimeSeconds),
    ).millisecondsSinceEpoch;
    await prefs.setInt(_tokenExpiryKey, expiryTimestamp);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  static Future<String?> getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionIdKey);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_sessionIdKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_tokenExpiryKey);
  }

  static Future<bool> hasTokens() async {
    final token = await getAccessToken();
    final sessionId = await getSessionId();
    final userId = await getUserId();
    return token != null && sessionId != null && userId != null;
  }

  /// Get the token expiration timestamp
  static Future<int?> getTokenExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_tokenExpiryKey);
  }

  /// Check if token is expired or will expire soon (within 2 minutes)
  static Future<bool> isTokenExpiredOrExpiringSoon() async {
    final expiryTimestamp = await getTokenExpiry();
    if (expiryTimestamp == null) {
      return true; // No expiry stored, consider expired
    }

    final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
    final now = DateTime.now();
    final timeUntilExpiry = expiryTime.difference(now);
    
    // Consider expired if less than 2 minutes remaining
    return timeUntilExpiry.inSeconds < 120;
  }

  /// Get time until token expires in seconds
  static Future<int?> getTimeUntilExpiry() async {
    final expiryTimestamp = await getTokenExpiry();
    if (expiryTimestamp == null) {
      return null;
    }

    final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
    final now = DateTime.now();
    final timeUntilExpiry = expiryTime.difference(now);
    
    return timeUntilExpiry.inSeconds > 0 ? timeUntilExpiry.inSeconds : 0;
  }
}

