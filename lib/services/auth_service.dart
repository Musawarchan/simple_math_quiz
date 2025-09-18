import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import '../data/models/auth_models.dart';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'auth_token';

  // Simulated user database (in a real app, this would be a backend API)
  static final Map<String, User> _users = {};
  static final Map<String, String> _passwords = {}; // email -> password

  // Email validation regex
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Password validation regex (at least 8 characters, 1 uppercase, 1 lowercase, 1 number)
  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$',
  );

  /// Validates email format
  static String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email is required';
    }

    if (!_emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates password strength
  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    if (!_passwordRegex.hasMatch(password)) {
      return 'Password must contain at least one uppercase letter, one lowercase letter, and one number';
    }

    return null;
  }

  /// Validates name
  static String? validateName(String name) {
    if (name.isEmpty) {
      return 'Name is required';
    }

    if (name.length < 2) {
      return 'Name must be at least 2 characters long';
    }

    if (name.length > 50) {
      return 'Name must be less than 50 characters';
    }

    return null;
  }

  /// Validates password confirmation
  static String? validatePasswordConfirmation(
      String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Sign up a new user
  Future<AuthResult> signUp(SignupCredentials credentials) async {
    try {
      // Validate all fields
      final emailError = validateEmail(credentials.email);
      if (emailError != null) {
        return AuthResult.failure(message: emailError);
      }

      final passwordError = validatePassword(credentials.password);
      if (passwordError != null) {
        return AuthResult.failure(message: passwordError);
      }

      final nameError = validateName(credentials.name);
      if (nameError != null) {
        return AuthResult.failure(message: nameError);
      }

      final confirmPasswordError = validatePasswordConfirmation(
        credentials.password,
        credentials.confirmPassword,
      );
      if (confirmPasswordError != null) {
        return AuthResult.failure(message: confirmPasswordError);
      }

      // Check if user already exists
      if (_users.containsKey(credentials.email.toLowerCase())) {
        return AuthResult.failure(
          message: 'An account with this email already exists',
          errorCode: 'EMAIL_ALREADY_EXISTS',
        );
      }

      // Create new user
      final userId = _generateUserId();
      final user = User(
        id: userId,
        email: credentials.email.toLowerCase(),
        name: credentials.name.trim(),
        createdAt: DateTime.now(),
        isEmailVerified: false,
      );

      // Store user and password
      _users[user.email] = user;
      _passwords[user.email] = credentials.password;

      // Save to local storage
      await _saveUser(user);
      await _saveToken(_generateToken());

      return AuthResult.success(
        user: user,
        message: 'Account created successfully!',
      );
    } catch (e) {
      return AuthResult.failure(
        message: 'An error occurred during sign up. Please try again.',
        errorCode: 'SIGNUP_ERROR',
      );
    }
  }

  /// Sign in an existing user
  Future<AuthResult> signIn(LoginCredentials credentials) async {
    try {
      // Validate email
      final emailError = validateEmail(credentials.email);
      if (emailError != null) {
        return AuthResult.failure(message: emailError);
      }

      if (credentials.password.isEmpty) {
        return AuthResult.failure(message: 'Password is required');
      }

      final email = credentials.email.toLowerCase();

      // Check if user exists
      if (!_users.containsKey(email)) {
        return AuthResult.failure(
          message: 'No account found with this email address',
          errorCode: 'USER_NOT_FOUND',
        );
      }

      // Check password
      if (_passwords[email] != credentials.password) {
        return AuthResult.failure(
          message: 'Incorrect password',
          errorCode: 'INVALID_PASSWORD',
        );
      }

      // Update last login time
      final user = _users[email]!.copyWith(
        lastLoginAt: DateTime.now(),
      );
      _users[email] = user;

      // Save to local storage
      await _saveUser(user);
      await _saveToken(_generateToken());

      return AuthResult.success(
        user: user,
        message: 'Welcome back!',
      );
    } catch (e) {
      return AuthResult.failure(
        message: 'An error occurred during sign in. Please try again.',
        errorCode: 'SIGNIN_ERROR',
      );
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_tokenKey);
    } catch (e) {
      // Ignore errors during sign out
    }
  }

  /// Get the current user from local storage
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return User.fromJson(userMap);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final userJson = prefs.getString(_userKey);

      return token != null && userJson != null;
    } catch (e) {
      return false;
    }
  }

  /// Save user to local storage
  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  /// Save auth token to local storage
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Generate a simple user ID
  String _generateUserId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'user_${timestamp}_${random.nextInt(10000)}';
  }

  /// Generate a simple auth token
  String _generateToken() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'token_${timestamp}_${random.nextInt(100000)}';
  }

  /// Reset password (simulated)
  Future<AuthResult> resetPassword(String email) async {
    try {
      final emailError = validateEmail(email);
      if (emailError != null) {
        return AuthResult.failure(message: emailError);
      }

      final normalizedEmail = email.toLowerCase();

      if (!_users.containsKey(normalizedEmail)) {
        return AuthResult.failure(
          message: 'No account found with this email address',
          errorCode: 'USER_NOT_FOUND',
        );
      }

      // In a real app, you would send an email with reset instructions
      return AuthResult.successMessage(
        message: 'Password reset instructions have been sent to your email',
      );
    } catch (e) {
      return AuthResult.failure(
        message: 'An error occurred. Please try again.',
        errorCode: 'RESET_ERROR',
      );
    }
  }

  /// Update user profile
  Future<AuthResult> updateProfile({
    required String userId,
    String? name,
    String? email,
  }) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        return AuthResult.failure(
          message: 'User not found',
          errorCode: 'USER_NOT_FOUND',
        );
      }

      // Validate email if provided
      if (email != null) {
        final emailError = validateEmail(email);
        if (emailError != null) {
          return AuthResult.failure(message: emailError);
        }

        // Check if email is already taken
        if (email.toLowerCase() != currentUser.email &&
            _users.containsKey(email.toLowerCase())) {
          return AuthResult.failure(
            message: 'This email is already in use',
            errorCode: 'EMAIL_ALREADY_EXISTS',
          );
        }
      }

      // Validate name if provided
      if (name != null) {
        final nameError = validateName(name);
        if (nameError != null) {
          return AuthResult.failure(message: nameError);
        }
      }

      // Update user
      final updatedUser = currentUser.copyWith(
        name: name ?? currentUser.name,
        email: email?.toLowerCase() ?? currentUser.email,
      );

      // Update in memory storage
      _users[updatedUser.email] = updatedUser;

      // Save to local storage
      await _saveUser(updatedUser);

      return AuthResult.success(
        user: updatedUser,
        message: 'Profile updated successfully',
      );
    } catch (e) {
      return AuthResult.failure(
        message: 'An error occurred while updating profile',
        errorCode: 'UPDATE_ERROR',
      );
    }
  }
}
