import 'math_models.dart';

// Session History Models
class SessionRecord {
  final String id;
  final DateTime timestamp;
  final OperationType operationType;
  final QuestionType questionType;
  final DifficultyLevel difficultyLevel;
  final int totalQuestions;
  final int correctAnswers;
  final int score;
  final double accuracy;
  final Duration totalTime;
  final List<QuestionAttempt> questionAttempts;

  SessionRecord({
    required this.id,
    required this.timestamp,
    required this.operationType,
    required this.questionType,
    required this.difficultyLevel,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.score,
    required this.accuracy,
    required this.totalTime,
    required this.questionAttempts,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'operationType': operationType.name,
        'questionType': questionType.name,
        'difficultyLevel': difficultyLevel.name,
        'totalQuestions': totalQuestions,
        'correctAnswers': correctAnswers,
        'score': score,
        'accuracy': accuracy,
        'totalTime': totalTime.inMilliseconds,
        'questionAttempts': questionAttempts.map((e) => e.toJson()).toList(),
      };

  factory SessionRecord.fromJson(Map<String, dynamic> json) => SessionRecord(
        id: json['id'],
        timestamp: DateTime.parse(json['timestamp']),
        operationType: OperationType.values
            .firstWhere((e) => e.name == json['operationType']),
        questionType: QuestionType.values
            .firstWhere((e) => e.name == json['questionType']),
        difficultyLevel: DifficultyLevel.values
            .firstWhere((e) => e.name == json['difficultyLevel']),
        totalQuestions: json['totalQuestions'],
        correctAnswers: json['correctAnswers'],
        score: json['score'],
        accuracy: json['accuracy'].toDouble(),
        totalTime: Duration(milliseconds: json['totalTime']),
        questionAttempts: (json['questionAttempts'] as List)
            .map((e) => QuestionAttempt.fromJson(e))
            .toList(),
      );
}

class QuestionAttempt {
  final int operand1;
  final int operand2;
  final OperationType operation;
  final int correctAnswer;
  final int? userAnswer;
  final bool isCorrect;
  final Duration timeSpent;
  final DifficultyLevel difficultyLevel;

  QuestionAttempt({
    required this.operand1,
    required this.operand2,
    required this.operation,
    required this.correctAnswer,
    this.userAnswer,
    required this.isCorrect,
    required this.timeSpent,
    required this.difficultyLevel,
  });

  Map<String, dynamic> toJson() => {
        'operand1': operand1,
        'operand2': operand2,
        'operation': operation.name,
        'correctAnswer': correctAnswer,
        'userAnswer': userAnswer,
        'isCorrect': isCorrect,
        'timeSpent': timeSpent.inMilliseconds,
        'difficultyLevel': difficultyLevel.name,
      };

  factory QuestionAttempt.fromJson(Map<String, dynamic> json) =>
      QuestionAttempt(
        operand1: json['operand1'],
        operand2: json['operand2'],
        operation:
            OperationType.values.firstWhere((e) => e.name == json['operation']),
        correctAnswer: json['correctAnswer'],
        userAnswer: json['userAnswer'],
        isCorrect: json['isCorrect'],
        timeSpent: Duration(milliseconds: json['timeSpent']),
        difficultyLevel: DifficultyLevel.values
            .firstWhere((e) => e.name == json['difficultyLevel']),
      );

  String get questionKey => '${operand1}_${operation.name}_${operand2}';
}

// Achievement Models
enum AchievementType {
  speedDemon,
  perfectScore,
  streakMaster,
  marathonRunner,
  accuracyKing,
  speedster,
  persistentLearner,
  operationMaster,
  difficultyChampion,
  consistencyChampion,
}

class Achievement {
  final AchievementType type;
  final String title;
  final String description;
  final String icon;
  final int points;
  final DateTime? unlockedAt;
  final Map<String, dynamic>? metadata;

  Achievement({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
    this.unlockedAt,
    this.metadata,
  });

  bool get isUnlocked => unlockedAt != null;

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'title': title,
        'description': description,
        'icon': icon,
        'points': points,
        'unlockedAt': unlockedAt?.toIso8601String(),
        'metadata': metadata,
      };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        type: AchievementType.values.firstWhere((e) => e.name == json['type']),
        title: json['title'],
        description: json['description'],
        icon: json['icon'],
        points: json['points'],
        unlockedAt: json['unlockedAt'] != null
            ? DateTime.parse(json['unlockedAt'])
            : null,
        metadata: json['metadata'],
      );
}

// Gamification Models
class UserProfile {
  final int totalXP;
  final int level;
  final int currentStreak;
  final int longestStreak;
  final int totalSessions;
  final int totalQuestionsAnswered;
  final int totalCorrectAnswers;
  final double overallAccuracy;
  final Map<OperationType, int> operationXP;
  final Map<DifficultyLevel, int> difficultyXP;
  final List<Achievement> achievements;
  final DateTime lastSessionDate;

  UserProfile({
    required this.totalXP,
    required this.level,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalSessions,
    required this.totalQuestionsAnswered,
    required this.totalCorrectAnswers,
    required this.overallAccuracy,
    required this.operationXP,
    required this.difficultyXP,
    required this.achievements,
    required this.lastSessionDate,
  });

  int get xpToNextLevel => _calculateXPToNextLevel();
  int get xpForCurrentLevel => _calculateXPForCurrentLevel();

  int _calculateXPToNextLevel() {
    final nextLevelXP = (level + 1) * 1000;
    return nextLevelXP - totalXP;
  }

  int _calculateXPForCurrentLevel() {
    final currentLevelXP = level * 1000;
    return totalXP - currentLevelXP;
  }

  Map<String, dynamic> toJson() => {
        'totalXP': totalXP,
        'level': level,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'totalSessions': totalSessions,
        'totalQuestionsAnswered': totalQuestionsAnswered,
        'totalCorrectAnswers': totalCorrectAnswers,
        'overallAccuracy': overallAccuracy,
        'operationXP': operationXP.map((k, v) => MapEntry(k.name, v)),
        'difficultyXP': difficultyXP.map((k, v) => MapEntry(k.name, v)),
        'achievements': achievements.map((e) => e.toJson()).toList(),
        'lastSessionDate': lastSessionDate.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        totalXP: json['totalXP'],
        level: json['level'],
        currentStreak: json['currentStreak'],
        longestStreak: json['longestStreak'],
        totalSessions: json['totalSessions'],
        totalQuestionsAnswered: json['totalQuestionsAnswered'],
        totalCorrectAnswers: json['totalCorrectAnswers'],
        overallAccuracy: json['overallAccuracy'].toDouble(),
        operationXP: (json['operationXP'] as Map<String, dynamic>).map((k, v) =>
            MapEntry(OperationType.values.firstWhere((e) => e.name == k), v)),
        difficultyXP: (json['difficultyXP'] as Map<String, dynamic>).map((k,
                v) =>
            MapEntry(DifficultyLevel.values.firstWhere((e) => e.name == k), v)),
        achievements: (json['achievements'] as List)
            .map((e) => Achievement.fromJson(e))
            .toList(),
        lastSessionDate: DateTime.parse(json['lastSessionDate']),
      );
}

// Analytics Models
class PerformanceTrend {
  final DateTime date;
  final double accuracy;
  final int questionsAnswered;
  final Duration averageTimePerQuestion;
  final Map<OperationType, double> operationAccuracy;

  PerformanceTrend({
    required this.date,
    required this.accuracy,
    required this.questionsAnswered,
    required this.averageTimePerQuestion,
    required this.operationAccuracy,
  });
}

class WeakArea {
  final String questionPattern;
  final OperationType operation;
  final int operand1;
  final int operand2;
  final int totalAttempts;
  final int correctAttempts;
  final double accuracy;
  final Duration averageTime;

  WeakArea({
    required this.questionPattern,
    required this.operation,
    required this.operand1,
    required this.operand2,
    required this.totalAttempts,
    required this.correctAttempts,
    required this.accuracy,
    required this.averageTime,
  });

  String get displayText {
    switch (operation) {
      case OperationType.addition:
        return '$operand1 + $operand2';
      case OperationType.subtraction:
        return '$operand1 - $operand2';
      case OperationType.multiplication:
        return '$operand1 × $operand2';
      case OperationType.division:
        return '$operand1 ÷ $operand2';
    }
  }
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final Map<String, dynamic> requirements;
  final int rewardXP;
  final Achievement? rewardAchievement;
  final DateTime? completedAt;
  final bool isActive;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.requirements,
    required this.rewardXP,
    this.rewardAchievement,
    this.completedAt,
    required this.isActive,
  });

  bool get isCompleted => completedAt != null;
}

enum ChallengeType {
  daily,
  weekly,
  monthly,
  special,
}

// Achievement Definitions
class AchievementDefinitions {
  static final Map<AchievementType, Achievement> definitions = {
    AchievementType.speedDemon: Achievement(
      type: AchievementType.speedDemon,
      title: 'Speed Demon',
      description: 'Answer 10 questions in under 1 second each',
      icon: '⚡',
      points: 100,
    ),
    AchievementType.perfectScore: Achievement(
      type: AchievementType.perfectScore,
      title: 'Perfect Score',
      description: 'Get 100% accuracy in a session',
      icon: '🎯',
      points: 150,
    ),
    AchievementType.streakMaster: Achievement(
      type: AchievementType.streakMaster,
      title: 'Streak Master',
      description: 'Maintain a 7-day practice streak',
      icon: '🔥',
      points: 200,
    ),
    AchievementType.marathonRunner: Achievement(
      type: AchievementType.marathonRunner,
      title: 'Marathon Runner',
      description: 'Complete 100 sessions',
      icon: '🏃',
      points: 300,
    ),
    AchievementType.accuracyKing: Achievement(
      type: AchievementType.accuracyKing,
      title: 'Accuracy King',
      description: 'Maintain 90%+ accuracy for 10 sessions',
      icon: '👑',
      points: 250,
    ),
    AchievementType.speedster: Achievement(
      type: AchievementType.speedster,
      title: 'Speedster',
      description: 'Answer 50 questions in under 2 seconds each',
      icon: '💨',
      points: 120,
    ),
    AchievementType.persistentLearner: Achievement(
      type: AchievementType.persistentLearner,
      title: 'Persistent Learner',
      description: 'Practice for 30 consecutive days',
      icon: '📚',
      points: 400,
    ),
    AchievementType.operationMaster: Achievement(
      type: AchievementType.operationMaster,
      title: 'Operation Master',
      description: 'Master all four operations',
      icon: '🧮',
      points: 180,
    ),
    AchievementType.difficultyChampion: Achievement(
      type: AchievementType.difficultyChampion,
      title: 'Difficulty Champion',
      description: 'Complete 50 hard difficulty sessions',
      icon: '💪',
      points: 220,
    ),
    AchievementType.consistencyChampion: Achievement(
      type: AchievementType.consistencyChampion,
      title: 'Consistency Champion',
      description: 'Practice every day for 2 weeks',
      icon: '📅',
      points: 160,
    ),
  };
}
