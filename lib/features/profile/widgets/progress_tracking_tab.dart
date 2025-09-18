import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/session_history_service.dart';
import '../../../services/gamification_service.dart';
import '../../../data/models/progress_models.dart';
import '../../../data/models/math_models.dart';

class ProgressTrackingTab extends StatefulWidget {
  const ProgressTrackingTab({super.key});

  @override
  State<ProgressTrackingTab> createState() => _ProgressTrackingTabState();
}

class _ProgressTrackingTabState extends State<ProgressTrackingTab> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        children: [
          // Progress Overview
          _buildProgressOverview(context, isMobile),

          SizedBox(height: isMobile ? 24 : 32),

          // Recent Sessions
          _buildRecentSessions(context, isMobile),

          SizedBox(height: isMobile ? 24 : 32),

          // Performance Charts
          _buildPerformanceCharts(context, isMobile),

          SizedBox(height: isMobile ? 24 : 32),

          // Achievements Preview
          _buildAchievementsPreview(context, isMobile),
        ],
      ),
    );
  }

  Widget _buildProgressOverview(BuildContext context, bool isMobile) {
    return Consumer2<SessionHistoryService, GamificationService>(
      builder: (context, historyService, gamificationService, child) {
        return FutureBuilder(
          future: Future.wait([
            historyService.getAllSessions(),
            historyService.getUserProfile(),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: isMobile ? 200 : 240,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundCard,
                  borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Container(
                height: isMobile ? 200 : 240,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundCard,
                  borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: isMobile ? 48 : 64,
                        color: AppTheme.textSecondary,
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      Text(
                        'No progress data yet',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                      ),
                      SizedBox(height: isMobile ? 4 : 8),
                      Text(
                        'Start practicing to see your progress!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final sessions = snapshot.data?[0] as List<SessionRecord>? ?? [];
            final profile = snapshot.data?[1] as UserProfile?;

            final totalSessions = sessions.length;
            final totalQuestions = sessions.fold<int>(
              0,
              (sum, session) => sum + session.totalQuestions,
            );
            final correctAnswers = sessions.fold<int>(
              0,
              (sum, session) => sum + session.correctAnswers,
            );
            final accuracy = totalQuestions > 0
                ? (correctAnswers / totalQuestions * 100).round()
                : 0;

            return Container(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress Overview',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12 : 16,
                          vertical: isMobile ? 6 : 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius:
                              BorderRadius.circular(isMobile ? 16 : 20),
                        ),
                        child: Text(
                          'Level ${profile?.level ?? 1}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 20 : 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildProgressStat(
                          context,
                          'Sessions',
                          totalSessions.toString(),
                          Icons.play_circle_outline,
                          isMobile,
                        ),
                      ),
                      SizedBox(width: isMobile ? 12 : 16),
                      Expanded(
                        child: _buildProgressStat(
                          context,
                          'Questions',
                          totalQuestions.toString(),
                          Icons.quiz_outlined,
                          isMobile,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 12 : 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildProgressStat(
                          context,
                          'Accuracy',
                          '$accuracy%',
                          Icons.gps_fixed,
                          isMobile,
                        ),
                      ),
                      SizedBox(width: isMobile ? 12 : 16),
                      Expanded(
                        child: _buildProgressStat(
                          context,
                          'XP',
                          '${profile?.totalXP ?? 0}',
                          Icons.star,
                          isMobile,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProgressStat(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: isMobile ? 24 : 28,
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: isMobile ? 18 : 22,
                ),
          ),
          SizedBox(height: isMobile ? 4 : 6),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: isMobile ? 12 : 14,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSessions(BuildContext context, bool isMobile) {
    return Consumer<SessionHistoryService>(
      builder: (context, historyService, child) {
        return FutureBuilder<List<SessionRecord>>(
          future: historyService.getAllSessions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: isMobile ? 200 : 240,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundCard,
                  borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return Container(
                padding: EdgeInsets.all(isMobile ? 20 : 24),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundCard,
                  borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Recent Sessions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    SizedBox(height: isMobile ? 20 : 24),
                    Icon(
                      Icons.history,
                      size: isMobile ? 48 : 64,
                      color: AppTheme.textSecondary,
                    ),
                    SizedBox(height: isMobile ? 12 : 16),
                    Text(
                      'No sessions yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    SizedBox(height: isMobile ? 4 : 8),
                    Text(
                      'Start your first math drill!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              );
            }

            final sessions = snapshot.data!.take(5).toList();

            return Container(
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
                    blurRadius: isMobile ? 10 : 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Sessions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to full session history
                        },
                        child: Text(
                          'View All',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.primaryPurple,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 16 : 20),
                  ...sessions.map((session) =>
                      _buildSessionItem(context, session, isMobile)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSessionItem(
      BuildContext context, SessionRecord session, bool isMobile) {
    final accuracy = session.totalQuestions > 0
        ? (session.correctAnswers / session.totalQuestions * 100).round()
        : 0;

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Operation Icon
          Container(
            width: isMobile ? 40 : 48,
            height: isMobile ? 40 : 48,
            decoration: BoxDecoration(
              color: _getOperationColor(session.operationType).withOpacity(0.1),
              borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
            ),
            child: Icon(
              _getOperationIcon(session.operationType),
              color: _getOperationColor(session.operationType),
              size: isMobile ? 20 : 24,
            ),
          ),

          SizedBox(width: isMobile ? 12 : 16),

          // Session Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${session.operationType.name.toUpperCase()} • ${session.difficultyLevel.name.toUpperCase()}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                ),
                SizedBox(height: isMobile ? 4 : 6),
                Text(
                  '${session.correctAnswers}/${session.totalQuestions} correct • $accuracy% accuracy',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                SizedBox(height: isMobile ? 4 : 6),
                Text(
                  _formatDateTime(session.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),

          // Accuracy Badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 8 : 12,
              vertical: isMobile ? 4 : 6,
            ),
            decoration: BoxDecoration(
              color: _getAccuracyColor(accuracy).withOpacity(0.1),
              borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
            ),
            child: Text(
              '$accuracy%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getAccuracyColor(accuracy),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCharts(BuildContext context, bool isMobile) {
    return Container(
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
            blurRadius: isMobile ? 10 : 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Trends',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
          ),

          SizedBox(height: isMobile ? 20 : 24),

          // Weekly Progress Chart Placeholder
          Container(
            height: isMobile ? 200 : 240,
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
              border: Border.all(
                color: Colors.grey.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: isMobile ? 48 : 64,
                    color: AppTheme.textSecondary,
                  ),
                  SizedBox(height: isMobile ? 12 : 16),
                  Text(
                    'Weekly Progress Chart',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  SizedBox(height: isMobile ? 4 : 8),
                  Text(
                    'Coming soon!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
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

  Widget _buildAchievementsPreview(BuildContext context, bool isMobile) {
    return Consumer<SessionHistoryService>(
      builder: (context, historyService, child) {
        return FutureBuilder<UserProfile?>(
          future: historyService.getUserProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: isMobile ? 200 : 240,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundCard,
                  borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final profile = snapshot.data;
            final achievements = profile?.achievements ?? [];

            return Container(
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
                    blurRadius: isMobile ? 10 : 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Achievements',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to achievements screen
                        },
                        child: Text(
                          'View All',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.primaryPurple,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 16 : 20),
                  if (achievements.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.emoji_events_outlined,
                            size: isMobile ? 48 : 64,
                            color: AppTheme.textSecondary,
                          ),
                          SizedBox(height: isMobile ? 12 : 16),
                          Text(
                            'No achievements yet',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                          SizedBox(height: isMobile ? 4 : 8),
                          Text(
                            'Keep practicing to unlock achievements!',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    )
                  else
                    Row(
                      children: achievements.take(3).map((achievement) {
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: isMobile ? 8 : 12),
                            padding: EdgeInsets.all(isMobile ? 16 : 20),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(isMobile ? 12 : 16),
                              border: Border.all(
                                color: Colors.amber.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.emoji_events,
                                  color: Colors.amber,
                                  size: isMobile ? 24 : 28,
                                ),
                                SizedBox(height: isMobile ? 8 : 12),
                                Text(
                                  achievement.type.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppTheme.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getOperationColor(OperationType operationType) {
    switch (operationType) {
      case OperationType.addition:
        return Colors.blue;
      case OperationType.subtraction:
        return Colors.green;
      case OperationType.multiplication:
        return Colors.orange;
      case OperationType.division:
        return Colors.purple;
    }
  }

  IconData _getOperationIcon(OperationType operationType) {
    switch (operationType) {
      case OperationType.addition:
        return Icons.add;
      case OperationType.subtraction:
        return Icons.remove;
      case OperationType.multiplication:
        return Icons.close;
      case OperationType.division:
        return Icons.percent;
    }
  }

  Color _getAccuracyColor(int accuracy) {
    if (accuracy >= 90) return Colors.green;
    if (accuracy >= 70) return Colors.orange;
    return Colors.red;
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
