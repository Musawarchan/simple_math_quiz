import 'package:flutter/material.dart';
import '../data/models/math_models.dart';
import '../data/models/progress_models.dart';
import '../services/math_question_service.dart';
import '../services/drill_session_service.dart';
import '../services/session_history_service.dart';
import '../services/gamification_service.dart';
import '../services/difficulty_progression_service.dart';

class EnhancedDrillProvider extends ChangeNotifier {
  final MathQuestionService _questionService;
  final DrillSessionService _sessionService;
  final SessionHistoryService _historyService;
  final GamificationService _gamificationService;
  final DifficultyProgressionService _progressionService;

  EnhancedDrillProvider({
    required MathQuestionService questionService,
    required DrillSessionService sessionService,
  })  : _questionService = questionService,
        _sessionService = sessionService,
        _historyService = SessionHistoryService(),
        _gamificationService = GamificationService(SessionHistoryService()),
        _progressionService = DifficultyProgressionService();

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

  // Progress tracking
  List<QuestionAttempt> _questionAttempts = [];
  DateTime? _sessionStartTime;
  int _sessionXP = 0;
  List<AchievementType> _newAchievements = [];
  bool _newLevelUnlocked = false;

  bool get isWaitingForAnswer => _isWaitingForAnswer;
  bool get showResult => _showResult;
  bool get isCorrect => _isCorrect;
  String get resultMessage => _resultMessage;
  bool get isSessionComplete => _isSessionComplete;
  int get questionLimit => _questionLimit;
  DifficultyLevel get difficultyLevel => _currentDifficultyLevel;
  int get currentQuestionNumber => _sessionService.session.totalQuestions;
  bool get isReadyToStart => _isReadyToStart;
  bool get showContinueButton => _showContinueButton;
  bool get shouldShowResultsPopup => _shouldShowResultsPopup;

  // Progress tracking getters
  int get sessionXP => _sessionXP;
  List<AchievementType> get newAchievements => _newAchievements;
  bool get newLevelUnlocked => _newLevelUnlocked;

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

    // Reset progress tracking
    _questionAttempts = [];
    _sessionStartTime = null;
    _sessionXP = 0;
    _newAchievements = [];
    _newLevelUnlocked = false;

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
    _sessionStartTime = DateTime.now();
    _generateNewQuestion();
  }

  void continueToNextQuestion() {
    _showContinueButton = false;
    _showResult = false;

    // Check if session is complete
    if (_sessionService.session.totalQuestions >= _questionLimit) {
      _isSessionComplete = true;
      _shouldShowResultsPopup = true; // Set flag to show popup
      _saveSessionAndUpdateProgress();
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
  }

  void submitAnswer(int answer) {
    if (!_isWaitingForAnswer) return;

    final correctAnswer = currentQuestion?.correctAnswer ?? 0;
    _isCorrect = answer == correctAnswer;
    _isWaitingForAnswer = false;
    _showResult = true;
    _showContinueButton = true;

    // Track question attempt
    if (currentQuestion != null) {
      final attempt = QuestionAttempt(
        operand1: currentQuestion!.operand1,
        operand2: currentQuestion!.operand2,
        operation: currentQuestion!.operation,
        correctAnswer: correctAnswer,
        userAnswer: answer,
        isCorrect: _isCorrect,
        timeSpent: Duration(
            milliseconds:
                3000), // Default time, could be improved with actual timing
        difficultyLevel: currentQuestion!.difficultyLevel,
      );
      _questionAttempts.add(attempt);
    }

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

  void resetLevelUnlockedFlag() {
    _newLevelUnlocked = false;
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up any resources
    super.dispose();
  }

  Future<void> _saveSessionAndUpdateProgress() async {
    if (_sessionStartTime == null) return;

    try {
      // Create session record
      final sessionRecord = SessionRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: _sessionStartTime!,
        operationType: _currentOperationType,
        questionType: _currentQuestionType,
        difficultyLevel: _currentDifficultyLevel,
        totalQuestions: _sessionService.session.totalQuestions,
        correctAnswers: _sessionService.session.correctAnswers,
        score: _sessionService.session.score,
        accuracy: _sessionService.session.accuracy,
        totalTime: DateTime.now().difference(_sessionStartTime!),
        questionAttempts: _questionAttempts,
      );

      // Save session to history
      await _historyService.saveSession(sessionRecord);

      // Update user profile and check achievements
      final updatedProfile =
          await _gamificationService.updateProfileWithSession(sessionRecord);
      _sessionXP = updatedProfile.totalXP -
          (updatedProfile.totalXP -
              await _gamificationService.calculateSessionXP(sessionRecord));

      // Check for new achievements
      final newAchievements =
          await _gamificationService.checkAchievements(sessionRecord);
      _newAchievements = newAchievements;

      // Check for level unlocking
      _newLevelUnlocked = await _progressionService.processSessionCompletion(
        completedLevel: _currentDifficultyLevel,
        accuracy: sessionRecord.accuracy,
        totalQuestions: sessionRecord.totalQuestions,
      );

      // If a new level was unlocked, update to the next unlocked level
      if (_newLevelUnlocked) {
        final nextUnlockedLevel =
            await _progressionService.getHighestUnlockedLevel();
        _currentDifficultyLevel = nextUnlockedLevel;
      }
    } catch (e) {
      // Handle error silently for now
      print('Error saving session: $e');
    }
  }
}
