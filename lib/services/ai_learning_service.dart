import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AILearningService {
  static const String _apiKeyKey = 'AIzaSyBjxxkFDEviYxYih8y_5cMBvgCMJTjSEgY';
  static const String _conversationHistoryKey = 'ai_conversation_history';

  // Default API key - in production, this should be stored securely
  static const String _defaultApiKey =
      'AIzaSyBjxxkFDEviYxYih8y_5cMBvgCMJTjSEgY';

  late Gemini _gemini;
  bool _isInitialized = false;
  List<Map<String, String>> _conversationHistory = [];

  /// Initialize the Gemini AI service
  Future<void> initialize() async {
    try {
      final apiKey = await _getApiKey();
      print('API Key retrieved: ${apiKey.substring(0, 10)}...');

      if (apiKey.isEmpty) {
        throw Exception('Please set your Gemini API key');
      }

      print('Initializing Gemini...');

      // Gemini is already initialized in main.dart
      _gemini = Gemini.instance;

      _isInitialized = true;

      // Load conversation history
      await _loadConversationHistory();
      print('AI service initialized successfully');
    } catch (e) {
      print('Failed to initialize AI service: $e');
      throw Exception('Failed to initialize AI service: $e');
    }
  }

  /// Get the system instruction for the AI assistant
  String _getSystemInstruction() {
    return '''
You are an AI Learning Assistant specialized in mathematics education. Your role is to:

1. **Educational Focus**: Help students learn math concepts through clear explanations, examples, and practice problems.

2. **Teaching Approach**:
   - Use the Socratic method - ask guiding questions to help students discover answers
   - Break down complex problems into simpler steps
   - Provide multiple explanations for different learning styles
   - Encourage critical thinking and problem-solving

3. **Content Areas**: Focus on:
   - Basic arithmetic (addition, subtraction, multiplication, division)
   - Fractions, decimals, and percentages
   - Algebra basics (equations, variables, solving for x)
   - Geometry fundamentals (shapes, angles, area, perimeter)
   - Statistics and probability basics
   - Word problems and real-world applications

4. **Communication Style**:
   - Be encouraging and supportive
   - Use age-appropriate language
   - Provide positive reinforcement
   - Be patient with mistakes
   - Use analogies and visual descriptions when helpful

5. **Response Guidelines**:
   - Keep responses concise but comprehensive
   - Include step-by-step solutions
   - Ask follow-up questions to check understanding
   - Suggest practice problems when appropriate
   - Use emojis sparingly to make responses engaging

6. **Safety**: Always maintain a safe, educational environment. If asked about non-mathematical topics, politely redirect to math-related questions.

Remember: Your goal is to make math learning enjoyable, accessible, and effective for students of all levels.
''';
  }

  /// Send a message to the AI and get a response
  Future<String> sendMessage(String message) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      print('Sending message to Gemini: $message');

      // Add system instruction to the conversation
      final fullMessage = '${_getSystemInstruction()}\n\nUser: $message';

      final response = await _gemini.prompt(parts: [
        Part.text(fullMessage),
      ]);

      print('Received response from Gemini: ${response?.output}');

      final aiResponse = response?.output ??
          'I apologize, but I couldn\'t generate a response. Please try again.';

      // Save conversation history
      _conversationHistory.add({'user': message, 'ai': aiResponse});
      await _saveConversationHistory();

      return aiResponse;
    } catch (e) {
      print('Error sending message to Gemini: $e');
      throw Exception('Failed to get AI response: $e');
    }
  }

  /// Set the Gemini API key
  Future<void> setApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, apiKey);

    // Reinitialize Gemini with new API key
    Gemini.init(apiKey: apiKey);
    _gemini = Gemini.instance;

    // Mark as initialized
    _isInitialized = true;
  }

  /// Get the stored API key
  Future<String> _getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey) ?? _defaultApiKey;
  }

  /// Check if API key is configured
  Future<bool> isApiKeyConfigured() async {
    final apiKey = await _getApiKey();
    return apiKey.isNotEmpty;
  }

  /// Save conversation history
  Future<void> _saveConversationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = _conversationHistory
          .map((msg) => {
                'user': msg['user']!,
                'ai': msg['ai']!,
              })
          .toList();

      await prefs.setString(_conversationHistoryKey, historyJson.toString());
    } catch (e) {
      // Ignore errors when saving history
    }
  }

  /// Load conversation history
  Future<void> _loadConversationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_conversationHistoryKey);

      if (historyJson != null) {
        // Simple history loading - in a real app you'd use proper JSON serialization
        _conversationHistory = [];
      }
    } catch (e) {
      // Ignore errors when loading history
    }
  }

  /// Clear conversation history
  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_conversationHistoryKey);

      _conversationHistory.clear();
    } catch (e) {
      // Ignore errors when clearing history
    }
  }

  /// Get conversation history count
  Future<int> getHistoryCount() async {
    return _conversationHistory.length;
  }

  /// Generate a quick response for common topics
  Future<String> getQuickResponse(String topic) async {
    final quickResponses = {
      'fractions':
          'Fractions represent parts of a whole! Think of a pizza cut into slices. If you have 3 slices out of 8 total slices, that\'s 3/8. The top number (numerator) tells you how many parts you have, and the bottom number (denominator) tells you how many equal parts the whole is divided into. Would you like me to explain how to add, subtract, multiply, or divide fractions?',
      'algebra':
          'Algebra is like solving puzzles with letters! Instead of just numbers, we use variables (like x, y) to represent unknown values. For example, if x + 5 = 12, we can figure out that x = 7. Algebra helps us solve real-world problems and understand patterns. Would you like to start with basic equations or learn about specific algebraic concepts?',
      'geometry':
          'Geometry is the study of shapes, sizes, and space! It\'s everywhere around us - from the rectangular screens we look at to the circular wheels on cars. We learn about points, lines, angles, triangles, circles, and 3D shapes. Geometry helps us understand how things fit together and measure distances and areas. What specific geometric concept interests you?',
      'statistics':
          'Statistics helps us make sense of data! It\'s about collecting, organizing, and interpreting information. For example, if you want to know the average height of students in your class, you\'d collect everyone\'s height, add them up, and divide by the number of students. Statistics helps us spot trends, make predictions, and make informed decisions. Would you like to learn about mean, median, mode, or data visualization?',
      'trigonometry':
          'Trigonometry is about the relationships between angles and sides in triangles! It\'s incredibly useful in engineering, physics, and even computer graphics. The main trigonometric functions are sine, cosine, and tangent. They help us calculate distances, heights, and angles in real-world situations. Would you like to start with the basics of right triangles or explore specific applications?',
      'calculus':
          'Calculus is the mathematics of change! It helps us understand how things change over time - like how fast a car is accelerating or how a population grows. There are two main branches: differential calculus (finding rates of change) and integral calculus (finding areas under curves). Calculus is essential in physics, engineering, economics, and many other fields. Would you like to explore derivatives or integrals?',
    };

    final lowerTopic = topic.toLowerCase();
    for (final key in quickResponses.keys) {
      if (lowerTopic.contains(key)) {
        return quickResponses[key]!;
      }
    }

    // If no quick response found, use AI
    return await sendMessage('Can you explain $topic in simple terms?');
  }

  /// Check if the service is ready to use
  bool get isReady => _isInitialized;
}
