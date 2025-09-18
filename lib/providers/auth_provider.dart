import 'package:flutter/foundation.dart';
import '../data/models/auth_models.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthState _state = AuthState.initial();
  User? _currentUser;

  AuthState get state => _state;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _state.isAuthenticated;
  bool get isLoading => _state.isLoading;
  String? get errorMessage => _state.errorMessage;

  /// Initialize authentication state
  Future<void> initialize() async {
    _setState(AuthState.loading());

    try {
      final user = await _authService.getCurrentUser();
      final isAuth = await _authService.isAuthenticated();

      if (isAuth && user != null) {
        _currentUser = user;
        _setState(AuthState.authenticated(user));
      } else {
        _setState(AuthState.unauthenticated());
      }
    } catch (e) {
      _setState(AuthState.error('Failed to initialize authentication'));
    }
  }

  /// Sign up a new user
  Future<AuthResult> signUp(SignupCredentials credentials) async {
    _setState(AuthState.loading());

    try {
      final result = await _authService.signUp(credentials);

      if (result.success && result.user != null) {
        _currentUser = result.user;
        _setState(AuthState.authenticated(result.user!));
      } else {
        _setState(AuthState.error(
          result.message ?? 'Sign up failed',
          errorCode: result.errorCode,
        ));
      }

      return result;
    } catch (e) {
      final errorState = AuthState.error('An unexpected error occurred');
      _setState(errorState);
      return AuthResult.failure(message: 'An unexpected error occurred');
    }
  }

  /// Sign in an existing user
  Future<AuthResult> signIn(LoginCredentials credentials) async {
    _setState(AuthState.loading());

    try {
      final result = await _authService.signIn(credentials);

      if (result.success && result.user != null) {
        _currentUser = result.user;
        _setState(AuthState.authenticated(result.user!));
      } else {
        _setState(AuthState.error(
          result.message ?? 'Sign in failed',
          errorCode: result.errorCode,
        ));
      }

      return result;
    } catch (e) {
      final errorState = AuthState.error('An unexpected error occurred');
      _setState(errorState);
      return AuthResult.failure(message: 'An unexpected error occurred');
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      _setState(AuthState.unauthenticated());
    } catch (e) {
      _setState(AuthState.error('Failed to sign out'));
    }
  }

  /// Reset password
  Future<AuthResult> resetPassword(String email) async {
    try {
      return await _authService.resetPassword(email);
    } catch (e) {
      return AuthResult.failure(message: 'Failed to reset password');
    }
  }

  /// Update user profile
  Future<AuthResult> updateProfile({
    String? name,
    String? email,
  }) async {
    if (_currentUser == null) {
      return AuthResult.failure(message: 'No user logged in');
    }

    try {
      final result = await _authService.updateProfile(
        userId: _currentUser!.id,
        name: name,
        email: email,
      );

      if (result.success && result.user != null) {
        _currentUser = result.user;
        _setState(AuthState.authenticated(result.user!));
      }

      return result;
    } catch (e) {
      return AuthResult.failure(message: 'Failed to update profile');
    }
  }

  /// Clear error state
  void clearError() {
    if (_state.hasError) {
      _setState(_currentUser != null
          ? AuthState.authenticated(_currentUser!)
          : AuthState.unauthenticated());
    }
  }

  /// Set authentication state
  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Validate email
  String? validateEmail(String email) {
    return AuthService.validateEmail(email);
  }

  /// Validate password
  String? validatePassword(String password) {
    return AuthService.validatePassword(password);
  }

  /// Validate name
  String? validateName(String name) {
    return AuthService.validateName(name);
  }

  /// Validate password confirmation
  String? validatePasswordConfirmation(
      String password, String confirmPassword) {
    return AuthService.validatePasswordConfirmation(password, confirmPassword);
  }
}
