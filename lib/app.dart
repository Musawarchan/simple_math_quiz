import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'routing/app_pages.dart';
import 'routing/app_routes.dart';
import 'services/math_question_service.dart';
import 'services/drill_session_service.dart';
import 'services/session_history_service.dart';
import 'services/gamification_service.dart';
import 'services/difficulty_progression_service.dart';
import 'services/auth_service.dart';
import 'providers/enhanced_drill_provider.dart';
import 'providers/auth_provider.dart';
import 'features/auth/widgets/auth_wrapper.dart';

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
        Provider<DifficultyProgressionService>(
          create: (_) => DifficultyProgressionService(),
        ),
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),

        // Providers
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(),
        ),
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
        home: const AuthWrapper(),
     
        routes: {
          AppRoutes.addition: (context) => AppPages.additionPage(context),
          AppRoutes.multiplication: (context) =>
              AppPages.multiplicationPage(context),
          AppRoutes.analytics: (context) => AppPages.analyticsPage(context),
          AppRoutes.achievements: (context) =>
              AppPages.achievementsPage(context),
          AppRoutes.login: (context) => AppPages.loginPage(context),
          AppRoutes.signup: (context) => AppPages.signupPage(context),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
