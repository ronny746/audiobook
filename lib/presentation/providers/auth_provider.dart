import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isInitialized = false;
  Map<String, dynamic>? _user;
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  String get mobileNumber => _user?['phone'] ?? "No number";

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    
    _isAuthenticated = await AuthService.isLoggedIn();
    if (_isAuthenticated) {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('userData');
      if (userData != null) {
        _user = jsonDecode(userData);
      }
    }
    
    _isInitialized = true;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> sendOtp(String phone) async {
    try {
      final result = await AuthService.sendOtp(phone);
      return result['msg'] != null;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await AuthService.verifyOtp(phone, otp);
      if (result['token'] != null) {
        _isAuthenticated = true;
        _user = result['user'];
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchProfile() async {
    final token = await AuthService.getToken();
    if (token == null) return;
    
    try {
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/user/me'),
        headers: {'x-auth-token': token},
      );
    
      if (response.statusCode == 200) {
        _user = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userData', jsonEncode(_user));
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }
}
