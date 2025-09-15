import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/math_models.dart';

class ResultsScreen extends StatelessWidget {
  final DrillSession session;
  final OperationType operationType;
  final QuestionType questionType;
  final DifficultyLevel difficultyLevel;
  final int questionLimit;

  const ResultsScreen({
    super.key,
    required this.session,
    required this.operationType,
    required this.questionType,
    required this.difficultyLevel,
    required this.questionLimit,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final padding = isMobile ? 16.0 : 24.0;

    final accuracy = session.totalQuestions > 0
        ? (session.correctAnswers / session.totalQuestions) * 100
        : 0.0;
    final isExcellent = accuracy >= 90;
    final isGood = accuracy >= 70;
    final isAverage = accuracy >= 50;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              SizedBox(height: isMobile ? 20 : 40),

              // Results Header
              _buildResultsHeader(context, isMobile, accuracy),

              SizedBox(height: isMobile ? 30 : 40),

              // Score Cards
              _buildScoreCards(context, isMobile),

              SizedBox(height: isMobile ? 30 : 40),

              // Performance Analysis
              _buildPerformanceAnalysis(
                  context, isMobile, accuracy, isExcellent, isGood, isAverage),

              SizedBox(height: isMobile ? 30 : 40),

              // Action Buttons
              _buildActionButtons(context, isMobile),

              SizedBox(height: isMobile ? 20 : 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsHeader(
      BuildContext context, bool isMobile, double accuracy) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        gradient: accuracy >= 80
            ? AppTheme.successGradient
            : accuracy >= 60
                ? AppTheme.warningGradient
                : AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
        boxShadow: [
          BoxShadow(
            color: (accuracy >= 80
                    ? AppTheme.success
                    : accuracy >= 60
                        ? AppTheme.warning
                        : AppTheme.primaryPurple)
                .withOpacity(0.3),
            blurRadius: isMobile ? 15 : 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            accuracy >= 80
                ? Icons.celebration_outlined
                : accuracy >= 60
                    ? Icons.thumb_up_outlined
                    : Icons.school_outlined,
            size: isMobile ? 48 : 64,
            color: Colors.white,
          ),
          SizedBox(height: isMobile ? 16 : 24),
          Text(
            accuracy >= 80
                ? 'Excellent Work!'
                : accuracy >= 60
                    ? 'Good Job!'
                    : 'Keep Practicing!',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: isMobile ? 24 : 28,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            '${accuracy.toStringAsFixed(1)}% Accuracy',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 18 : 20,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCards(BuildContext context, bool isMobile) {
    return Row(
      children: [
        Expanded(
          child: _buildScoreCard(
            context,
            'Score',
            '${session.score}',
            AppTheme.primaryGreen,
            Icons.star_outline,
            isMobile,
          ),
        ),
        SizedBox(width: isMobile ? 12 : 16),
        Expanded(
          child: _buildScoreCard(
            context,
            'Correct',
            '${session.correctAnswers}',
            AppTheme.primaryBlue,
            Icons.check_circle_outline,
            isMobile,
          ),
        ),
        SizedBox(width: isMobile ? 12 : 16),
        Expanded(
          child: _buildScoreCard(
            context,
            'Total',
            '${session.totalQuestions}',
            AppTheme.primaryPurple,
            Icons.quiz_outlined,
            isMobile,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCard(BuildContext context, String title, String value,
      Color color, IconData icon, bool isMobile) {
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
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 8 : 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
            ),
            child: Icon(
              icon,
              color: color,
              size: isMobile ? 20 : 24,
            ),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: isMobile ? 18 : 20,
                ),
          ),
          SizedBox(height: isMobile ? 4 : 6),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: isMobile ? 10 : 12,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceAnalysis(BuildContext context, bool isMobile,
      double accuracy, bool isExcellent, bool isGood, bool isAverage) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 6 : 8),
                decoration: BoxDecoration(
                  color: AppTheme.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
                ),
                child: Icon(
                  Icons.analytics_outlined,
                  color: AppTheme.info,
                  size: isMobile ? 16 : 20,
                ),
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Text(
                'Performance Analysis',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      fontSize: isMobile ? 16 : 18,
                    ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildAnalysisItem(
            context,
            '${operationType.name.toUpperCase()} Practice',
            'Operation Type',
            isMobile,
          ),
          _buildAnalysisItem(
            context,
            '${questionType.name.replaceAll('In', ' in ').toUpperCase()}',
            'Question Format',
            isMobile,
          ),
          _buildAnalysisItem(
            context,
            '${difficultyLevel.difficultyText} Level',
            'Difficulty',
            isMobile,
          ),
          _buildAnalysisItem(
            context,
            '$questionLimit Questions',
            'Session Length',
            isMobile,
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: isExcellent
                  ? AppTheme.success.withOpacity(0.1)
                  : isGood
                      ? AppTheme.warning.withOpacity(0.1)
                      : AppTheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
            ),
            child: Text(
              isExcellent
                  ? 'Outstanding performance! You\'re ready for harder challenges.'
                  : isGood
                      ? 'Great work! A few more practice sessions will make you perfect.'
                      : 'Keep practicing! Focus on the basics and you\'ll improve quickly.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isExcellent
                        ? AppTheme.success
                        : isGood
                            ? AppTheme.warning
                            : AppTheme.error,
                    fontWeight: FontWeight.w500,
                    fontSize: isMobile ? 12 : 14,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisItem(
      BuildContext context, String value, String label, bool isMobile) {
    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: isMobile ? 12 : 14,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 12 : 14,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isMobile) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: isMobile ? 56 : 64,
          child: ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
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
                  Icons.refresh_rounded,
                  size: isMobile ? 20 : 24,
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Text(
                  'Try Again',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: isMobile ? 16 : 18,
                      ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),
        SizedBox(
          width: double.infinity,
          height: isMobile ? 56 : 64,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryPurple,
              side: BorderSide(color: AppTheme.primaryPurple),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.home_outlined,
                  size: isMobile ? 20 : 24,
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Text(
                  'Back to Home',
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
    );
  }
}
