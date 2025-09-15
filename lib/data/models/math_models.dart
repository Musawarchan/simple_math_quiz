enum OperationType { addition, multiplication }

enum QuestionType { fillInBlank, multipleChoice }

enum DifficultyLevel { easy, medium, hard }

class MathQuestion {
  final int operand1;
  final int operand2;
  final OperationType operation;
  final int correctAnswer;
  final QuestionType questionType;
  final DifficultyLevel difficultyLevel;
  final List<int>? options; // For MCQ

  MathQuestion({
    required this.operand1,
    required this.operand2,
    required this.operation,
    required this.questionType,
    required this.difficultyLevel,
    this.options,
  }) : correctAnswer = _calculateAnswer(operand1, operand2, operation);

  static int _calculateAnswer(int a, int b, OperationType operation) {
    switch (operation) {
      case OperationType.addition:
        return a + b;
      case OperationType.multiplication:
        return a * b;
    }
  }

  String get questionText {
    switch (operation) {
      case OperationType.addition:
        return '$operand1 + $operand2 = ?';
      case OperationType.multiplication:
        return '$operand1 × $operand2 = ?';
    }
  }

  String get operationSymbol {
    switch (operation) {
      case OperationType.addition:
        return '+';
      case OperationType.multiplication:
        return '×';
    }
  }

  String get difficultyText {
    switch (difficultyLevel) {
      case DifficultyLevel.easy:
        return 'Easy';
      case DifficultyLevel.medium:
        return 'Medium';
      case DifficultyLevel.hard:
        return 'Hard';
    }
  }

  int get timeLimit {
    switch (difficultyLevel) {
      case DifficultyLevel.easy:
        return 5; // 5 seconds for easy
      case DifficultyLevel.medium:
        return 3; // 3 seconds for medium
      case DifficultyLevel.hard:
        return 2; // 2 seconds for hard
    }
  }
}

extension DifficultyLevelExtension on DifficultyLevel {
  String get difficultyText {
    switch (this) {
      case DifficultyLevel.easy:
        return 'Easy';
      case DifficultyLevel.medium:
        return 'Medium';
      case DifficultyLevel.hard:
        return 'Hard';
    }
  }
}

class DrillSession {
  int score = 0;
  int totalQuestions = 0;
  int correctAnswers = 0;
  bool isActive = false;
  MathQuestion? currentQuestion;

  void reset() {
    score = 0;
    totalQuestions = 0;
    correctAnswers = 0;
    isActive = false;
    currentQuestion = null;
  }

  void startSession() {
    isActive = true;
  }

  void stopSession() {
    isActive = false;
  }

  void answerQuestion(bool isCorrect) {
    totalQuestions++;
    if (isCorrect) {
      correctAnswers++;
      score++;
    }
  }

  double get accuracy {
    if (totalQuestions == 0) return 0.0;
    return correctAnswers / totalQuestions;
  }
}
