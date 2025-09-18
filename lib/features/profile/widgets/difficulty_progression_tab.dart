import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/difficulty_progression_service.dart';
import '../../../data/models/math_models.dart';

class DifficultyProgressionTab extends StatefulWidget {
  const DifficultyProgressionTab({super.key});

  @override
  State<DifficultyProgressionTab> createState() =>
      _DifficultyProgressionTabState();
}

class _DifficultyProgressionTabState extends State<DifficultyProgressionTab> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        children: [
          // Difficulty Overview
          _buildDifficultyOverview(context, isMobile),

          SizedBox(height: isMobile ? 24 : 32),

          // Level Progression Path
          _buildLevelProgressionPath(context, isMobile),

          SizedBox(height: isMobile ? 24 : 32),

          // Requirements Info
          _buildRequirementsInfo(context, isMobile),
        ],
      ),
    );
  }

  Widget _buildDifficultyOverview(BuildContext context, bool isMobile) {
    return Consumer<DifficultyProgressionService>(
      builder: (context, progressionService, child) {
        return FutureBuilder<Map<DifficultyLevel, bool>>(
          future: progressionService.getProgressionState(),
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
                        Icons.lock_outline,
                        size: isMobile ? 48 : 64,
                        color: AppTheme.textSecondary,
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      Text(
                        'Unable to load progression',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final progressionState = snapshot.data!;
            final unlockedLevels =
                progressionState.values.where((unlocked) => unlocked).length;
            final totalLevels = progressionState.length;

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
                        'Difficulty Progression',
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
                          '$unlockedLevels/$totalLevels Unlocked',
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

                  // Progress Bar
                  Container(
                    height: isMobile ? 8 : 12,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(isMobile ? 4 : 6),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: unlockedLevels / totalLevels,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(isMobile ? 4 : 6),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: isMobile ? 16 : 20),

                  Text(
                    'Complete levels with 100% accuracy to unlock the next difficulty!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: isMobile ? 14 : 16,
                        ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLevelProgressionPath(BuildContext context, bool isMobile) {
    return Consumer<DifficultyProgressionService>(
      builder: (context, progressionService, child) {
        return FutureBuilder<Map<DifficultyLevel, bool>>(
          future: progressionService.getProgressionState(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: isMobile ? 300 : 360,
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
                height: isMobile ? 300 : 360,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundCard,
                  borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
                ),
                child: Center(
                  child: Text(
                    'Unable to load progression levels',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ),
              );
            }

            final progressionState = snapshot.data!;
            final levels = DifficultyLevel.values;

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
                    'Level Progression Path',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  SizedBox(height: isMobile ? 20 : 24),
                  ...levels.asMap().entries.map((entry) {
                    final index = entry.key;
                    final level = entry.value;
                    final isUnlocked = progressionState[level] ?? false;
                    final isLast = index == levels.length - 1;

                    return Column(
                      children: [
                        _buildLevelItem(context, level, isUnlocked, isMobile),
                        if (!isLast)
                          _buildConnector(context, isUnlocked, isMobile),
                      ],
                    );
                  }).toList(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLevelItem(BuildContext context, DifficultyLevel level,
      bool isUnlocked, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: isUnlocked
            ? AppTheme.primaryPurple.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(
          color: isUnlocked
              ? AppTheme.primaryPurple.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Level Icon
          Container(
            width: isMobile ? 48 : 56,
            height: isMobile ? 48 : 56,
            decoration: BoxDecoration(
              color: isUnlocked ? AppTheme.primaryPurple : Colors.grey,
              borderRadius: BorderRadius.circular(isMobile ? 24 : 28),
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryPurple.withOpacity(0.3),
                        blurRadius: isMobile ? 8 : 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              isUnlocked ? Icons.check : Icons.lock,
              color: Colors.white,
              size: isMobile ? 24 : 28,
            ),
          ),

          SizedBox(width: isMobile ? 16 : 20),

          // Level Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level.name.toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isUnlocked
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                      ),
                ),
                SizedBox(height: isMobile ? 4 : 6),
                Text(
                  _getLevelDescription(level),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color:
                            isUnlocked ? AppTheme.textSecondary : Colors.grey,
                      ),
                ),
                SizedBox(height: isMobile ? 4 : 6),
                Text(
                  isUnlocked ? 'Unlocked' : 'Locked',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isUnlocked ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 8 : 12,
              vertical: isMobile ? 4 : 6,
            ),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
            ),
            child: Text(
              isUnlocked ? '✓' : '🔒',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isUnlocked ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnector(BuildContext context, bool isUnlocked, bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: isMobile ? 8 : 12),
      child: Row(
        children: [
          SizedBox(width: isMobile ? 24 : 28),
          Container(
            width: 2,
            height: isMobile ? 20 : 24,
            decoration: BoxDecoration(
              color: isUnlocked ? AppTheme.primaryPurple : Colors.grey,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementsInfo(BuildContext context, bool isMobile) {
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
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.primaryPurple,
                size: isMobile ? 24 : 28,
              ),
              SizedBox(width: isMobile ? 12 : 16),
              Text(
                'How to Unlock Levels',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildRequirementItem(
            context,
            'Complete Previous Level',
            'Finish all questions in the current level',
            Icons.check_circle_outline,
            Colors.green,
            isMobile,
          ),
          SizedBox(height: isMobile ? 12 : 16),
          _buildRequirementItem(
            context,
            '100% Accuracy Required',
            'Answer all questions correctly to unlock the next level',
            Icons.gps_fixed,
            Colors.orange,
            isMobile,
          ),
          SizedBox(height: isMobile ? 12 : 16),
          _buildRequirementItem(
            context,
            'Minimum Questions',
            'Complete at least 10 questions per session',
            Icons.quiz_outlined,
            Colors.blue,
            isMobile,
          ),
          SizedBox(height: isMobile ? 20 : 24),
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
              border: Border.all(
                color: Colors.amber.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.amber,
                  size: isMobile ? 20 : 24,
                ),
                SizedBox(width: isMobile ? 12 : 16),
                Expanded(
                  child: Text(
                    'Tip: Practice regularly to improve your accuracy and unlock new levels faster!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    bool isMobile,
  ) {
    return Row(
      children: [
        Container(
          width: isMobile ? 40 : 48,
          height: isMobile ? 40 : 48,
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
        SizedBox(width: isMobile ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
              ),
              SizedBox(height: isMobile ? 4 : 6),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getLevelDescription(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return 'Simple addition and subtraction with small numbers';
      case DifficultyLevel.easy:
        return 'Basic operations with numbers up to 20';
      case DifficultyLevel.medium:
        return 'Mixed operations with numbers up to 100';
      case DifficultyLevel.hard:
        return 'Complex problems with larger numbers';
      case DifficultyLevel.expert:
        return 'Advanced mathematical challenges';
    }
  }
}
