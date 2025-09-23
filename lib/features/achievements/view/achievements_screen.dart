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
          padding: EdgeInsets.only(left: padding, right: padding),
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
        crossAxisSpacing: isMobile ? 16 : 20,
        mainAxisSpacing: isMobile ? 16 : 20,
        childAspectRatio: isMobile ? 0.740 : 0.85,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _staggerAnimation,
          builder: (context, child) {
            final delay = index * 0.1;
            final animationValue =
                (_staggerAnimation.value - delay).clamp(0.0, 1.0);

            return
                // Transform.scale(
                // scale: animationValue,
                // child: Opacity(
                //   opacity: animationValue,
                //   child:

                _buildAchievementCard(
                    context, achievements[index], isMobile, isUnlocked);
            // ),
            // );
          },
        );
      },
    );
  }

  Widget _buildAchievementCard(BuildContext context, Achievement achievement,
      bool isMobile, bool isUnlocked) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        boxShadow: [
          BoxShadow(
            color: isUnlocked
                ? AppTheme.primaryPurple.withOpacity(0.15)
                : Colors.black.withOpacity(0.08),
            blurRadius: isMobile ? 12 : 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        child: Container(
          decoration: BoxDecoration(
            gradient: isUnlocked
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      AppTheme.primaryPurple.withOpacity(0.05),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey[50]!,
                      Colors.grey[100]!,
                    ],
                  ),
            border: Border.all(
              color: isUnlocked
                  ? AppTheme.primaryPurple.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.15),
              width: 1.5,
            ),
          ),
          child: Stack(
            children: [
              // Background Pattern
              if (isUnlocked)
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryPurple.withOpacity(0.05),
                    ),
                  ),
                ),

              // Main Content
              Padding(
                padding: EdgeInsets.all(isMobile ? 20 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Achievement Icon with Enhanced Design
                    Container(
                      width: isMobile ? 70 : 80,
                      height: isMobile ? 70 : 80,
                      decoration: BoxDecoration(
                        gradient: isUnlocked
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.primaryPurple,
                                  AppTheme.primaryPurple.withOpacity(0.8),
                                ],
                              )
                            : LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.grey[400]!,
                                  Colors.grey[500]!,
                                ],
                              ),
                        borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
                        boxShadow: [
                          BoxShadow(
                            color: isUnlocked
                                ? AppTheme.primaryPurple.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.3),
                            blurRadius: isMobile ? 8 : 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          achievement.icon,
                          style: TextStyle(
                            fontSize: isMobile ? 28 : 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: isMobile ? 16 : 20),

                    // Achievement Title with Better Typography
                    Text(
                      achievement.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isUnlocked
                                ? AppTheme.textPrimary
                                : Colors.grey[600],
                            fontSize: isMobile ? 15 : 17,
                            height: 1.2,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: isMobile ? 8 : 12),

                    // Achievement Description with Better Spacing
                    Text(
                      achievement.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isUnlocked
                                ? AppTheme.textSecondary
                                : Colors.grey[500],
                            fontSize: isMobile ? 11 : 13,
                            height: 1.3,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: isMobile ? 16 : 20),

                    // Enhanced Points and Status Section
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 16,
                        vertical: isMobile ? 8 : 10,
                      ),
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? AppTheme.primaryPurple.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                        border: Border.all(
                          color: isUnlocked
                              ? AppTheme.primaryPurple.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // XP Points
                          Row(
                            children: [
                              Icon(
                                Icons.stars,
                                size: isMobile ? 14 : 16,
                                color: isUnlocked
                                    ? AppTheme.primaryPurple
                                    : Colors.grey[600],
                              ),
                              // SizedBox(width: isMobile ? 4 : 6),
                              Text(
                                '${achievement.points} XP',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: isUnlocked
                                          ? AppTheme.primaryPurple
                                          : Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                      fontSize: isMobile ? 8 : 13,
                                    ),
                              ),
                            ],
                          ),

                          // Status Badge
                          if (isUnlocked && achievement.unlockedAt != null)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 10 : 10,
                                vertical: isMobile ? 4 : 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.primaryGreen,
                                    AppTheme.primaryGreen.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius:
                                    BorderRadius.circular(isMobile ? 8 : 10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: isMobile ? 12 : 14,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: isMobile ? 4 : 6),
                                  Text(
                                    'Unlocked',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: isMobile ? 8 : 12,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Unlock Date
                    if (isUnlocked && achievement.unlockedAt != null) ...[
                      SizedBox(height: isMobile ? 8 : 12),
                      Text(
                        _formatUnlockDate(achievement.unlockedAt!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                              fontSize: isMobile ? 10 : 12,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                  ],
                ),
              ),

              // Lock Overlay for Locked Achievements
              if (!isUnlocked)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
                    ),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(isMobile ? 8 : 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.lock,
                          size: isMobile ? 20 : 24,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
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
