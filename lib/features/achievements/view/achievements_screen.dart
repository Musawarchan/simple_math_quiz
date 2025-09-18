import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/progress_models.dart';
import '../../../services/session_history_service.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _staggerAnimation;

  final SessionHistoryService _historyService = SessionHistoryService();
  List<Achievement> _achievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadAchievements();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _staggerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _staggerController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _staggerController.forward();
  }

  Future<void> _loadAchievements() async {
    try {
      final achievements = await _historyService.getAchievements();
      setState(() {
        _achievements = achievements;
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
    _staggerController.dispose();
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

    final unlockedAchievements =
        _achievements.where((a) => a.isUnlocked).toList();
    final lockedAchievements =
        _achievements.where((a) => !a.isUnlocked).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Achievements',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                fontSize: isMobile ? 16 : 18,
              ),
        ),
        // leading: IconButton(
        //   icon: Container(
        //     padding: const EdgeInsets.all(8),
        //     decoration: BoxDecoration(
        //       color: AppTheme.surfaceElevated,
        //       borderRadius: BorderRadius.circular(12),
        //     ),
        //     child: Icon(
        //       Icons.arrow_back_ios_new_rounded,
        //       size: 18,
        //       color: AppTheme.textPrimary,
        //     ),
        //   ),
        //   onPressed: () => Navigator.pop(context),
        // ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              // Progress Header
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildProgressHeader(context, isMobile,
                    unlockedAchievements.length, _achievements.length),
              ),

              SizedBox(height: isMobile ? 20 : 30),

              // Unlocked Achievements
              if (unlockedAchievements.isNotEmpty) ...[
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildSectionHeader(context, 'Unlocked Achievements',
                      unlockedAchievements.length, isMobile),
                ),
                SizedBox(height: isMobile ? 16 : 20),
                _buildAchievementsGrid(
                    context, unlockedAchievements, isMobile, true),
                SizedBox(height: isMobile ? 30 : 40),
              ],

              // Locked Achievements
              if (lockedAchievements.isNotEmpty) ...[
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildSectionHeader(context, 'Lock Achievements',
                      lockedAchievements.length, isMobile),
                ),
                SizedBox(height: isMobile ? 16 : 20),
                _buildAchievementsGrid(
                    context, lockedAchievements, isMobile, false),
                SizedBox(height: isMobile ? 20 : 30),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHeader(
      BuildContext context, bool isMobile, int unlocked, int total) {
    final progressPercentage = total > 0 ? (unlocked / total) * 100 : 0.0;

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
                  Icons.emoji_events_outlined,
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
                      'Achievement Progress',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontSize: isMobile ? 18 : 22,
                              ),
                    ),
                    Text(
                      '$unlocked of $total achievements unlocked',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: isMobile ? 14 : 16,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          LinearProgressIndicator(
            value: progressPercentage / 100,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: isMobile ? 8 : 10,
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            '${progressPercentage.toStringAsFixed(1)}% Complete',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 14 : 16,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, int count, bool isMobile) {
    return Row(
      children: [
        Icon(
          title.contains('Unlocked')
              ? Icons.check_circle_outline
              : Icons.lock_outline,
          color: title.contains('Unlocked')
              ? AppTheme.primaryGreen
              : AppTheme.textSecondary,
          size: isMobile ? 20 : 24,
        ),
        SizedBox(width: isMobile ? 8 : 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                fontSize: isMobile ? 16 : 18,
              ),
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : 12,
            vertical: isMobile ? 4 : 6,
          ),
          decoration: BoxDecoration(
            color: title.contains('Unlocked')
                ? AppTheme.primaryGreen.withOpacity(0.1)
                : AppTheme.textSecondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
          ),
          child: Text(
            '$count',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: title.contains('Unlocked')
                      ? AppTheme.primaryGreen
                      : AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 12 : 14,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsGrid(BuildContext context,
      List<Achievement> achievements, bool isMobile, bool isUnlocked) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 3,
        crossAxisSpacing: isMobile ? 12 : 16,
        mainAxisSpacing: isMobile ? 12 : 16,
        childAspectRatio: isMobile ? 0.8 : 0.9,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _staggerAnimation,
          builder: (context, child) {
            final delay = index * 0.1;
            final animationValue =
                (_staggerAnimation.value - delay).clamp(0.0, 1.0);

            return Transform.scale(
              scale: animationValue,
              child: Opacity(
                opacity: animationValue,
                child: _buildAchievementCard(
                    context, achievements[index], isMobile, isUnlocked),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAchievementCard(BuildContext context, Achievement achievement,
      bool isMobile, bool isUnlocked) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: isUnlocked ? AppTheme.backgroundCard : AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(
          color: isUnlocked
              ? AppTheme.primaryGreen.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
          width: isUnlocked ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isUnlocked
                ? AppTheme.primaryGreen.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            blurRadius: isMobile ? 8 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Achievement Icon
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? AppTheme.primaryGreen.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              achievement.icon,
              style: TextStyle(
                fontSize: isMobile ? 32 : 40,
                color: isUnlocked ? AppTheme.primaryGreen : Colors.grey,
              ),
            ),
          ),

          SizedBox(height: isMobile ? 12 : 16),

          // Achievement Title
          Text(
            achievement.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isUnlocked
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary,
                  fontSize: isMobile ? 14 : 16,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: isMobile ? 8 : 12),

          // Achievement Description
          Text(
            achievement.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isUnlocked ? AppTheme.textSecondary : Colors.grey,
                  fontSize: isMobile ? 10 : 12,
                ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: isMobile ? 8 : 12),

          // Points and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 6 : 8,
                  vertical: isMobile ? 2 : 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isMobile ? 4 : 6),
                ),
                child: Text(
                  '${achievement.points} XP',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryPurple,
                        fontWeight: FontWeight.w600,
                        fontSize: isMobile ? 8 : 10,
                      ),
                ),
              ),
              if (isUnlocked && achievement.unlockedAt != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 6 : 8,
                    vertical: isMobile ? 2 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isMobile ? 4 : 6),
                  ),
                  child: Text(
                    'Unlocked',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                          fontSize: isMobile ? 8 : 10,
                        ),
                  ),
                ),
            ],
          ),

          if (isUnlocked && achievement.unlockedAt != null) ...[
            SizedBox(height: isMobile ? 4 : 6),
            Text(
              _formatUnlockDate(achievement.unlockedAt!),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: isMobile ? 8 : 10,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatUnlockDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Unlocked today';
    if (difference == 1) return 'Unlocked yesterday';
    if (difference < 7) return 'Unlocked $difference days ago';
    if (difference < 30)
      return 'Unlocked ${(difference / 7).floor()} weeks ago';
    return 'Unlocked ${(difference / 30).floor()} months ago';
  }
}
