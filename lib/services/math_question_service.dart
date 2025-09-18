import 'dart:math';
import '../data/models/math_models.dart';

class MathQuestionService {
  static final Random _random = Random();

  MathQuestion generateQuestion({
    required OperationType operation,
    required QuestionType questionType,
    required DifficultyLevel difficultyLevel,
  }) {
    int operand1, operand2;

    // Generate operands based on operation type
    if (operation == OperationType.subtraction) {
      // For subtraction, ensure result is non-negative
      operand1 = _generateOperand(difficultyLevel);
      operand2 = _random.nextInt(operand1 + 1); // operand2 <= operand1
    } else if (operation == OperationType.division) {
      // For division, ensure it divides evenly
      operand2 = _generateOperand(difficultyLevel);
      if (operand2 == 0) operand2 = 1; // Avoid division by zero
      operand1 = operand2 * _generateOperand(difficultyLevel);
    } else {
      // For addition and multiplication, use normal generation
      operand1 = _generateOperand(difficultyLevel);
      operand2 = _generateOperand(difficultyLevel);
    }

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
      case DifficultyLevel.beginner:
        return _random.nextInt(10) + 1; // 1-10 (was 0-3)
      case DifficultyLevel.easy:
        return _random.nextInt(20) + 5; // 5-24 (was 0-5)
      case DifficultyLevel.medium:
        return _random.nextInt(50) + 10; // 10-59 (was 0-7)
      case DifficultyLevel.hard:
        return _random.nextInt(100) + 20; // 20-119 (was 0-9)
      case DifficultyLevel.expert:
        return _random.nextInt(200) + 50; // 50-249 (was 0-12)
    }
  }

  int _calculateAnswer(int a, int b, OperationType operation) {
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

  List<int> _generateMCQOptions(
      int correctAnswer, DifficultyLevel difficultyLevel) {
    final options = <int>[correctAnswer];

    // Generate 3 wrong options
    while (options.length < 4) {
      int wrongOption;
      switch (difficultyLevel) {
        case DifficultyLevel.beginner:
          // Beginner: moderately different (±2-5)
          wrongOption = correctAnswer + (_random.nextInt(8) - 4);
          break;
        case DifficultyLevel.easy:
          // Easy: more varied options (±3-8)
          wrongOption = correctAnswer + (_random.nextInt(16) - 8);
          break;
        case DifficultyLevel.medium:
          // Medium: varied options (±5-15)
          wrongOption = correctAnswer + (_random.nextInt(30) - 15);
          break;
        case DifficultyLevel.hard:
          // Hard: very varied options (±10-25)
          wrongOption = correctAnswer + (_random.nextInt(50) - 25);
          break;
        case DifficultyLevel.expert:
          // Expert: extremely varied options (±20-50)
          wrongOption = correctAnswer + (_random.nextInt(100) - 50);
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
