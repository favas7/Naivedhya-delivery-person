import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _user = _supabase.auth.currentUser;
    _supabase.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      notifyListeners();
    });
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<bool> signUp(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      debugPrint('Response user: ${response.user}');
      debugPrint('Response session: ${response.session}');

      // Supabase returns user but null session when email confirmation is required
      if (response.user != null) {
        _user = response.user;
        return true;
      }

      // If both are null, email is likely already registered
      _setError('Email may already be registered, or confirmation is required.');
      return false;

    } on AuthException catch (e) {
      debugPrint('AuthException: ${e.message}');
      _setError(e.message);
      return false;
    } catch (e) {
      debugPrint('Unexpected error: $e');
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        _user = response.user;
        return true;
      }
      return false;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);
      await _supabase.auth.resetPasswordForEmail(email);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      _setError('Error signing out');
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }



  

}
