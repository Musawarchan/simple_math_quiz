import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/math_models.dart';
import '../../../routing/app_routes.dart';

class EnhancedHomeView extends StatefulWidget {
  const EnhancedHomeView({super.key});

  @override
  State<EnhancedHomeView> createState() => _EnhancedHomeViewState();
}

class _EnhancedHomeViewState extends State<EnhancedHomeView>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  OperationType _selectedOperation = OperationType.addition;
  QuestionType _selectedQuestionType = QuestionType.fillInBlank;
  DifficultyLevel _selectedDifficulty = DifficultyLevel.medium;
  int _selectedQuestionLimit = 10;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final padding = isMobile ? 16.0 : 24.0;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - (padding * 2),
                ),
                child: Column(
                  children: [
                    SizedBox(height: isMobile ? 20 : 40),

                    // Hero Section
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildHeroSection(context, isMobile),
                      ),
                    ),

                    SizedBox(height: isMobile ? 30 : 60),

                    // Operation Selection
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildOperationSelection(context, isMobile),
                    ),

                    SizedBox(height: isMobile ? 20 : 30),

                    // Question Type Selection
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildQuestionTypeSelection(context, isMobile),
                    ),

                    SizedBox(height: isMobile ? 20 : 30),

                    // Difficulty Selection
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildDifficultySelection(context, isMobile),
                    ),

                    SizedBox(height: isMobile ? 20 : 30),

                    // Question Limit Selection
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildQuestionLimitSelection(context, isMobile),
                    ),

                    SizedBox(height: isMobile ? 30 : 40),

                    // Start Button
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildStartButton(context, isMobile),
                    ),

                    SizedBox(height: isMobile ? 30 : 40),

                    // Instructions Card
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildInstructionsCard(context, isMobile),
                    ),

                    SizedBox(height: isMobile ? 16 : 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isMobile) {
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
              Icons.school_outlined,
              size: isMobile ? 48 : 64,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),
          Text(
            'Math Drill Master',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: isMobile ? 24 : 28,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            'Choose your challenge level',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                  fontSize: isMobile ? 14 : 16,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOperationSelection(BuildContext context, bool isMobile) {
    return _buildSelectionCard(
      context,
      'Operation Type',
      [
        _buildOption(
          context,
          'Addition',
          Icons.add_circle_outline,
          AppTheme.successGradient,
          OperationType.addition,
          isMobile,
        ),
        _buildOption(
          context,
          'Multiplication',
          Icons.close_rounded,
          AppTheme.primaryGradient,
          OperationType.multiplication,
          isMobile,
        ),
      ],
      isMobile,
    );
  }

  Widget _buildQuestionTypeSelection(BuildContext context, bool isMobile) {
    return _buildSelectionCard(
      context,
      'Question Type',
      [
        _buildOption(
          context,
          'Fill in Blank',
          Icons.edit_outlined,
          AppTheme.warningGradient,
          QuestionType.fillInBlank,
          isMobile,
        ),
        _buildOption(
          context,
          'Multiple Choice',
          Icons.quiz_outlined,
          AppTheme.primaryGradient,
          QuestionType.multipleChoice,
          isMobile,
        ),
      ],
      isMobile,
    );
  }

  Widget _buildDifficultySelection(BuildContext context, bool isMobile) {
    return _buildSelectionCard(
      context,
      'Difficulty Level',
      [
        _buildOption(
          context,
          'Easy (5s)',
          Icons.sentiment_satisfied_outlined,
          LinearGradient(
              colors: [AppTheme.success, AppTheme.success.withOpacity(0.7)]),
          DifficultyLevel.easy,
          isMobile,
        ),
        _buildOption(
          context,
          'Medium (3s)',
          Icons.sentiment_neutral_outlined,
          LinearGradient(
              colors: [AppTheme.warning, AppTheme.warning.withOpacity(0.7)]),
          DifficultyLevel.medium,
          isMobile,
        ),
        _buildOption(
          context,
          'Hard (2s)',
          Icons.sentiment_dissatisfied_outlined,
          LinearGradient(
              colors: [AppTheme.error, AppTheme.error.withOpacity(0.7)]),
          DifficultyLevel.hard,
          isMobile,
        ),
      ],
      isMobile,
    );
  }

  Widget _buildQuestionLimitSelection(BuildContext context, bool isMobile) {
    return _buildSelectionCard(
      context,
      'Number of Questions',
      [
        _buildOption(
          context,
          '5 Questions',
          Icons.looks_5_outlined,
          LinearGradient(colors: [
            AppTheme.primaryBlue,
            AppTheme.primaryBlue.withOpacity(0.7)
          ]),
          5,
          isMobile,
        ),
        _buildOption(
          context,
          '10 Questions',
          Icons.looks_one_outlined,
          LinearGradient(colors: [
            AppTheme.primaryPurple,
            AppTheme.primaryPurple.withOpacity(0.7)
          ]),
          10,
          isMobile,
        ),
        _buildOption(
          context,
          '15 Questions',
          Icons.looks_two_outlined,
          LinearGradient(colors: [
            AppTheme.primaryGreen,
            AppTheme.primaryGreen.withOpacity(0.7)
          ]),
          15,
          isMobile,
        ),
        _buildOption(
          context,
          '20 Questions',
          Icons.looks_3_outlined,
          LinearGradient(colors: [
            AppTheme.primaryOrange,
            AppTheme.primaryOrange.withOpacity(0.7)
          ]),
          20,
          isMobile,
        ),
      ],
      isMobile,
    );
  }

  Widget _buildSelectionCard(
      BuildContext context, String title, List<Widget> options, bool isMobile) {
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
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                  fontSize: isMobile ? 16 : 18,
                ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          ...options,
        ],
      ),
    );
  }

  Widget _buildOption<T>(
    BuildContext context,
    String title,
    IconData icon,
    LinearGradient gradient,
    T value,
    bool isMobile,
  ) {
    bool isSelected = false;
    if (value is OperationType) {
      isSelected = _selectedOperation == value;
    } else if (value is QuestionType) {
      isSelected = _selectedQuestionType == value;
    } else if (value is DifficultyLevel) {
      isSelected = _selectedDifficulty == value;
    } else if (value is int) {
      isSelected = _selectedQuestionLimit == value;
    }

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _setSelectedValue(value),
          borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              gradient: isSelected ? gradient : null,
              color: isSelected ? null : AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isMobile ? 8 : 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : gradient.colors.first.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                  ),
                  child: Icon(
                    icon,
                    size: isMobile ? 20 : 24,
                    color: isSelected ? Colors.white : gradient.colors.first,
                  ),
                ),
                SizedBox(width: isMobile ? 12 : 16),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color:
                              isSelected ? Colors.white : AppTheme.textPrimary,
                          fontSize: isMobile ? 14 : 16,
                        ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: isMobile ? 20 : 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, bool isMobile) {
    return SizedBox(
      width: double.infinity,
      height: isMobile ? 56 : 64,
      child: ElevatedButton(
        onPressed: _startDrill,
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
              Icons.play_arrow_rounded,
              size: isMobile ? 24 : 28,
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Text(
              'Start Practice',
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

  Widget _buildInstructionsCard(BuildContext context, bool isMobile) {
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
                  Icons.lightbulb_outline,
                  color: AppTheme.info,
                  size: isMobile ? 16 : 20,
                ),
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Text(
                'How to Play',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      fontSize: isMobile ? 16 : 18,
                    ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          _buildInstructionItem(
            context,
            '⏱️',
            'Answer within the time limit',
            'Easy: 5s, Medium: 3s, Hard: 2s',
            isMobile,
          ),
          SizedBox(height: isMobile ? 8 : 12),
          _buildInstructionItem(
            context,
            '🎯',
            'Earn points for correct answers',
            'Track your progress in real-time',
            isMobile,
          ),
          SizedBox(height: isMobile ? 8 : 12),
          _buildInstructionItem(
            context,
            '🔄',
            'Practice makes perfect',
            'Reset anytime to start fresh',
            isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(
    BuildContext context,
    String emoji,
    String title,
    String subtitle,
    bool isMobile,
  ) {
    return Row(
      children: [
        Text(
          emoji,
          style: TextStyle(fontSize: isMobile ? 16 : 20),
        ),
        SizedBox(width: isMobile ? 8 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      fontSize: isMobile ? 14 : 16,
                    ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: isMobile ? 11 : 12,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _setSelectedValue<T>(T value) {
    setState(() {
      if (value is OperationType) {
        _selectedOperation = value;
      } else if (value is QuestionType) {
        _selectedQuestionType = value;
      } else if (value is DifficultyLevel) {
        _selectedDifficulty = value;
      } else if (value is int) {
        _selectedQuestionLimit = value;
      }
    });
  }

  void _startDrill() {
    Navigator.pushNamed(
      context,
      AppRoutes.drillRoute,
      arguments: {
        'operationType': _selectedOperation,
        'questionType': _selectedQuestionType,
        'difficultyLevel': _selectedDifficulty,
        'questionLimit': _selectedQuestionLimit,
      },
    );
  }
}
