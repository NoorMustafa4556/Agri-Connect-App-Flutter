import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Auth/AuthService.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  String? _userRole;
  String? _userName;
  String? _profileImageUrl;
  bool _isLoading = false;

  User? get user => _user;
  String? get userRole => _userRole;
  String? get userName => _userName;
  String? get profileImageUrl => _profileImageUrl;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _authService.userStream.listen((User? user) async {
      _user = user;
      if (user != null) {
        // Fetch role and name if user exists
        final data = await _authService.getUserData(user.uid);
        _userRole = data?['role'];
        _userName = data?['fullName'];
        _profileImageUrl = data?['profileImageUrl'];
      } else {
        _userRole = null;
        _userName = null;
        _profileImageUrl = null;
      }
      notifyListeners();
    });
  }

  void setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  Future<void> login(String email, String password, BuildContext context) async {
    try {
      setLoading(true);
      await _authService.loginUser(email: email, password: password);
      // navigation will be handled by UI listening to streams, 
      // but if we want manual routing, it's done in the view based on success without throwing.
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
    required String city,
    required String phone,
    BuildContext? context,
  }) async {
    try {
      setLoading(true);
      await _authService.registerUser(
        email: email, 
        password: password, 
        fullName: fullName, 
        role: role, 
        city: city,
        phone: phone,
      );
    } catch (e) {
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  Future<Map<String, dynamic>?> getUserData() async {
    if (_user == null) return null;
    return await _authService.getUserData(_user!.uid);
  }

  Future<void> refreshUserData() async {
    if (_user != null) {
      final data = await _authService.getUserData(_user!.uid);
      _userRole = data?['role'];
      _userName = data?['fullName'];
      _profileImageUrl = data?['profileImageUrl'];
      notifyListeners();
    }
  }
}
