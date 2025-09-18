import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/progress_models.dart';
import '../data/models/math_models.dart';

class SessionHistoryService {
  static const String _sessionsKey = 'session_history';
  static const String _userProfileKey = 'user_profile';
  static const String _achievementsKey = 'achievements';

  // Session History Management
  Future<List<SessionRecord>> getAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getStringList(_sessionsKey) ?? [];

    return sessionsJson
        .map((json) => SessionRecord.fromJson(jsonDecode(json)))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> saveSession(SessionRecord session) async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = await getAllSessions();

    sessions.add(session);

    // Keep only last 1000 sessions to prevent storage bloat
    if (sessions.length > 1000) {
      sessions.removeRange(1000, sessions.length);
    }

    final sessionsJson =
        sessions.map((session) => jsonEncode(session.toJson())).toList();

    await prefs.setStringList(_sessionsKey, sessionsJson);
  }

  Future<List<SessionRecord>> getSessionsByDateRange(
      DateTime start, DateTime end) async {
    final allSessions = await getAllSessions();
    return allSessions.where((session) {
      return session.timestamp.isAfter(start) &&
          session.timestamp.isBefore(end);
    }).toList();
  }

  Future<List<SessionRecord>> getSessionsByOperation(
      OperationType operation) async {
    final allSessions = await getAllSessions();
    return allSessions
        .where((session) => session.operationType == operation)
        .toList();
  }

  Future<List<SessionRecord>> getSessionsByDifficulty(
      DifficultyLevel difficulty) async {
    final allSessions = await getAllSessions();
    return allSessions
        .where((session) => session.difficultyLevel == difficulty)
        .toList();
  }

  // User Profile Management
  Future<UserProfile> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_userProfileKey);

    if (profileJson != null) {
      return UserProfile.fromJson(jsonDecode(profileJson));
    }

    // Return default profile if none exists
    return UserProfile(
      totalXP: 0,
      level: 1,
      currentStreak: 0,
      longestStreak: 0,
      totalSessions: 0,
      totalQuestionsAnswered: 0,
      totalCorrectAnswers: 0,
      overallAccuracy: 0.0,
      operationXP: {
        OperationType.addition: 0,
        OperationType.subtraction: 0,
        OperationType.multiplication: 0,
        OperationType.division: 0,
      },
      difficultyXP: {
        DifficultyLevel.easy: 0,
        DifficultyLevel.medium: 0,
        DifficultyLevel.hard: 0,
      },
      achievements: [],
      lastSessionDate: DateTime.now().subtract(const Duration(days: 1)),
    );
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfileKey, jsonEncode(profile.toJson()));
  }

  // Achievement Management
  Future<List<Achievement>> getAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = prefs.getStringList(_achievementsKey) ?? [];

    if (achievementsJson.isEmpty) {
      // Initialize with all achievement definitions
      final achievements = AchievementDefinitions.definitions.values.toList();
      await saveAchievements(achievements);
      return achievements;
    }

    return achievementsJson
        .map((json) => Achievement.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> saveAchievements(List<Achievement> achievements) async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = achievements
        .map((achievement) => jsonEncode(achievement.toJson()))
        .toList();

    await prefs.setStringList(_achievementsKey, achievementsJson);
  }

  Future<void> unlockAchievement(AchievementType type) async {
    final achievements = await getAchievements();
    final achievementIndex = achievements.indexWhere((a) => a.type == type);

    if (achievementIndex != -1 && !achievements[achievementIndex].isUnlocked) {
      achievements[achievementIndex] = Achievement(
        type: achievements[achievementIndex].type,
        title: achievements[achievementIndex].title,
        description: achievements[achievementIndex].description,
        icon: achievements[achievementIndex].icon,
        points: achievements[achievementIndex].points,
        unlockedAt: DateTime.now(),
        metadata: achievements[achievementIndex].metadata,
      );

      await saveAchievements(achievements);
    }
  }

  // Analytics Methods
  Future<List<PerformanceTrend>> getPerformanceTrends({int days = 30}) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    final sessions = await getSessionsByDateRange(startDate, endDate);

    final Map<String, List<SessionRecord>> sessionsByDate = {};

    for (final session in sessions) {
      final dateKey =
          '${session.timestamp.year}-${session.timestamp.month.toString().padLeft(2, '0')}-${session.timestamp.day.toString().padLeft(2, '0')}';
      sessionsByDate.putIfAbsent(dateKey, () => []).add(session);
    }

    final trends = <PerformanceTrend>[];

    for (int i = 0; i < days; i++) {
      final date = endDate.subtract(Duration(days: i));
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final daySessions = sessionsByDate[dateKey] ?? [];

      if (daySessions.isNotEmpty) {
        final totalQuestions =
            daySessions.fold(0, (sum, session) => sum + session.totalQuestions);
        final correctAnswers =
            daySessions.fold(0, (sum, session) => sum + session.correctAnswers);
        final totalTime = daySessions.fold(
            Duration.zero, (sum, session) => sum + session.totalTime);

        final operationAccuracy = <OperationType, double>{};
        for (final operation in OperationType.values) {
          final operationSessions =
              daySessions.where((s) => s.operationType == operation);
          if (operationSessions.isNotEmpty) {
            final opTotal = operationSessions.fold(
                0, (sum, session) => sum + session.totalQuestions);
            final opCorrect = operationSessions.fold(
                0, (sum, session) => sum + session.correctAnswers);
            operationAccuracy[operation] =
                opTotal > 0 ? opCorrect / opTotal : 0.0;
          }
        }

        trends.add(PerformanceTrend(
          date: date,
          accuracy: totalQuestions > 0 ? correctAnswers / totalQuestions : 0.0,
          questionsAnswered: totalQuestions,
          averageTimePerQuestion: totalQuestions > 0
              ? Duration(
                  milliseconds: totalTime.inMilliseconds ~/ totalQuestions)
              : Duration.zero,
          operationAccuracy: operationAccuracy,
        ));
      } else {
        trends.add(PerformanceTrend(
          date: date,
          accuracy: 0.0,
          questionsAnswered: 0,
          averageTimePerQuestion: Duration.zero,
          operationAccuracy: {},
        ));
      }
    }

    return trends.reversed.toList();
  }

  Future<List<WeakArea>> getWeakAreas({int minAttempts = 3}) async {
    final sessions = await getAllSessions();
    final Map<String, List<QuestionAttempt>> questionAttempts = {};

    // Group attempts by question pattern
    for (final session in sessions) {
      for (final attempt in session.questionAttempts) {
        final key = attempt.questionKey;
        questionAttempts.putIfAbsent(key, () => []).add(attempt);
      }
    }

    final weakAreas = <WeakArea>[];

    for (final entry in questionAttempts.entries) {
      final attempts = entry.value;
      if (attempts.length >= minAttempts) {
        final correctAttempts = attempts.where((a) => a.isCorrect).length;
        final accuracy = correctAttempts / attempts.length;
        final totalTime = attempts.fold(
            Duration.zero, (sum, attempt) => sum + attempt.timeSpent);
        final averageTime =
            Duration(milliseconds: totalTime.inMilliseconds ~/ attempts.length);

        // Consider it a weak area if accuracy is below 70%
        if (accuracy < 0.7) {
          final firstAttempt = attempts.first;
          weakAreas.add(WeakArea(
            questionPattern: entry.key,
            operation: firstAttempt.operation,
            operand1: firstAttempt.operand1,
            operand2: firstAttempt.operand2,
            totalAttempts: attempts.length,
            correctAttempts: correctAttempts,
            accuracy: accuracy,
            averageTime: averageTime,
          ));
        }
      }
    }

    // Sort by accuracy (worst first) and then by total attempts
    weakAreas.sort((a, b) {
      final accuracyComparison = a.accuracy.compareTo(b.accuracy);
      if (accuracyComparison != 0) return accuracyComparison;
      return b.totalAttempts.compareTo(a.totalAttempts);
    });

    return weakAreas.take(10).toList(); // Return top 10 weak areas
  }

  Future<Map<String, dynamic>> getSessionStatistics() async {
    final sessions = await getAllSessions();

    if (sessions.isEmpty) {
      return {
        'totalSessions': 0,
        'totalQuestions': 0,
        'totalCorrect': 0,
        'overallAccuracy': 0.0,
        'averageSessionTime': Duration.zero,
        'bestStreak': 0,
        'currentStreak': 0,
        'operationStats': <String, Map<String, dynamic>>{},
        'difficultyStats': <String, Map<String, dynamic>>{},
      };
    }

    final totalQuestions =
        sessions.fold(0, (sum, session) => sum + session.totalQuestions);
    final totalCorrect =
        sessions.fold(0, (sum, session) => sum + session.correctAnswers);
    final totalTime =
        sessions.fold(Duration.zero, (sum, session) => sum + session.totalTime);

    // Operation statistics
    final operationStats = <String, Map<String, dynamic>>{};
    for (final operation in OperationType.values) {
      final operationSessions =
          sessions.where((s) => s.operationType == operation);
      if (operationSessions.isNotEmpty) {
        final opTotal = operationSessions.fold(
            0, (sum, session) => sum + session.totalQuestions);
        final opCorrect = operationSessions.fold(
            0, (sum, session) => sum + session.correctAnswers);
        operationStats[operation.name] = {
          'sessions': operationSessions.length,
          'questions': opTotal,
          'correct': opCorrect,
          'accuracy': opTotal > 0 ? opCorrect / opTotal : 0.0,
        };
      }
    }

    // Difficulty statistics
    final difficultyStats = <String, Map<String, dynamic>>{};
    for (final difficulty in DifficultyLevel.values) {
      final difficultySessions =
          sessions.where((s) => s.difficultyLevel == difficulty);
      if (difficultySessions.isNotEmpty) {
        final diffTotal = difficultySessions.fold(
            0, (sum, session) => sum + session.totalQuestions);
        final diffCorrect = difficultySessions.fold(
            0, (sum, session) => sum + session.correctAnswers);
        difficultyStats[difficulty.name] = {
          'sessions': difficultySessions.length,
          'questions': diffTotal,
          'correct': diffCorrect,
          'accuracy': diffTotal > 0 ? diffCorrect / diffTotal : 0.0,
        };
      }
    }

    // Calculate streaks
    final streaks = _calculateStreaks(sessions);

    return {
      'totalSessions': sessions.length,
      'totalQuestions': totalQuestions,
      'totalCorrect': totalCorrect,
      'overallAccuracy':
          totalQuestions > 0 ? totalCorrect / totalQuestions : 0.0,
      'averageSessionTime':
          Duration(milliseconds: totalTime.inMilliseconds ~/ sessions.length),
      'bestStreak': streaks['longest'],
      'currentStreak': streaks['current'],
      'operationStats': operationStats,
      'difficultyStats': difficultyStats,
    };
  }

  Map<String, int> _calculateStreaks(List<SessionRecord> sessions) {
    if (sessions.isEmpty) return {'current': 0, 'longest': 0};

    // Sort sessions by date
    final sortedSessions = List<SessionRecord>.from(sessions)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;

    DateTime? lastSessionDate;

    for (final session in sortedSessions) {
      final sessionDate = DateTime(session.timestamp.year,
          session.timestamp.month, session.timestamp.day);

      if (lastSessionDate == null) {
        tempStreak = 1;
      } else {
        final daysDifference = sessionDate.difference(lastSessionDate).inDays;

        if (daysDifference == 1) {
          // Consecutive day
          tempStreak++;
        } else if (daysDifference == 0) {
          // Same day, continue streak
          // Don't increment tempStreak
        } else {
          // Streak broken
          longestStreak =
              tempStreak > longestStreak ? tempStreak : longestStreak;
          tempStreak = 1;
        }
      }

      lastSessionDate = sessionDate;
    }

    // Check final streak
    longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;

    // Calculate current streak (from today backwards)
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    currentStreak = 0;

    DateTime checkDate = todayDate;
    for (int i = 0; i < 365; i++) {
      // Check up to a year back
      final hasSessionOnDate = sortedSessions.any((session) {
        final sessionDate = DateTime(session.timestamp.year,
            session.timestamp.month, session.timestamp.day);
        return sessionDate == checkDate;
      });

      if (hasSessionOnDate) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return {
      'current': currentStreak,
      'longest': longestStreak,
    };
  }

  // Challenge Management
  Future<List<Challenge>> getActiveChallenges() async {
    // For now, return some default challenges
    // In a real app, these would be stored and managed server-side
    return [
      Challenge(
        id: 'daily_practice',
        title: 'Daily Practice',
        description: 'Complete at least one session today',
        type: ChallengeType.daily,
        requirements: {'sessions': 1},
        rewardXP: 50,
        isActive: true,
      ),
      Challenge(
        id: 'accuracy_master',
        title: 'Accuracy Master',
        description: 'Achieve 90%+ accuracy in 5 sessions this week',
        type: ChallengeType.weekly,
        requirements: {'accuracy': 0.9, 'sessions': 5},
        rewardXP: 200,
        isActive: true,
      ),
      Challenge(
        id: 'operation_explorer',
        title: 'Operation Explorer',
        description: 'Practice all four operations this week',
        type: ChallengeType.weekly,
        requirements: {'operations': 4},
        rewardXP: 150,
        isActive: true,
      ),
    ];
  }
}
