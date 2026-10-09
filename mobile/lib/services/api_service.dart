import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  static String? authToken;

  static Map<String, String> get headers {
    return {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };
  }

  // Auth
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      authToken = data['access_token'];
    }
    return data;
  }

  static Future<Map<String, dynamic>> register(String email, String password, String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: headers,
      body: jsonEncode({'email': email, 'password': password, 'full_name': name}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      authToken = data['access_token'];
    }
    return data;
  }

  static Future<Map<String, dynamic>> getMe() async {
    final response = await http.get(Uri.parse('$baseUrl/auth/me'), headers: headers);
    return jsonDecode(response.body);
  }

  // Wallet
  static Future<Map<String, dynamic>> deposit(double amount, {String method = 'UPI'}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/wallet/deposit'),
      headers: headers,
      body: jsonEncode({'amount': amount, 'payment_method': method}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> withdraw(double amount, bool disclaimerAccepted) async {
    final response = await http.post(
      Uri.parse('$baseUrl/wallet/withdraw'),
      headers: headers,
      body: jsonEncode({
        'amount': amount,
        'disclaimer_accepted': disclaimerAccepted,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getLedger() async {
    final response = await http.get(Uri.parse('$baseUrl/wallet/ledger'), headers: headers);
    return jsonDecode(response.body);
  }

  // Daily Spin
  static Future<Map<String, dynamic>> claimDailySpin() async {
    final response = await http.post(Uri.parse('$baseUrl/games/spin/claim'), headers: headers);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getSpinStatus() async {
    final response = await http.get(Uri.parse('$baseUrl/games/spin/status'), headers: headers);
    return jsonDecode(response.body);
  }

  // Games
  static Future<Map<String, dynamic>> startAviator(double betAmount) async {
    final response = await http.post(
      Uri.parse('$baseUrl/games/aviator/start'),
      headers: headers,
      body: jsonEncode({'bet_amount': betAmount}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> cashoutAviator(String gameId, double multiplier) async {
    final response = await http.post(
      Uri.parse('$baseUrl/games/aviator/cashout'),
      headers: headers,
      body: jsonEncode({'game_id': gameId, 'multiplier': multiplier}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> startMines(double betAmount, int count) async {
    final response = await http.post(
      Uri.parse('$baseUrl/games/mines/start'),
      headers: headers,
      body: jsonEncode({'bet_amount': betAmount, 'mines_count': count}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> revealMinesTile(String gameId, int tileIndex) async {
    final response = await http.post(
      Uri.parse('$baseUrl/games/mines/reveal'),
      headers: headers,
      body: jsonEncode({'game_id': gameId, 'tile_index': tileIndex}),
    );
    return jsonDecode(response.body);
  }

  // Sports
  static Future<List<dynamic>> getSportsEvents({String? sport}) async {
    final url = Uri.parse('$baseUrl/sports/events${sport != null ? '?sport=$sport' : ''}');
    final response = await http.get(url, headers: headers);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> placeSportsBet(String eventId, String selection, double stake) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sports/bet'),
      headers: headers,
      body: jsonEncode({'event_id': eventId, 'selection': selection, 'stake': stake}),
    );
    return jsonDecode(response.body);
  }
}
