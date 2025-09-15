import 'package:flutter/material.dart';
import '../data/models/math_models.dart';
import '../services/math_question_service.dart';
import '../services/drill_session_service.dart';

class EnhancedDrillProvider extends ChangeNotifier {
  final MathQuestionService _questionService;
  final DrillSessionService _sessionService;

  EnhancedDrillProvider({
    required MathQuestionService questionService,
    required DrillSessionService sessionService,
  })  : _questionService = questionService,
        _sessionService = sessionService;

  DrillSession get session => _sessionService.session;
  MathQuestion? get currentQuestion => _sessionService.currentQuestion;

  bool _isWaitingForAnswer = false;
  bool _showResult = false;
  bool _isCorrect = false;
  String _resultMessage = '';
  bool _isReadyToStart = true;
  bool _showContinueButton = false;

  // Store current session parameters
  OperationType _currentOperationType = OperationType.addition;
  QuestionType _currentQuestionType = QuestionType.fillInBlank;
  DifficultyLevel _currentDifficultyLevel = DifficultyLevel.medium;
  int _questionLimit = 10;
  bool _isSessionComplete = false;
  bool _shouldShowResultsPopup = false;

  bool get isWaitingForAnswer => _isWaitingForAnswer;
  bool get showResult => _showResult;
  bool get isCorrect => _isCorrect;
  String get resultMessage => _resultMessage;
  bool get isSessionComplete => _isSessionComplete;
  int get questionLimit => _questionLimit;
  int get currentQuestionNumber => _sessionService.session.totalQuestions;
  bool get isReadyToStart => _isReadyToStart;
  bool get showContinueButton => _showContinueButton;
  bool get shouldShowResultsPopup => _shouldShowResultsPopup;

  void startSession({
    required OperationType operationType,
    required QuestionType questionType,
    required DifficultyLevel difficultyLevel,
    required int questionLimit,
  }) {
    // Store the session parameters
    _currentOperationType = operationType;
    _currentQuestionType = questionType;
    _currentDifficultyLevel = difficultyLevel;
    _questionLimit = questionLimit;

    // Reset all states completely
    _isSessionComplete = false;
    _shouldShowResultsPopup = false; // Reset popup flag
    _isReadyToStart = true;
    _showContinueButton = false;
    _showResult = false;
    _isWaitingForAnswer = false;
    _isCorrect = false;
    _resultMessage = '';

    _sessionService.startNewSession();
    // Don't generate question yet - wait for user to click "Start"
    notifyListeners();
  }

  void startQuiz() {
    _isReadyToStart = false;
    _showContinueButton = false;
    _showResult = false;
    _isCorrect = false;
    _resultMessage = '';
    _generateNewQuestion();
  }

  void continueToNextQuestion() {
    _showContinueButton = false;
    _showResult = false;

    // Check if session is complete
    if (_sessionService.session.totalQuestions >= _questionLimit) {
      _isSessionComplete = true;
      _shouldShowResultsPopup = true; // Set flag to show popup
      notifyListeners();
      return;
    }

    _generateNewQuestion();
  }

  void _generateNewQuestion() {
    final question = _questionService.generateQuestion(
      operation: _currentOperationType,
      questionType: _currentQuestionType,
      difficultyLevel: _currentDifficultyLevel,
    );
    _sessionService.setCurrentQuestion(question);

    // Reset all states for new question
    _isWaitingForAnswer = true;
    _showResult = false;
    _showContinueButton = false;
    _isCorrect = false;
    _resultMessage = '';

    notifyListeners();

    // Ensure timer starts properly with a small delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_isWaitingForAnswer) {
        notifyListeners();
      }
    });
  }

  void submitAnswer(int answer) {
    if (!_isWaitingForAnswer) return;

    final correctAnswer = currentQuestion?.correctAnswer ?? 0;
    _isCorrect = answer == correctAnswer;
    _isWaitingForAnswer = false;
    _showResult = true;
    _showContinueButton = true;

    if (_isCorrect) {
      _resultMessage = 'Correct! 🎉';
      _sessionService.answerQuestion(true);
    } else {
      _resultMessage = 'Incorrect. The answer was $correctAnswer';
      _sessionService.answerQuestion(false);
    }

    notifyListeners();
  }

  void onTimeUp() {
    if (_isWaitingForAnswer) {
      final correctAnswer = currentQuestion?.correctAnswer ?? 0;
      _isCorrect = false;
      _isWaitingForAnswer = false;
      _showResult = true;
      _showContinueButton = true;
      _resultMessage = 'Time\'s up! The answer was $correctAnswer';
      _sessionService.answerQuestion(false);

      notifyListeners();
    }
  }

  void hideResultsPopup() {
    _shouldShowResultsPopup = false;
    notifyListeners();
  }

  void resetSession() {
    _sessionService.resetSession();
    _showResult = false;
    _isWaitingForAnswer = false;
    _isSessionComplete = false;
    _shouldShowResultsPopup = false; // Reset popup flag
    _isReadyToStart = true;
    _showContinueButton = false;
    _isCorrect = false;
    _resultMessage = '';
    notifyListeners();
  }

  void restartSession() {
    _sessionService.startNewSession();
    _showResult = false;
    _isWaitingForAnswer = false;
    _isSessionComplete = false;
    _shouldShowResultsPopup = false; // Reset popup flag
    _isReadyToStart = true;
    _showContinueButton = false;
    _isCorrect = false;
    _resultMessage = '';
    notifyListeners();
  }
}
