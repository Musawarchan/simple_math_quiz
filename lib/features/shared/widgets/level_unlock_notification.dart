import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/math_models.dart';

class LevelUnlockNotification extends StatefulWidget {
  final DifficultyLevel unlockedLevel;
  final VoidCallback onDismiss;

  const LevelUnlockNotification({
    super.key,
    required this.unlockedLevel,
    required this.onDismiss,
  });

  @override
  State<LevelUnlockNotification> createState() =>
      _LevelUnlockNotificationState();
}

class _LevelUnlockNotificationState extends State<LevelUnlockNotification>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleController.forward();
    });

    // Auto dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _slideController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  String _getLevelIcon(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return '🌱';
      case DifficultyLevel.easy:
        return '⭐';
      case DifficultyLevel.medium:
        return '🔥';
      case DifficultyLevel.hard:
        return '💪';
      case DifficultyLevel.expert:
        return '👑';
    }
  }

  String _getLevelName(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return 'Beginner';
      case DifficultyLevel.easy:
        return 'Easy';
      case DifficultyLevel.medium:
        return 'Medium';
      case DifficultyLevel.hard:
        return 'Hard';
      case DifficultyLevel.expert:
        return 'Expert';
    }
  }

  Color _getLevelColor(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return const Color(0xFF4CAF50);
      case DifficultyLevel.easy:
        return const Color(0xFF2196F3);
      case DifficultyLevel.medium:
        return const Color(0xFFFF9800);
      case DifficultyLevel.hard:
        return const Color(0xFFE91E63);
      case DifficultyLevel.expert:
        return const Color(0xFF9C27B0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final levelColor = _getLevelColor(widget.unlockedLevel);

    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: EdgeInsets.all(isMobile ? 16 : 24),
          padding: EdgeInsets.all(isMobile ? 20 : 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [levelColor, levelColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
            boxShadow: [
              BoxShadow(
                color: levelColor.withOpacity(0.3),
                blurRadius: isMobile ? 15 : 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Level icon
              Container(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                ),
                child: Text(
                  _getLevelIcon(widget.unlockedLevel),
                  style: TextStyle(
                    fontSize: isMobile ? 24 : 32,
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 16 : 20),

              // Level info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎉 Level Unlocked!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: isMobile ? 16 : 18,
                          ),
                    ),
                    SizedBox(height: isMobile ? 4 : 6),
                    Text(
                      '${_getLevelName(widget.unlockedLevel)} Level',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: isMobile ? 14 : 16,
                          ),
                    ),
                    SizedBox(height: isMobile ? 2 : 4),
                    Text(
                      'You can now practice with this difficulty level!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: isMobile ? 12 : 14,
                          ),
                    ),
                  ],
                ),
              ),

              // Close button
              IconButton(
                onPressed: _dismiss,
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: isMobile ? 20 : 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
