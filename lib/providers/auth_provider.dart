import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import '../services/preference_service.dart';
import '../akun.dart';

class AuthProvider extends ChangeNotifier {
  final PreferenceService _service = PreferenceService();
  final String _secretKey = 'RahasiaSuperSulitDitebak_1234!';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _token;
  String? get token => _token;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    _token = await _service.getToken();
    _isLoggedIn = await _service.isLoggedIn();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // Simulasi Jaringan

    try {
      Map<String, String>? foundAccount;
      for (var akun in dummyAccounts) {
        if (akun['email'] == email) {
          if (akun['password'] == password) {
            foundAccount = akun;
            break;
          } else {
            throw Exception('Password salah!');
          }
        }
      }

      if (foundAccount == null) throw Exception('Email tidak terdaftar!');

      // CREATE REAL JWT
      final jwt = JWT({
        'name': foundAccount['name'],
        'email': foundAccount['email'],
        'role': foundAccount['role'],
      });

      _token = jwt.sign(
        SecretKey(_secretKey),
        expiresIn: const Duration(hours: 1),
      );

      // Persistence
      await _service.saveToken(_token!);
      await _service.setLoggedIn(true);
      if (foundAccount['name'] != null) {
        await _service.setUserName(foundAccount['name']!);
      }
      
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); 

    try {
      for (var akun in dummyAccounts) {
        if (akun['email'] == email) {
          throw Exception('Email sudah terdaftar!');
        }
      }

      final jwt = JWT({
        'name': 'Pendaftar Baru',
        'email': email,
        'role': 'User Biasa',
      });

      _token = jwt.sign(SecretKey(_secretKey), expiresIn: const Duration(hours: 1));
      
      await _service.saveToken(_token!);
      await _service.setLoggedIn(true);
      await _service.setUserName('Pendaftar Baru');
      
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _service.clearAll();
    _token = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
