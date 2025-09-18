import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/math_models.dart';
import '../../../providers/enhanced_drill_provider.dart';
import '../../../routing/app_routes.dart';
import '../../shared/widgets/timer_widget.dart';
import '../../shared/widgets/answer_input_widget.dart';
import '../../shared/widgets/mcq_widget.dart';
import '../../shared/widgets/level_unlock_notification.dart';
import '../../results/view/results_screen.dart';
import '../../../services/difficulty_progression_service.dart';

class EnhancedDrillView extends StatefulWidget {
  final OperationType operationType;
  final QuestionType questionType;
  final DifficultyLevel difficultyLevel;
  final int questionLimit;

  const EnhancedDrillView({
    super.key,
    required this.operationType,
    required this.questionType,
    required this.difficultyLevel,
    required this.questionLimit,
  });

  @override
  State<EnhancedDrillView> createState() => _EnhancedDrillViewState();
}

class _EnhancedDrillViewState extends State<EnhancedDrillView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EnhancedDrillProvider>().startSession(
            operationType: widget.operationType,
            questionType: widget.questionType,
            difficultyLevel: widget.difficultyLevel,
            questionLimit: widget.questionLimit,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final padding = isMobile ? 16.0 : 24.0;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '${widget.operationType.name.toUpperCase()} - ${widget.difficultyLevel.difficultyText}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                fontSize: isMobile ? 16 : 18,
              ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppTheme.textPrimary,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: AppTheme.textPrimary,
                ),
              ),
              onPressed: () =>
                  context.read<EnhancedDrillProvider>().resetSession(),
              tooltip: 'Reset Session',
            ),
          ),
        ],
      ),
      body: Consumer<EnhancedDrillProvider>(
        builder: (context, viewModel, child) {
          // Show results popup only if flag is set
          if (viewModel.shouldShowResultsPopup) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showResultsDialog(context, viewModel);
            });
          }

          // Show level unlock notification
          if (viewModel.newLevelUnlocked) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showLevelUnlockNotification(context, viewModel);
            });
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                children: [
                  // Ready to Start Screen
                  if (viewModel.isReadyToStart) ...[
                    _buildReadyToStartScreen(context, viewModel, isMobile),
                  ] else ...[
                    // Score Display
                    _buildScoreDisplay(context, viewModel, isMobile),

                    SizedBox(height: isMobile ? 24 : 32),

                    // Timer - only show when we have a question and are waiting for answer
                    if (viewModel.currentQuestion != null &&
                        viewModel.isWaitingForAnswer)
                      Center(
                        child: TimerWidget(
                          key: ValueKey(
                              'timer_${viewModel.currentQuestionNumber}_${viewModel.currentQuestion?.timeLimit ?? 3}'),
                          durationSeconds:
                              viewModel.currentQuestion?.timeLimit ?? 3,
                          onTimeUp: viewModel.onTimeUp,
                          onTick: () {},
                          isActive: viewModel.isWaitingForAnswer,
                        ),
                      ),

                    SizedBox(height: isMobile ? 24 : 32),

                    // Question Display
                    if (viewModel.currentQuestion != null) ...[
                      _buildQuestionDisplay(context, viewModel, isMobile),

                      SizedBox(height: isMobile ? 24 : 32),

                      // Result Message
                      if (viewModel.showResult)
                        _buildResultMessage(context, viewModel, isMobile),

                      SizedBox(height: isMobile ? 24 : 32),

                      // Answer Input (Fill in the blank)
                      if (viewModel.isWaitingForAnswer &&
                          viewModel.currentQuestion!.questionType ==
                              QuestionType.fillInBlank)
                        AnswerInputWidget(
                          onAnswerSubmitted: viewModel.submitAnswer,
                          isEnabled: viewModel.isWaitingForAnswer,
                        ),

                      // MCQ Options
                      if (viewModel.isWaitingForAnswer &&
                          viewModel.currentQuestion!.questionType ==
                              QuestionType.multipleChoice)
                        MCQWidget(
                          options: viewModel.currentQuestion!.options!,
                          correctAnswer:
                              viewModel.currentQuestion!.correctAnswer,
                          onAnswerSelected: viewModel.submitAnswer,
                        ),

                      // Continue Button
                      if (viewModel.showContinueButton)
                        _buildContinueButton(context, viewModel, isMobile),

                      SizedBox(height: isMobile ? 24 : 32),
                    ],
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScoreDisplay(
      BuildContext context, EnhancedDrillProvider viewModel, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: isMobile ? 10 : 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScoreItem(
            context,
            'Score',
            '${viewModel.session.score}',
            AppTheme.primaryGreen,
            isMobile,
          ),
          _buildScoreItem(
            context,
            'Questions',
            '${viewModel.currentQuestionNumber}/${viewModel.questionLimit}',
            AppTheme.primaryBlue,
            isMobile,
          ),
          _buildScoreItem(
            context,
            'Accuracy',
            '${(viewModel.session.accuracy * 100).toStringAsFixed(0)}%',
            AppTheme.primaryOrange,
            isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(BuildContext context, String label, String value,
      Color color, bool isMobile) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: isMobile ? 18 : 20,
              ),
        ),
        SizedBox(height: isMobile ? 2 : 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
                fontSize: isMobile ? 10 : 12,
              ),
        ),
      ],
    );
  }

  Widget _buildQuestionDisplay(
      BuildContext context, EnhancedDrillProvider viewModel, bool isMobile) {
    final question = viewModel.currentQuestion!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: isMobile ? 12 : 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Difficulty Badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: _getDifficultyColor(question.difficultyLevel)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
            ),
            child: Text(
              question.difficultyText,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _getDifficultyColor(question.difficultyLevel),
                    fontSize: isMobile ? 12 : 14,
                  ),
            ),
          ),

          SizedBox(height: isMobile ? 16 : 24),

          // Question
          Text(
            question.questionText,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  fontSize: isMobile ? 24 : 32,
                ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: isMobile ? 16 : 24),

          // Visual Question
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildNumberBox(context, question.operand1, isMobile),
              SizedBox(width: isMobile ? 12 : 16),
              Container(
                padding: EdgeInsets.all(isMobile ? 8 : 12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                ),
                child: Text(
                  question.operationSymbol,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryPurple,
                        fontSize: isMobile ? 20 : 24,
                      ),
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              _buildNumberBox(context, question.operand2, isMobile),
              SizedBox(width: isMobile ? 12 : 16),
              Container(
                padding: EdgeInsets.all(isMobile ? 8 : 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                ),
                child: Text(
                  '=',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                        fontSize: isMobile ? 20 : 24,
                      ),
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              Container(
                padding: EdgeInsets.all(isMobile ? 8 : 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  '?',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                        fontSize: isMobile ? 20 : 24,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberBox(BuildContext context, int number, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: AppTheme.primaryPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(
          color: AppTheme.primaryPurple.withOpacity(0.3),
        ),
      ),
      child: Text(
        '$number',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryPurple,
              fontSize: isMobile ? 20 : 24,
            ),
      ),
    );
  }

  Widget _buildResultMessage(
      BuildContext context, EnhancedDrillProvider viewModel, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: viewModel.isCorrect
            ? AppTheme.success.withOpacity(0.1)
            : AppTheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(
          color: viewModel.isCorrect
              ? AppTheme.success.withOpacity(0.3)
              : AppTheme.error.withOpacity(0.3),
        ),
      ),
      child: Text(
        viewModel.resultMessage,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: viewModel.isCorrect ? AppTheme.success : AppTheme.error,
              fontSize: isMobile ? 14 : 16,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return const Color(0xFF4CAF50); // Green
      case DifficultyLevel.easy:
        return AppTheme.success;
      case DifficultyLevel.medium:
        return AppTheme.warning;
      case DifficultyLevel.hard:
        return AppTheme.error;
      case DifficultyLevel.expert:
        return const Color(0xFF9C27B0); // Purple
    }
  }

  void _showResultsDialog(
      BuildContext context, EnhancedDrillProvider viewModel) {
    final accuracy = viewModel.session.totalQuestions > 0
        ? (viewModel.session.correctAnswers /
                viewModel.session.totalQuestions) *
            100
        : 0.0;
    final isBelowHalf = accuracy < 50;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
          ),
          child: Container(
            width: isMobile ? double.infinity : 400,
            padding: EdgeInsets.all(isMobile ? 24 : 32),
            decoration: BoxDecoration(
              color: AppTheme.backgroundCard,
              borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                  decoration: BoxDecoration(
                    gradient: accuracy >= 80
                        ? AppTheme.successGradient
                        : accuracy >= 50
                            ? AppTheme.warningGradient
                            : AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        accuracy >= 80
                            ? Icons.celebration_outlined
                            : accuracy >= 50
                                ? Icons.thumb_up_outlined
                                : Icons.school_outlined,
                        size: isMobile ? 48 : 64,
                        color: Colors.white,
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      Text(
                        accuracy >= 80
                            ? 'Excellent!'
                            : accuracy >= 50
                                ? 'Good Job!'
                                : 'Keep Practicing!',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: isMobile ? 20 : 24,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isMobile ? 4 : 8),
                      Text(
                        '${accuracy.toStringAsFixed(1)}% Accuracy',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w600,
                                  fontSize: isMobile ? 14 : 16,
                                ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isMobile ? 20 : 24),

                // Score Summary
                Row(
                  children: [
                    Expanded(
                      child: _buildDialogScoreItem(
                        context,
                        'Score',
                        '${viewModel.session.score}',
                        AppTheme.primaryGreen,
                        isMobile,
                      ),
                    ),
                    SizedBox(width: isMobile ? 8 : 12),
                    Expanded(
                      child: _buildDialogScoreItem(
                        context,
                        'Correct',
                        '${viewModel.session.correctAnswers}/${viewModel.session.totalQuestions}',
                        AppTheme.primaryBlue,
                        isMobile,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isMobile ? 20 : 24),

                // Performance Message
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  decoration: BoxDecoration(
                    color: accuracy >= 80
                        ? AppTheme.success.withOpacity(0.1)
                        : accuracy >= 50
                            ? AppTheme.warning.withOpacity(0.1)
                            : AppTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                  ),
                  child: Text(
                    accuracy >= 80
                        ? 'Outstanding performance! You\'re ready for harder challenges.'
                        : accuracy >= 50
                            ? 'Great work! A few more practice sessions will make you perfect.'
                            : 'Keep practicing! Focus on the basics and you\'ll improve quickly.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: accuracy >= 80
                              ? AppTheme.success
                              : accuracy >= 50
                                  ? AppTheme.warning
                                  : AppTheme.error,
                          fontWeight: FontWeight.w500,
                          fontSize: isMobile ? 12 : 14,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: isMobile ? 20 : 24),

                // Action Buttons
                Column(
                  children: [
                    // Try Again Button (always show)
                    SizedBox(
                      width: double.infinity,
                      height: isMobile ? 48 : 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          viewModel.hideResultsPopup();
                          viewModel.restartSession();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(isMobile ? 12 : 16),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.refresh_rounded,
                              size: isMobile ? 18 : 20,
                            ),
                            SizedBox(width: isMobile ? 6 : 8),
                            Text(
                              'Try Again',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontSize: isMobile ? 14 : 16,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: isMobile ? 12 : 16),

                    // Go to Home Button
                    SizedBox(
                      width: double.infinity,
                      height: isMobile ? 48 : 52,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          viewModel.hideResultsPopup();
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryPurple,
                          side: BorderSide(color: AppTheme.primaryPurple),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(isMobile ? 12 : 16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.home_outlined,
                              size: isMobile ? 18 : 20,
                            ),
                            SizedBox(width: isMobile ? 6 : 8),
                            Text(
                              'Go to Home',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryPurple,
                                    fontSize: isMobile ? 14 : 16,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogScoreItem(BuildContext context, String label, String value,
      Color color, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: isMobile ? 16 : 18,
                ),
          ),
          SizedBox(height: isMobile ? 2 : 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: isMobile ? 10 : 12,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyToStartScreen(
      BuildContext context, EnhancedDrillProvider viewModel, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withOpacity(0.3),
            blurRadius: isMobile ? 15 : 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
            ),
            child: Icon(
              Icons.play_circle_outline,
              size: isMobile ? 48 : 64,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),
          Text(
            'Ready to Start?',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: isMobile ? 24 : 28,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            '${widget.operationType.name.toUpperCase()} - ${widget.difficultyLevel.difficultyText}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 14 : 16,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 4 : 8),
          Text(
            '${widget.questionLimit} Questions • ${widget.questionType.name.replaceAll('In', ' in ').toUpperCase()}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: isMobile ? 12 : 14,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 24 : 32),
          SizedBox(
            width: double.infinity,
            height: isMobile ? 56 : 64,
            child: ElevatedButton(
              onPressed: () => viewModel.startQuiz(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_arrow_rounded,
                    size: isMobile ? 24 : 28,
                  ),
                  SizedBox(width: isMobile ? 8 : 12),
                  Text(
                    'Start Quiz',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryPurple,
                          fontSize: isMobile ? 16 : 18,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(
      BuildContext context, EnhancedDrillProvider viewModel, bool isMobile) {
    return SizedBox(
      width: double.infinity,
      height: isMobile ? 56 : 64,
      child: ElevatedButton(
        onPressed: () => viewModel.continueToNextQuestion(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.arrow_forward_rounded,
              size: isMobile ? 20 : 24,
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Text(
              'Continue to Next Question',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: isMobile ? 16 : 18,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLevelUnlockNotification(
      BuildContext context, EnhancedDrillProvider viewModel) {
    // Get the next unlocked level (current level + 1)
    final nextLevel = _getNextDifficultyLevel(viewModel.difficultyLevel);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: LevelUnlockNotification(
          unlockedLevel: nextLevel,
          onDismiss: () {
            Navigator.of(context).pop();
            // Reset the flag
            viewModel.resetLevelUnlockedFlag();

            // Force refresh the progression service to notify listeners
            final progressionService =
                Provider.of<DifficultyProgressionService>(context,
                    listen: false);
            progressionService.notifyListeners();
          },
        ),
      ),
    );
  }

  DifficultyLevel _getNextDifficultyLevel(DifficultyLevel currentLevel) {
    switch (currentLevel) {
      case DifficultyLevel.beginner:
        return DifficultyLevel.easy;
      case DifficultyLevel.easy:
        return DifficultyLevel.medium;
      case DifficultyLevel.medium:
        return DifficultyLevel.hard;
      case DifficultyLevel.hard:
        return DifficultyLevel.expert;
      case DifficultyLevel.expert:
        return DifficultyLevel.expert; // No next level
    }
  }
}
