import 'dart:math';
import '../constants/app_constants.dart';

class MathUtils {
  static final Random _random = Random();

  /// Generates a random number between min and max (inclusive)
  static int generateRandomNumber(int min, int max) {
    return min + _random.nextInt(max - min + 1);
  }

  /// Calculates the correct answer for a math operation
  static int calculateAnswer(int operand1, int operand2, String operation) {
    switch (operation) {
      case '+':
        return operand1 + operand2;
      case '×':
        return operand1 * operand2;
      case '-':
        return operand1 - operand2;
      case '÷':
        return operand1 ~/ operand2;
      default:
        throw ArgumentError('Unsupported operation: $operation');
    }
  }

  /// Formats accuracy as a percentage string
  static String formatAccuracy(double accuracy) {
    return '${(accuracy * 100).toStringAsFixed(0)}%';
  }

  /// Validates if a number is within the allowed range
  static bool isValidNumber(int number) {
    return number >= AppConstants.minNumber && number <= AppConstants.maxNumber;
  }
}
