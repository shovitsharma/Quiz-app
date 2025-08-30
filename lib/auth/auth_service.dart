import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "http://34.235.122.140:4000/api";

  // Store the token in memory
  static String? _token;

  // Login method
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['token']; // store token in memory
      return data; // should contain token and user info
    } else {
      return {
        "success": false,
        "message": jsonDecode(response.body)["message"] ?? "Login failed"
      };
    }
  }

  // Signup method
  static Future<Map<String, dynamic>> signup(String name, String email, String password) async {
  final url = Uri.parse('$baseUrl/auth/signup');
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"username": name, "email": email, "password": password}),
  );

  if (response.statusCode == 201) {
    return {"success": true, "data": jsonDecode(response.body)};
  } else {
    return {
      "success": false,
      "message": jsonDecode(response.body)["message"] ?? "Signup failed"
    };
  }
}


  // Get token method
  static String? getToken() {
    return _token;
  }

  // Optional: logout
  static void logout() {
    _token = null;
  }
}
