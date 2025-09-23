import 'package:flutter/material.dart';
import '../data/models/math_models.dart';
import '../features/splash/view/splash_screen.dart';
import '../features/enhanced_home/view/enhanced_home_view.dart';
import '../features/enhanced_drill/view/enhanced_drill_view.dart';
import '../features/addition_drill/view/addition_drill_view.dart';
import '../features/multiplication_drill/view/multiplication_drill_view.dart';
import '../features/analytics/view/analytics_dashboard.dart';
import '../features/achievements/view/achievements_screen.dart';
import '../features/auth/view/login_screen.dart';
import '../features/auth/view/signup_screen.dart';
import 'app_routes.dart';

class AppPages {
  // Route builders
  static Widget splashPage(BuildContext context) => const SplashScreen();
  // static Widget homePage(BuildContext context) => const EnhancedHomeView();
  static Widget additionPage(BuildContext context) => const AdditionDrillView();
  static Widget multiplicationPage(BuildContext context) =>
      const MultiplicationDrillView();
  static Widget analyticsPage(BuildContext context) =>
      const AnalyticsDashboard();
  static Widget achievementsPage(BuildContext context) =>
      const AchievementsScreen();
  static Widget loginPage(BuildContext context) => const LoginScreen();
  static Widget signupPage(BuildContext context) => const SignupScreen();

  // Parameterized route builder
  static Widget drillPage(
    BuildContext context, {
    required OperationType operationType,
    required QuestionType questionType,
    required DifficultyLevel difficultyLevel,
    required int questionLimit,
  }) {
    return EnhancedDrillView(
      operationType: operationType,
      questionType: questionType,
      difficultyLevel: difficultyLevel,
      questionLimit: questionLimit,
    );
  }

  // Error page
  static Widget errorPage(BuildContext context, String errorMessage) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed(AppRoutes.home),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
