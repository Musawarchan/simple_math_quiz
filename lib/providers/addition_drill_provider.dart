import 'package:flutter/material.dart';
import '../data/models/math_models.dart';
import '../services/math_question_service.dart';
import '../services/drill_session_service.dart';
import '../core/constants/app_constants.dart';

class AdditionDrillProvider extends ChangeNotifier {
  final MathQuestionService _questionService;
  final DrillSessionService _sessionService;

  AdditionDrillProvider({
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

  bool get isWaitingForAnswer => _isWaitingForAnswer;
  bool get showResult => _showResult;
  bool get isCorrect => _isCorrect;
  String get resultMessage => _resultMessage;

  void startSession() {
    _sessionService.startNewSession();
    _generateNewQuestion();
  }

  void _generateNewQuestion() {
    final question = _questionService.generateQuestion(
      operation: OperationType.addition,
      questionType: QuestionType.fillInBlank,
      difficultyLevel: DifficultyLevel.medium,
    );
    _sessionService.setCurrentQuestion(question);

    _isWaitingForAnswer = true;
    _showResult = false;
    notifyListeners();
  }

  void submitAnswer(int answer) {
    if (!_isWaitingForAnswer) return;

    final correctAnswer = currentQuestion?.correctAnswer ?? 0;
    _isCorrect = answer == correctAnswer;
    _isWaitingForAnswer = false;
    _showResult = true;

    if (_isCorrect) {
      _resultMessage = 'Correct! 🎉';
      _sessionService.answerQuestion(true);
    } else {
      _resultMessage = 'Incorrect. The answer was $correctAnswer';
      _sessionService.answerQuestion(false);
    }

    notifyListeners();

    // Show result for 2 seconds, then generate new question
    Future.delayed(
        const Duration(seconds: AppConstants.resultDisplayDurationSeconds), () {
      _generateNewQuestion();
    });
  }

  void onTimeUp() {
    if (_isWaitingForAnswer) {
      final correctAnswer = currentQuestion?.correctAnswer ?? 0;
      _isCorrect = false;
      _isWaitingForAnswer = false;
      _showResult = true;
      _resultMessage = 'Time\'s up! The answer was $correctAnswer';
      _sessionService.answerQuestion(false);

      notifyListeners();

      // Show result for 2 seconds, then generate new question
      Future.delayed(
          const Duration(seconds: AppConstants.resultDisplayDurationSeconds),
          () {
        _generateNewQuestion();
      });
    }
  }

  void resetSession() {
    _sessionService.resetSession();
    _showResult = false;
    _isWaitingForAnswer = false;
    notifyListeners();
    _generateNewQuestion();
  }
}
