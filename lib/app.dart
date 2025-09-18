import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'routing/app_pages.dart';
import 'routing/app_routes.dart';
import 'services/math_question_service.dart';
import 'services/drill_session_service.dart';
import 'services/session_history_service.dart';
import 'services/gamification_service.dart';
import 'providers/enhanced_drill_provider.dart';

class MathDrillApp extends StatelessWidget {
  const MathDrillApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider<MathQuestionService>(
          create: (_) => MathQuestionService(),
        ),
        Provider<DrillSessionService>(
          create: (_) => DrillSessionService(),
        ),
        Provider<SessionHistoryService>(
          create: (_) => SessionHistoryService(),
        ),
        Provider<GamificationService>(
          create: (context) =>
              GamificationService(context.read<SessionHistoryService>()),
        ),

        // Providers
        ChangeNotifierProxyProvider2<MathQuestionService, DrillSessionService,
            EnhancedDrillProvider>(
          create: (context) => EnhancedDrillProvider(
            questionService: context.read<MathQuestionService>(),
            sessionService: context.read<DrillSessionService>(),
          ),
          update: (context, questionService, sessionService, previous) {
            return previous ??
                EnhancedDrillProvider(
                  questionService: questionService,
                  sessionService: sessionService,
                );
          },
        ),
      ],
      child: MaterialApp(
        title: 'Math Drill MVP',
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (context) => AppPages.splashPage(context),
          AppRoutes.home: (context) => AppPages.homePage(context),
          AppRoutes.addition: (context) => AppPages.additionPage(context),
          AppRoutes.multiplication: (context) =>
              AppPages.multiplicationPage(context),
          AppRoutes.analytics: (context) => AppPages.analyticsPage(context),
          AppRoutes.achievements: (context) =>
              AppPages.achievementsPage(context),
        },
        onGenerateRoute: (settings) {
          // Handle parameterized routes
          if (settings.name == AppRoutes.drillRoute) {
            final args = settings.arguments as Map<String, dynamic>?;
            if (args != null) {
              return MaterialPageRoute(
                builder: (context) => AppPages.drillPage(
                  context,
                  operationType: args['operationType'],
                  questionType: args['questionType'],
                  difficultyLevel: args['difficultyLevel'],
                  questionLimit: args['questionLimit'],
                ),
                settings: settings,
              );
            }
          }

          // Handle unknown routes
          return MaterialPageRoute(
            builder: (context) => AppPages.errorPage(
              context,
              'The requested page "${settings.name}" does not exist.',
            ),
            settings: settings,
          );
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
