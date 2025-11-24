import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class ApiService {
  // CHANGE THIS TO YOUR FLASK SERVER IP
  static const String baseUrl = 'https://vanitalunchhome-xwhj.onrender.com';

  // Register
  static Future<bool> register(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  // Verify OTP
  static Future<bool> verifyOtp(String email, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );
    return response.statusCode == 200;
  }

  // Login
  static Future<User?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      User user = User.fromJson(data['user']);
      await _saveLocalUser(user);
      return user;
    }
    return null;
  }

  // Get Menu Items
  static Future<List<dynamic>> getMenu() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/menu-items'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to load menu. Status code: ${response.statusCode}');
        return [];
      }
    } on SocketException {
      print('No Internet connection');
      return [];
    } catch (e) {
      print('Error fetching menu: $e');
      return [];
    }
  }

  // Place Order
  static Future<Map<String, dynamic>> placeOrder(
    Map<String, dynamic> orderData,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/order'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(orderData),
    );
    return jsonDecode(response.body);
  }

  // Update User Address
  static Future<bool> updateUserAddress(
      int userId, Map<String, dynamic> addressData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/update-address'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, ...addressData}),
    );

    if (response.statusCode == 200) {
      final user = await getLocalUser();
      if (user != null) {
        final updatedUser = User(
          id: user.id,
          fullName: user.fullName,
          mobile: user.mobile,
          email: user.email,
          address: addressData['address'],
          latitude: addressData['lat'],
          longitude: addressData['lng'],
        );
        await _saveLocalUser(updatedUser);
      }
      return true;
    }
    return false;
  }

  // Local Storage Helpers
  static Future<void> _saveLocalUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user.toJson()));
  }

  static Future<User?> getLocalUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userStr = prefs.getString('user_data');
    if (userStr != null) {
      try {
        return User.fromJson(jsonDecode(userStr));
      } catch (e) {
        print('Error decoding user data: $e');
        return null;
      }
    }
    return null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
