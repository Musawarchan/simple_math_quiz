class AppConstants {
  // Game settings
  static const int timerDurationSeconds = 3;
  static const int maxNumber = 9;
  static const int minNumber = 0;
  static const int pointsPerCorrectAnswer = 1;
  static const int resultDisplayDurationSeconds = 2;

  // UI constants
  static const double defaultPadding = 24.0;
  static const double cardPadding = 20.0;
  static const double borderRadius = 16.0;
  static const double smallBorderRadius = 12.0;
  static const double largeBorderRadius = 20.0;

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Routes
  static const String splashRoute = '/splash';
  static const String homeRoute = '/';
  static const String additionRoute = '/addition';
  static const String multiplicationRoute = '/multiplication';
  static const String drillRoute = '/drill';
}
