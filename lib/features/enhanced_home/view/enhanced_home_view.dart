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

                    SizedBox(height: isMobile ? 20 : 30),

                    // Progress & Achievements Section
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildProgressSection(context, isMobile),
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
          'Subtraction',
          Icons.remove_circle_outline,
          AppTheme.warningGradient,
          OperationType.subtraction,
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
        _buildOption(
          context,
          'Division',
          Icons.percent_outlined,
          LinearGradient(colors: [
            AppTheme.primaryBlue,
            AppTheme.primaryBlue.withOpacity(0.7)
          ]),
          OperationType.division,
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
        _buildDifficultyOption(
          context,
          'Beginner',
          'Numbers 0-3, 8s timer',
          Icons.child_care_outlined,
          const Color(0xFF4CAF50), // Green
          DifficultyLevel.beginner,
          isMobile,
        ),
        _buildDifficultyOption(
          context,
          'Easy',
          'Numbers 0-5, 5s timer',
          Icons.sentiment_satisfied_outlined,
          const Color(0xFF8BC34A), // Light Green
          DifficultyLevel.easy,
          isMobile,
        ),
        _buildDifficultyOption(
          context,
          'Medium',
          'Numbers 0-7, 3s timer',
          Icons.sentiment_neutral_outlined,
          const Color(0xFFFF9800), // Orange
          DifficultyLevel.medium,
          isMobile,
        ),
        _buildDifficultyOption(
          context,
          'Hard',
          'Numbers 0-9, 2s timer',
          Icons.sentiment_dissatisfied_outlined,
          const Color(0xFFF44336), // Red
          DifficultyLevel.hard,
          isMobile,
        ),
        _buildDifficultyOption(
          context,
          'Expert',
          'Numbers 0-12, 1s timer',
          Icons.psychology_outlined,
          const Color(0xFF9C27B0), // Purple
          DifficultyLevel.expert,
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

  Widget _buildDifficultyOption(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    DifficultyLevel value,
    bool isMobile,
  ) {
    final isSelected = _selectedDifficulty == value;
    final gradient = LinearGradient(
      colors: [color, color.withOpacity(0.7)],
    );

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
                        : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                  ),
                  child: Icon(
                    icon,
                    size: isMobile ? 20 : 24,
                    color: isSelected ? Colors.white : color,
                  ),
                ),
                SizedBox(width: isMobile ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.textPrimary,
                                  fontSize: isMobile ? 14 : 16,
                                ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.8)
                                  : AppTheme.textSecondary,
                              fontSize: isMobile ? 11 : 12,
                            ),
                      ),
                    ],
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
            'Beginner: 8s, Easy: 5s, Medium: 3s, Hard: 2s, Expert: 1s',
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

  Widget _buildProgressSection(BuildContext context, bool isMobile) {
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
                  color: AppTheme.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: AppTheme.primaryPurple,
                  size: isMobile ? 16 : 20,
                ),
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Text(
                'Track Your Progress',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      fontSize: isMobile ? 16 : 18,
                    ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          Row(
            children: [
              Expanded(
                child: _buildProgressButton(
                  context,
                  'Analytics',
                  Icons.analytics_outlined,
                  AppTheme.primaryBlue,
                  () => Navigator.pushNamed(context, AppRoutes.analytics),
                  isMobile,
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              Expanded(
                child: _buildProgressButton(
                  context,
                  'Achievements',
                  Icons.emoji_events_outlined,
                  AppTheme.primaryOrange,
                  () => Navigator.pushNamed(context, AppRoutes.achievements),
                  isMobile,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isMobile,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isMobile ? 24 : 28,
                ),
              ),
              SizedBox(height: isMobile ? 8 : 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                      fontSize: isMobile ? 14 : 16,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
