import 'package:flutter/foundation.dart';
import '../services/ai_learning_service.dart';

class AILearningProvider extends ChangeNotifier {
  final AILearningService _aiService = AILearningService();

  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;
  String? _lastResponse;

  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  String? get lastResponse => _lastResponse;

  /// Initialize the AI service
  Future<void> initialize() async {
    if (_isInitialized) return;

    _setLoading(true);
    _clearError();

    try {
      print('Provider: Initializing AI service...');
      await _aiService.initialize();
      _isInitialized = true;
      print('Provider: AI service initialized successfully');
    } catch (e) {
      print('Provider: Failed to initialize AI service: $e');
      _setError('Failed to initialize AI service: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Send a message to the AI
  Future<String?> sendMessage(String message) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_isInitialized) {
      _setError('AI service not initialized');
      return null;
    }

    _setLoading(true);
    _clearError();

    try {
      final response = await _aiService.sendMessage(message);
      _lastResponse = response;
      notifyListeners();
      return response;
    } catch (e) {
      _setError('Failed to get AI response: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Get a quick response for common topics
  Future<String?> getQuickResponse(String topic) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_isInitialized) {
      _setError('AI service not initialized');
      return null;
    }

    _setLoading(true);
    _clearError();

    try {
      final response = await _aiService.getQuickResponse(topic);
      _lastResponse = response;
      notifyListeners();
      return response;
    } catch (e) {
      _setError('Failed to get quick response: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Set the API key
  Future<void> setApiKey(String apiKey) async {
    _setLoading(true);
    _clearError();

    try {
      await _aiService.setApiKey(apiKey);
      _isInitialized = true;
    } catch (e) {
      _setError('Failed to set API key: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Check if API key is configured
  Future<bool> isApiKeyConfigured() async {
    return await _aiService.isApiKeyConfigured();
  }

  /// Clear conversation history
  Future<void> clearHistory() async {
    try {
      await _aiService.clearHistory();
      _lastResponse = null;
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear history: $e');
    }
  }

  /// Get conversation history count
  Future<int> getHistoryCount() async {
    try {
      return await _aiService.getHistoryCount();
    } catch (e) {
      return 0;
    }
  }

  /// Clear error message
  void clearError() {
    _clearError();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
