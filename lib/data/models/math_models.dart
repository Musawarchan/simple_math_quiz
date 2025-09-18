enum OperationType { addition, subtraction, multiplication, division }

enum QuestionType { fillInBlank, multipleChoice }

enum DifficultyLevel {
  beginner, // 0-3, 8s timer
  easy, // 0-5, 5s timer
  medium, // 0-7, 3s timer
  hard, // 0-9, 2s timer
  expert // 0-12, 1s timer
}

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
      case OperationType.subtraction:
        return a - b;
      case OperationType.multiplication:
        return a * b;
      case OperationType.division:
        return a ~/ b; // Integer division
    }
  }

  String get questionText {
    switch (operation) {
      case OperationType.addition:
        return '$operand1 + $operand2 = ?';
      case OperationType.subtraction:
        return '$operand1 - $operand2 = ?';
      case OperationType.multiplication:
        return '$operand1 × $operand2 = ?';
      case OperationType.division:
        return '$operand1 ÷ $operand2 = ?';
    }
  }

  String get operationSymbol {
    switch (operation) {
      case OperationType.addition:
        return '+';
      case OperationType.subtraction:
        return '-';
      case OperationType.multiplication:
        return '×';
      case OperationType.division:
        return '÷';
    }
  }

  String get difficultyText {
    switch (difficultyLevel) {
      case DifficultyLevel.beginner:
        return 'Beginner';
      case DifficultyLevel.easy:
        return 'Easy';
      case DifficultyLevel.medium:
        return 'Medium';
      case DifficultyLevel.hard:
        return 'Hard';
      case DifficultyLevel.expert:
        return 'Expert';
    }
  }

  int get timeLimit {
    switch (difficultyLevel) {
      case DifficultyLevel.beginner:
        return 8; // 8 seconds for beginner
      case DifficultyLevel.easy:
        return 5; // 5 seconds for easy
      case DifficultyLevel.medium:
        return 3; // 3 seconds for medium
      case DifficultyLevel.hard:
        return 2; // 2 seconds for hard
      case DifficultyLevel.expert:
        return 1; // 1 second for expert
    }
  }
}

extension DifficultyLevelExtension on DifficultyLevel {
  String get difficultyText {
    switch (this) {
      case DifficultyLevel.beginner:
        return 'Beginner';
      case DifficultyLevel.easy:
        return 'Easy';
      case DifficultyLevel.medium:
        return 'Medium';
      case DifficultyLevel.hard:
        return 'Hard';
      case DifficultyLevel.expert:
        return 'Expert';
    }
  }

  String get description {
    switch (this) {
      case DifficultyLevel.beginner:
        return 'Numbers 0-3, 8s timer';
      case DifficultyLevel.easy:
        return 'Numbers 0-5, 5s timer';
      case DifficultyLevel.medium:
        return 'Numbers 0-7, 3s timer';
      case DifficultyLevel.hard:
        return 'Numbers 0-9, 2s timer';
      case DifficultyLevel.expert:
        return 'Numbers 0-12, 1s timer';
    }
  }

  int get maxNumber {
    switch (this) {
      case DifficultyLevel.beginner:
        return 3;
      case DifficultyLevel.easy:
        return 5;
      case DifficultyLevel.medium:
        return 7;
      case DifficultyLevel.hard:
        return 9;
      case DifficultyLevel.expert:
        return 12;
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
