import 'dart:math';
import '../data/models/progress_models.dart';
import '../data/models/math_models.dart';
import 'session_history_service.dart';

class GamificationService {
  final SessionHistoryService _historyService;

  GamificationService(this._historyService);

  // XP Calculation Methods
  Future<int> calculateSessionXP(SessionRecord session) async {
    int baseXP = session.correctAnswers * 10; // 10 XP per correct answer

    // Accuracy bonus
    if (session.accuracy >= 0.9) {
      baseXP = (baseXP * 1.5).round(); // 50% bonus for 90%+ accuracy
    } else if (session.accuracy >= 0.8) {
      baseXP = (baseXP * 1.25).round(); // 25% bonus for 80%+ accuracy
    }

    // Difficulty bonus
    switch (session.difficultyLevel) {
      case DifficultyLevel.beginner:
        baseXP = (baseXP * 0.8).round(); // 20% penalty for beginner
        break;
      case DifficultyLevel.easy:
        baseXP = (baseXP * 1.0).round();
        break;
      case DifficultyLevel.medium:
        baseXP = (baseXP * 1.2).round(); // 20% bonus
        break;
      case DifficultyLevel.hard:
        baseXP = (baseXP * 1.5).round(); // 50% bonus
        break;
      case DifficultyLevel.expert:
        baseXP = (baseXP * 2.0).round(); // 100% bonus
        break;
    }

    // Speed bonus (if average time per question is fast)
    final avgTimePerQuestion =
        session.totalTime.inMilliseconds / session.totalQuestions;
    if (avgTimePerQuestion < 2000) {
      // Under 2 seconds
      baseXP = (baseXP * 1.3).round(); // 30% speed bonus
    } else if (avgTimePerQuestion < 3000) {
      // Under 3 seconds
      baseXP = (baseXP * 1.1).round(); // 10% speed bonus
    }

    // Streak bonus
    final profile = await _historyService.getUserProfile();
    if (profile.currentStreak >= 7) {
      baseXP = (baseXP * 1.2).round(); // 20% streak bonus
    } else if (profile.currentStreak >= 3) {
      baseXP = (baseXP * 1.1).round(); // 10% streak bonus
    }

    return baseXP;
  }

  int calculateLevelFromXP(int totalXP) {
    // Level formula: Level = sqrt(XP / 1000) + 1
    return (sqrt(totalXP / 1000)).floor() + 1;
  }

  // Achievement Checking Methods
  Future<List<AchievementType>> checkAchievements(SessionRecord session) async {
    final profile = await _historyService.getUserProfile();
    final sessions = await _historyService.getAllSessions();
    final unlockedAchievements = profile.achievements
        .where((a) => a.isUnlocked)
        .map((a) => a.type)
        .toSet();

    final newAchievements = <AchievementType>[];

    // Speed Demon: Answer 10 questions in under 1 second each
    if (!unlockedAchievements.contains(AchievementType.speedDemon)) {
      final fastAnswers = session.questionAttempts
          .where((attempt) => attempt.timeSpent.inMilliseconds < 1000)
          .length;
      if (fastAnswers >= 10) {
        newAchievements.add(AchievementType.speedDemon);
      }
    }

    // Perfect Score: Get 100% accuracy in a session
    if (!unlockedAchievements.contains(AchievementType.perfectScore)) {
      if (session.accuracy >= 1.0) {
        newAchievements.add(AchievementType.perfectScore);
      }
    }

    // Accuracy King: Maintain 90%+ accuracy for 10 sessions
    if (!unlockedAchievements.contains(AchievementType.accuracyKing)) {
      final recentSessions = sessions.take(10).toList();
      if (recentSessions.length >= 10) {
        final avgAccuracy =
            recentSessions.fold(0.0, (sum, s) => sum + s.accuracy) /
                recentSessions.length;
        if (avgAccuracy >= 0.9) {
          newAchievements.add(AchievementType.accuracyKing);
        }
      }
    }

    // Speedster: Answer 50 questions in under 2 seconds each
    if (!unlockedAchievements.contains(AchievementType.speedster)) {
      final allFastAnswers = sessions.fold(
          0,
          (sum, session) =>
              sum +
              session.questionAttempts
                  .where((attempt) => attempt.timeSpent.inMilliseconds < 2000)
                  .length);
      if (allFastAnswers >= 50) {
        newAchievements.add(AchievementType.speedster);
      }
    }

    // Marathon Runner: Complete 100 sessions
    if (!unlockedAchievements.contains(AchievementType.marathonRunner)) {
      if (sessions.length >= 100) {
        newAchievements.add(AchievementType.marathonRunner);
      }
    }

    // Operation Master: Master all four operations
    if (!unlockedAchievements.contains(AchievementType.operationMaster)) {
      final operationSessions = <OperationType, int>{};
      for (final op in OperationType.values) {
        operationSessions[op] =
            sessions.where((s) => s.operationType == op).length;
      }
      if (operationSessions.values.every((count) => count >= 10)) {
        newAchievements.add(AchievementType.operationMaster);
      }
    }

    // Difficulty Champion: Complete 50 hard difficulty sessions
    if (!unlockedAchievements.contains(AchievementType.difficultyChampion)) {
      final hardSessions = sessions
          .where((s) => s.difficultyLevel == DifficultyLevel.hard)
          .length;
      if (hardSessions >= 50) {
        newAchievements.add(AchievementType.difficultyChampion);
      }
    }

    // Streak Master: Maintain a 7-day practice streak
    if (!unlockedAchievements.contains(AchievementType.streakMaster)) {
      if (profile.currentStreak >= 7) {
        newAchievements.add(AchievementType.streakMaster);
      }
    }

    // Persistent Learner: Practice for 30 consecutive days
    if (!unlockedAchievements.contains(AchievementType.persistentLearner)) {
      if (profile.currentStreak >= 30) {
        newAchievements.add(AchievementType.persistentLearner);
      }
    }

    // Consistency Champion: Practice every day for 2 weeks
    if (!unlockedAchievements.contains(AchievementType.consistencyChampion)) {
      if (profile.currentStreak >= 14) {
        newAchievements.add(AchievementType.consistencyChampion);
      }
    }

    return newAchievements;
  }

  // Update User Profile
  Future<UserProfile> updateProfileWithSession(SessionRecord session) async {
    final currentProfile = await _historyService.getUserProfile();
    final sessionXP = await calculateSessionXP(session);
    final newTotalXP = currentProfile.totalXP + sessionXP;
    final newLevel = calculateLevelFromXP(newTotalXP);

    // Update operation XP
    final newOperationXP =
        Map<OperationType, int>.from(currentProfile.operationXP);
    newOperationXP[session.operationType] =
        (newOperationXP[session.operationType] ?? 0) + sessionXP;

    // Update difficulty XP
    final newDifficultyXP =
        Map<DifficultyLevel, int>.from(currentProfile.difficultyXP);
    newDifficultyXP[session.difficultyLevel] =
        (newDifficultyXP[session.difficultyLevel] ?? 0) + sessionXP;

    // Update streak
    final today = DateTime.now();
    final lastSessionDate = DateTime(
        currentProfile.lastSessionDate.year,
        currentProfile.lastSessionDate.month,
        currentProfile.lastSessionDate.day);
    final todayDate = DateTime(today.year, today.month, today.day);

    int newCurrentStreak = currentProfile.currentStreak;
    int newLongestStreak = currentProfile.longestStreak;

    if (todayDate.difference(lastSessionDate).inDays == 1) {
      // Consecutive day
      newCurrentStreak++;
    } else if (todayDate.difference(lastSessionDate).inDays > 1) {
      // Streak broken
      newCurrentStreak = 1;
    }
    // If same day, keep current streak

    if (newCurrentStreak > newLongestStreak) {
      newLongestStreak = newCurrentStreak;
    }

    // Update overall statistics
    final newTotalSessions = currentProfile.totalSessions + 1;
    final newTotalQuestions =
        currentProfile.totalQuestionsAnswered + session.totalQuestions;
    final newTotalCorrect =
        currentProfile.totalCorrectAnswers + session.correctAnswers;
    final newOverallAccuracy =
        newTotalQuestions > 0 ? newTotalCorrect / newTotalQuestions : 0.0;

    // Check for new achievements
    final newAchievements = await checkAchievements(session);
    final updatedAchievements =
        List<Achievement>.from(currentProfile.achievements);

    for (final achievementType in newAchievements) {
      await _historyService.unlockAchievement(achievementType);
      final achievementDef =
          AchievementDefinitions.definitions[achievementType]!;
      updatedAchievements.add(Achievement(
        type: achievementType,
        title: achievementDef.title,
        description: achievementDef.description,
        icon: achievementDef.icon,
        points: achievementDef.points,
        unlockedAt: DateTime.now(),
      ));
    }

    final updatedProfile = UserProfile(
      totalXP: newTotalXP,
      level: newLevel,
      currentStreak: newCurrentStreak,
      longestStreak: newLongestStreak,
      totalSessions: newTotalSessions,
      totalQuestionsAnswered: newTotalQuestions,
      totalCorrectAnswers: newTotalCorrect,
      overallAccuracy: newOverallAccuracy,
      operationXP: newOperationXP,
      difficultyXP: newDifficultyXP,
      achievements: updatedAchievements,
      lastSessionDate: today,
    );

    await _historyService.updateUserProfile(updatedProfile);
    return updatedProfile;
  }

  // Challenge Checking
  Future<List<Challenge>> checkChallengeProgress() async {
    final challenges = await _historyService.getActiveChallenges();
    final sessions = await _historyService.getAllSessions();

    final updatedChallenges = <Challenge>[];

    for (final challenge in challenges) {
      if (challenge.isCompleted) {
        updatedChallenges.add(challenge);
        continue;
      }

      bool isCompleted = false;

      switch (challenge.id) {
        case 'daily_practice':
          final today = DateTime.now();
          final todaySessions = sessions
              .where((s) =>
                  DateTime(
                      s.timestamp.year, s.timestamp.month, s.timestamp.day) ==
                  DateTime(today.year, today.month, today.day))
              .length;
          isCompleted =
              todaySessions >= (challenge.requirements['sessions'] as int);
          break;

        case 'accuracy_master':
          final weekAgo = DateTime.now().subtract(const Duration(days: 7));
          final weekSessions =
              sessions.where((s) => s.timestamp.isAfter(weekAgo)).toList();
          final highAccuracySessions =
              weekSessions.where((s) => s.accuracy >= 0.9).length;
          isCompleted = highAccuracySessions >=
              (challenge.requirements['sessions'] as int);
          break;

        case 'operation_explorer':
          final weekAgo = DateTime.now().subtract(const Duration(days: 7));
          final weekSessions =
              sessions.where((s) => s.timestamp.isAfter(weekAgo)).toList();
          final practicedOperations =
              weekSessions.map((s) => s.operationType).toSet();
          isCompleted = practicedOperations.length >=
              (challenge.requirements['operations'] as int);
          break;
      }

      if (isCompleted) {
        updatedChallenges.add(Challenge(
          id: challenge.id,
          title: challenge.title,
          description: challenge.description,
          type: challenge.type,
          requirements: challenge.requirements,
          rewardXP: challenge.rewardXP,
          rewardAchievement: challenge.rewardAchievement,
          completedAt: DateTime.now(),
          isActive: challenge.isActive,
        ));
      } else {
        updatedChallenges.add(challenge);
      }
    }

    return updatedChallenges;
  }

  // Get Progress Summary
  Future<Map<String, dynamic>> getProgressSummary() async {
    final profile = await _historyService.getUserProfile();
    final sessions = await _historyService.getAllSessions();
    final weakAreas = await _historyService.getWeakAreas();
    final trends = await _historyService.getPerformanceTrends(days: 7);

    return {
      'profile': profile,
      'recentSessions': sessions.take(5).toList(),
      'weakAreas': weakAreas.take(3).toList(),
      'weeklyTrend': trends,
      'levelProgress': {
        'currentLevel': profile.level,
        'currentXP': profile.xpForCurrentLevel,
        'xpToNext': profile.xpToNextLevel,
        'progressPercentage': (profile.xpForCurrentLevel /
                (profile.xpForCurrentLevel + profile.xpToNextLevel)) *
            100,
      },
      'achievements': {
        'unlocked': profile.achievements.where((a) => a.isUnlocked).length,
        'total': AchievementDefinitions.definitions.length,
        'recent': profile.achievements
            .where((a) =>
                a.unlockedAt != null &&
                a.unlockedAt!
                    .isAfter(DateTime.now().subtract(const Duration(days: 7))))
            .toList(),
      },
    };
  }
}
