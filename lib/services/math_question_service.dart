import 'dart:math';
import '../data/models/math_models.dart';

class MathQuestionService {
  static final Random _random = Random();

  MathQuestion generateQuestion({
    required OperationType operation,
    required QuestionType questionType,
    required DifficultyLevel difficultyLevel,
  }) {
    final operand1 = _generateOperand(difficultyLevel);
    final operand2 = _generateOperand(difficultyLevel);
    final correctAnswer = _calculateAnswer(operand1, operand2, operation);

    List<int>? options;
    if (questionType == QuestionType.multipleChoice) {
      options = _generateMCQOptions(correctAnswer, difficultyLevel);
    }

    return MathQuestion(
      operand1: operand1,
      operand2: operand2,
      operation: operation,
      questionType: questionType,
      difficultyLevel: difficultyLevel,
      options: options,
    );
  }

  int _generateOperand(DifficultyLevel difficultyLevel) {
    switch (difficultyLevel) {
      case DifficultyLevel.easy:
        return _random.nextInt(6); // 0-5
      case DifficultyLevel.medium:
        return _random.nextInt(8); // 0-7
      case DifficultyLevel.hard:
        return _random.nextInt(10); // 0-9
    }
  }

  int _calculateAnswer(int a, int b, OperationType operation) {
    switch (operation) {
      case OperationType.addition:
        return a + b;
      case OperationType.multiplication:
        return a * b;
    }
  }

  List<int> _generateMCQOptions(
      int correctAnswer, DifficultyLevel difficultyLevel) {
    final options = <int>[correctAnswer];

    // Generate 3 wrong options
    while (options.length < 4) {
      int wrongOption;
      switch (difficultyLevel) {
        case DifficultyLevel.easy:
          // Easy: close to correct answer (±1-2)
          wrongOption = correctAnswer + (_random.nextInt(5) - 2);
          break;
        case DifficultyLevel.medium:
          // Medium: moderately different (±1-3)
          wrongOption = correctAnswer + (_random.nextInt(7) - 3);
          break;
        case DifficultyLevel.hard:
          // Hard: more varied options (±1-5)
          wrongOption = correctAnswer + (_random.nextInt(11) - 5);
          break;
      }

      // Ensure non-negative and not already in options
      if (wrongOption >= 0 && !options.contains(wrongOption)) {
        options.add(wrongOption);
      }
    }

    // Shuffle options
    options.shuffle();
    return options;
  }
}
