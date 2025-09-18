import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/progress_models.dart';
import '../../../data/models/math_models.dart';
import '../../../services/session_history_service.dart';
import '../../../services/gamification_service.dart';

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final SessionHistoryService _historyService = SessionHistoryService();
  final GamificationService _gamificationService =
      GamificationService(SessionHistoryService());

  UserProfile? _userProfile;
  List<SessionRecord> _recentSessions = [];
  List<WeakArea> _weakAreas = [];
  List<PerformanceTrend> _weeklyTrend = [];
  Map<String, dynamic>? _statistics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
  }

  void _initializeAnimations() {
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

  Future<void> _loadData() async {
    try {
      final progressSummary = await _gamificationService.getProgressSummary();
      final statistics = await _historyService.getSessionStatistics();

      setState(() {
        _userProfile = progressSummary['profile'] as UserProfile;
        _recentSessions =
            List<SessionRecord>.from(progressSummary['recentSessions']);
        _weakAreas = List<WeakArea>.from(progressSummary['weakAreas']);
        _weeklyTrend =
            List<PerformanceTrend>.from(progressSummary['weeklyTrend']);
        _statistics = statistics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
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

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   title: Text(
      //     'Progress Dashboard',
      //     style: Theme.of(context).textTheme.titleLarge?.copyWith(
      //           fontWeight: FontWeight.w600,
      //           color: AppTheme.textPrimary,
      //           fontSize: isMobile ? 16 : 18,
      //         ),
      //   ),
      //   // leading: IconButton(
      //   //   icon: Container(
      //   //     padding: const EdgeInsets.all(8),
      //   //     decoration: BoxDecoration(
      //   //       color: AppTheme.surfaceElevated,
      //   //       borderRadius: BorderRadius.circular(12),
      //   //     ),
      //   //     child: Icon(
      //   //       Icons.arrow_back_ios_new_rounded,
      //   //       size: 18,
      //   //       color: AppTheme.textPrimary,
      //   //     ),
      //   //   ),
      //   //   onPressed: () => Navigator.pop(context),
      //   // ),
      // ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              // User Profile Card
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildUserProfileCard(context, isMobile),
                ),
              ),

              SizedBox(height: isMobile ? 20 : 30),

              // Level Progress Card
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildLevelProgressCard(context, isMobile),
              ),

              SizedBox(height: isMobile ? 20 : 30),

              // Statistics Cards
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildStatisticsCards(context, isMobile),
              ),

              SizedBox(height: isMobile ? 20 : 30),

              // Recent Sessions
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildRecentSessionsCard(context, isMobile),
              ),

              SizedBox(height: isMobile ? 20 : 30),

              // Weak Areas
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildWeakAreasCard(context, isMobile),
              ),

              SizedBox(height: isMobile ? 20 : 30),

              // Weekly Performance Chart
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildWeeklyPerformanceCard(context, isMobile),
              ),

              SizedBox(height: isMobile ? 20 : 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfileCard(BuildContext context, bool isMobile) {
    if (_userProfile == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                ),
                child: Icon(
                  Icons.person_outline,
                  size: isMobile ? 24 : 32,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level ${_userProfile!.level}',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontSize: isMobile ? 18 : 22,
                              ),
                    ),
                    Text(
                      '${_userProfile!.totalXP} XP',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: isMobile ? 14 : 16,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 12,
                  vertical: isMobile ? 4 : 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                ),
                child: Text(
                  '${_userProfile!.currentStreak} day streak',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: isMobile ? 10 : 12,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgressCard(BuildContext context, bool isMobile) {
    if (_userProfile == null) return const SizedBox.shrink();

    final progressPercentage = (_userProfile!.xpForCurrentLevel /
            (_userProfile!.xpForCurrentLevel + _userProfile!.xpToNextLevel)) *
        100;

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
              Icon(
                Icons.trending_up,
                color: AppTheme.primaryPurple,
                size: isMobile ? 20 : 24,
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Text(
                'Level Progress',
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level ${_userProfile!.level}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      fontSize: isMobile ? 14 : 16,
                    ),
              ),
              Text(
                'Level ${_userProfile!.level + 1}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                      fontSize: isMobile ? 14 : 16,
                    ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 8 : 12),
          LinearProgressIndicator(
            value: progressPercentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
            minHeight: isMobile ? 8 : 10,
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            '${_userProfile!.xpForCurrentLevel} / ${_userProfile!.xpForCurrentLevel + _userProfile!.xpToNextLevel} XP',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: isMobile ? 12 : 14,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(BuildContext context, bool isMobile) {
    if (_statistics == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Sessions',
            '${_statistics!['totalSessions']}',
            AppTheme.primaryBlue,
            Icons.play_circle_outline,
            isMobile,
          ),
        ),
        SizedBox(width: isMobile ? 8 : 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Questions',
            '${_statistics!['totalQuestions']}',
            AppTheme.primaryGreen,
            Icons.quiz_outlined,
            isMobile,
          ),
        ),
        SizedBox(width: isMobile ? 8 : 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Accuracy',
            '${(_statistics!['overallAccuracy'] * 100).toStringAsFixed(1)}%',
            AppTheme.primaryOrange,
            Icons.gps_fixed,
            isMobile,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      Color color, IconData icon, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: isMobile ? 8 : 12,
            offset: const Offset(0, 2),
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
                  fontSize: isMobile ? 16 : 18,
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

  Widget _buildRecentSessionsCard(BuildContext context, bool isMobile) {
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
              Icon(
                Icons.history,
                color: AppTheme.primaryPurple,
                size: isMobile ? 20 : 24,
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Text(
                'Recent Sessions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      fontSize: isMobile ? 16 : 18,
                    ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          if (_recentSessions.isEmpty)
            Center(
              child: Text(
                'No sessions yet. Start practicing!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: isMobile ? 12 : 14,
                    ),
              ),
            )
          else
            ..._recentSessions.take(5).map(
                (session) => _buildSessionItem(context, session, isMobile)),
        ],
      ),
    );
  }

  Widget _buildSessionItem(
      BuildContext context, SessionRecord session, bool isMobile) {
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 6 : 8),
            decoration: BoxDecoration(
              color: _getOperationColor(session.operationType).withOpacity(0.1),
              borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
            ),
            child: Text(
              _getOperationSymbol(session.operationType),
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: _getOperationColor(session.operationType),
              ),
            ),
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${session.operationType.name.toUpperCase()} - ${session.difficultyLevel.name.toUpperCase()}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        fontSize: isMobile ? 12 : 14,
                      ),
                ),
                Text(
                  '${session.correctAnswers}/${session.totalQuestions} • ${(session.accuracy * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: isMobile ? 10 : 12,
                      ),
                ),
              ],
            ),
          ),
          Text(
            _formatDate(session.timestamp),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: isMobile ? 10 : 12,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeakAreasCard(BuildContext context, bool isMobile) {
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
              Icon(
                Icons.warning_outlined,
                color: AppTheme.error,
                size: isMobile ? 20 : 24,
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Text(
                'Areas to Improve',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      fontSize: isMobile ? 16 : 18,
                    ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          if (_weakAreas.isEmpty)
            Center(
              child: Text(
                'Great job! No weak areas identified.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: isMobile ? 12 : 14,
                    ),
              ),
            )
          else
            ..._weakAreas
                .take(3)
                .map((area) => _buildWeakAreaItem(context, area, isMobile)),
        ],
      ),
    );
  }

  Widget _buildWeakAreaItem(
      BuildContext context, WeakArea area, bool isMobile) {
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: AppTheme.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
        border: Border.all(
          color: AppTheme.error.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  area.displayText,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        fontSize: isMobile ? 14 : 16,
                      ),
                ),
                Text(
                  '${area.correctAttempts}/${area.totalAttempts} correct (${(area.accuracy * 100).toStringAsFixed(1)}%)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: isMobile ? 10 : 12,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 6 : 8,
              vertical: isMobile ? 2 : 4,
            ),
            decoration: BoxDecoration(
              color: AppTheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isMobile ? 4 : 6),
            ),
            child: Text(
              '${area.totalAttempts} attempts',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.error,
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 8 : 10,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyPerformanceCard(BuildContext context, bool isMobile) {
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
              Icon(
                Icons.show_chart,
                color: AppTheme.primaryPurple,
                size: isMobile ? 20 : 24,
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Text(
                'Weekly Performance',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      fontSize: isMobile ? 16 : 18,
                    ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          if (_weeklyTrend.isEmpty)
            Center(
              child: Text(
                'No data for this week yet.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: isMobile ? 12 : 14,
                    ),
              ),
            )
          else
            SizedBox(
              height: isMobile ? 120 : 150,
              child: _buildPerformanceChart(context, isMobile),
            ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart(BuildContext context, bool isMobile) {
    final maxAccuracy =
        _weeklyTrend.map((t) => t.accuracy).reduce((a, b) => a > b ? a : b);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: _weeklyTrend.map((trend) {
        final height = maxAccuracy > 0 ? (trend.accuracy / maxAccuracy) : 0.0;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: isMobile ? 20 : 24,
              height: (isMobile ? 80 : 100) * height,
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.7),
                borderRadius: BorderRadius.circular(isMobile ? 4 : 6),
              ),
            ),
            SizedBox(height: isMobile ? 4 : 6),
            Text(
              _getDayName(trend.date.weekday),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: isMobile ? 8 : 10,
                  ),
            ),
            SizedBox(height: isMobile ? 2 : 4),
            Text(
              '${(trend.accuracy * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 8 : 10,
                  ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Color _getOperationColor(OperationType operation) {
    switch (operation) {
      case OperationType.addition:
        return AppTheme.primaryGreen;
      case OperationType.subtraction:
        return AppTheme.primaryOrange;
      case OperationType.multiplication:
        return AppTheme.primaryPurple;
      case OperationType.division:
        return AppTheme.primaryBlue;
    }
  }

  String _getOperationSymbol(OperationType operation) {
    switch (operation) {
      case OperationType.addition:
        return '+';
      case OperationType.subtraction:
        return '-';
      case OperationType.multiplication:
        return '×';
      case OperationType.division:
        return '÷';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';
    return '${date.day}/${date.month}';
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}
