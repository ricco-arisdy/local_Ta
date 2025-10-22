import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:ta_project/models/app_constants.dart';
import 'package:ta_project/models/user_models.dart';
import 'package:ta_project/services/auth_login.dart';
import 'package:ta_project/services/SharedPreferences_service.dart';
import 'package:ta_project/viewsModels/base_view_models.dart';

class LoginViewModel extends BaseViewModel {
  final AuthLoginService _authLoginService = AuthLoginService();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  User? _currentUser;

  bool get obscurePassword => _obscurePassword;
  bool get rememberMe => _rememberMe;
  User? get currentUser => _currentUser;

  // Constructor - Load saved credentials saat ViewModel dibuat
  LoginViewModel() {
    _loadSavedCredentials();
  }

  // Method untuk load saved credentials
  Future<void> _loadSavedCredentials() async {
    try {
      final credentials = await SharedPreferencesService.getSavedCredentials();

      emailController.text = credentials['email'];
      passwordController.text = credentials['password'];
      _rememberMe = credentials['rememberMe'];

      notifyListeners();
    } catch (e) {
      setError('Gagal memuat data tersimpan: ${e.toString()}');
    }
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void setRememberMe(bool? value) {
    _rememberMe = value ?? false;
    notifyListeners();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  Future<bool> validateToken() async {
    try {
      final token = await SharedPreferencesService.getToken();

      if (token == null || token.isEmpty) {
        return false;
      }

      // Test token validity dengan call ke profile endpoint
      final response = await _authLoginService.testTokenValidity();

      if (!response.isSuccess) {
        // Token invalid, clear session
        await SharedPreferencesService.clearAuthData();
        return false;
      }

      return true;
    } catch (e) {
      print('💥 [LOGIN_VM] Token validation error: $e');
      return false;
    }
  }

  static final ValueNotifier<bool> logoutNotifier = ValueNotifier<bool>(false);

  // ✅ FIX: Error di line 122 dan 124
  Future<bool> handleLogin() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    try {
      setLoading(true);
      clearError();

      print('🔐 [LOGIN_VM] Starting login process...');

      final response = await _authLoginService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (response.isSuccess && response.data != null) {
        final user = response.data!;
        _currentUser = user;

        print('🔐 [LOGIN_VM] User object: $user');
        print('🔐 [LOGIN_VM] User token: ${user.token}');

        // ✅ FIX: Proper null check untuk token yang nullable
        if (user.token != null && user.token!.isNotEmpty) {
          await SharedPreferencesService.saveAuthData(
            token: user.token!,
            rememberMe: _rememberMe,
            userId: user.id.toString(),
          );

          print('✅ [LOGIN_VM] Token saved successfully via service');

          // ✅ ADD: Notify successful login
          _notifyLoginSuccess();
        } else {
          print('❌ [LOGIN_VM] TOKEN IS NULL OR EMPTY!');
          setError('Token tidak ditemukan dari server');
          setLoading(false);
          return false;
        }

        // Save user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            AppConstants.userDataKey, json.encode(user.toJson()));

        if (_rememberMe) {
          await prefs.setString(
              AppConstants.savedEmailKey, emailController.text.trim());
          await prefs.setString(
              AppConstants.savedPasswordKey, passwordController.text.trim());
          await prefs.setBool(AppConstants.rememberMeKey, true);
        } else {
          await prefs.remove(AppConstants.savedEmailKey);
          await prefs.remove(AppConstants.savedPasswordKey);
          await prefs.setBool(AppConstants.rememberMeKey, false);
        }

        print('✅ [LOGIN_VM] Login successful for user: ${user.nama}');
        setLoading(false);
        return true;
      } else {
        print('❌ [LOGIN_VM] Login failed: ${response.message}');
        setError(response.message);
        setLoading(false);
        return false;
      }
    } catch (e) {
      print('💥 [LOGIN_VM] Login error: ${e.toString()}');
      setError('Login gagal: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }

  // ✅ Updated: Use SharedPreferencesService for logout
  Future<void> handleLogout() async {
    try {
      print('🔓 [LOGIN_VM] Starting logout process...');

      // Clear auth data first
      await SharedPreferencesService.clearAuthData();

      // Clear current user
      _currentUser = null;
      clearError();

      // ✅ FIX: Safe notification after frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        logoutNotifier.value = !logoutNotifier.value;
        print('📢 [LOGIN_VM] Logout notification sent');
      });

      print('✅ [LOGIN_VM] Logout successful - all ViewModels will be notified');
    } catch (e) {
      print('💥 [LOGIN_VM] Logout error: ${e.toString()}');
      setError('Logout gagal: ${e.toString()}');
    }
  }

  void _notifyLoginSuccess() {
    // Trigger semua listener untuk reload data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        logoutNotifier.value = !logoutNotifier.value;
        print('📢 [LOGIN_VM] Login success notification sent');
      });
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
