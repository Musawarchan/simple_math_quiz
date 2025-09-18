import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../data/models/math_models.dart';

class DifficultyProgressionService extends ChangeNotifier {
  static const String _progressionKey = 'difficulty_progression';

  // Define the progression order
  static const List<DifficultyLevel> _progressionOrder = [
    DifficultyLevel.beginner,
    DifficultyLevel.easy,
    DifficultyLevel.medium,
    DifficultyLevel.hard,
    DifficultyLevel.expert,
  ];

  // Get the current progression state
  Future<Map<DifficultyLevel, bool>> getProgressionState() async {
    final prefs = await SharedPreferences.getInstance();
    final progressionJson = prefs.getString(_progressionKey);

    if (progressionJson == null) {
      // Initialize with only beginner unlocked
      final initialState = <DifficultyLevel, bool>{};
      for (final level in DifficultyLevel.values) {
        initialState[level] = level == DifficultyLevel.beginner;
      }
      await saveProgressionState(initialState);
      return initialState;
    }

    final progressionData = jsonDecode(progressionJson) as Map<String, dynamic>;
    final progressionState = <DifficultyLevel, bool>{};

    for (final entry in progressionData.entries) {
      final level = DifficultyLevel.values.firstWhere(
        (e) => e.name == entry.key,
        orElse: () => DifficultyLevel.beginner,
      );
      progressionState[level] = entry.value as bool;
    }

    return progressionState;
  }

  // Save the progression state
  Future<void> saveProgressionState(
      Map<DifficultyLevel, bool> progressionState) async {
    final prefs = await SharedPreferences.getInstance();
    final progressionData = <String, bool>{};

    for (final entry in progressionState.entries) {
      progressionData[entry.key.name] = entry.value;
    }

    await prefs.setString(_progressionKey, jsonEncode(progressionData));
  }

  // Check if a difficulty level is unlocked
  Future<bool> isDifficultyUnlocked(DifficultyLevel level) async {
    final progressionState = await getProgressionState();
    return progressionState[level] ?? false;
  }

  // Get the next locked difficulty level
  Future<DifficultyLevel?> getNextLockedLevel() async {
    final progressionState = await getProgressionState();

    for (final level in _progressionOrder) {
      if (!(progressionState[level] ?? false)) {
        return level;
      }
    }

    return null; // All levels unlocked
  }

  // Get the highest unlocked difficulty level
  Future<DifficultyLevel> getHighestUnlockedLevel() async {
    final progressionState = await getProgressionState();

    for (int i = _progressionOrder.length - 1; i >= 0; i--) {
      final level = _progressionOrder[i];
      if (progressionState[level] ?? false) {
        return level;
      }
    }

    return DifficultyLevel.beginner; // Fallback
  }

  // Unlock the next difficulty level
  Future<void> unlockNextLevel() async {
    final progressionState = await getProgressionState();
    final nextLockedLevel = await getNextLockedLevel();

    if (nextLockedLevel != null) {
      progressionState[nextLockedLevel] = true;
      await saveProgressionState(progressionState);
      notifyListeners(); // Notify listeners of the change
    }
  }

  // Check if a session qualifies for unlocking the next level
  Future<bool> checkSessionCompletion({
    required DifficultyLevel completedLevel,
    required double accuracy,
    required int totalQuestions,
  }) async {
    // Must achieve 100% accuracy to unlock next level
    if (accuracy < 1.0) return false;

    // Must complete at least 5 questions
    if (totalQuestions < 5) return false;

    // Check if this level is currently the highest unlocked
    final highestUnlocked = await getHighestUnlockedLevel();
    if (completedLevel != highestUnlocked) return false;

    // Check if there's a next level to unlock
    final nextLockedLevel = await getNextLockedLevel();
    if (nextLockedLevel == null) return false; // All levels already unlocked

    return true;
  }

  // Process session completion and unlock next level if qualified
  Future<bool> processSessionCompletion({
    required DifficultyLevel completedLevel,
    required double accuracy,
    required int totalQuestions,
  }) async {
    final canUnlock = await checkSessionCompletion(
      completedLevel: completedLevel,
      accuracy: accuracy,
      totalQuestions: totalQuestions,
    );

    if (canUnlock) {
      await unlockNextLevel();
      return true; // Level was unlocked
    }

    return false; // Level was not unlocked
  }

  // Get completion requirements for a level
  String getCompletionRequirements(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return 'Complete 5+ questions with 100% accuracy';
      case DifficultyLevel.easy:
        return 'Complete 5+ questions with 100% accuracy';
      case DifficultyLevel.medium:
        return 'Complete 5+ questions with 100% accuracy';
      case DifficultyLevel.hard:
        return 'Complete 5+ questions with 100% accuracy';
      case DifficultyLevel.expert:
        return 'Complete 5+ questions with 100% accuracy';
    }
  }

  // Get the level description
  String getLevelDescription(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return 'Start your math journey with basic numbers 0-3';
      case DifficultyLevel.easy:
        return 'Practice with numbers 0-5 and build confidence';
      case DifficultyLevel.medium:
        return 'Challenge yourself with numbers 0-7';
      case DifficultyLevel.hard:
        return 'Master advanced problems with numbers 0-9';
      case DifficultyLevel.expert:
        return 'Become a math expert with numbers 0-12';
    }
  }

  // Get the level icon
  String getLevelIcon(DifficultyLevel level) {
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

  // Get the level color
  int getLevelColor(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return 0xFF4CAF50; // Green
      case DifficultyLevel.easy:
        return 0xFF2196F3; // Blue
      case DifficultyLevel.medium:
        return 0xFFFF9800; // Orange
      case DifficultyLevel.hard:
        return 0xFFE91E63; // Pink
      case DifficultyLevel.expert:
        return 0xFF9C27B0; // Purple
    }
  }

  // Reset progression (for testing or reset functionality)
  Future<void> resetProgression() async {
    final initialState = <DifficultyLevel, bool>{};
    for (final level in DifficultyLevel.values) {
      initialState[level] = level == DifficultyLevel.beginner;
    }
    await saveProgressionState(initialState);
  }

  // Get total unlocked levels count
  Future<int> getUnlockedLevelsCount() async {
    final progressionState = await getProgressionState();
    return progressionState.values.where((isUnlocked) => isUnlocked).length;
  }

  // Get total levels count
  int getTotalLevelsCount() => DifficultyLevel.values.length;

  // Get progress percentage
  Future<double> getProgressPercentage() async {
    final unlockedCount = await getUnlockedLevelsCount();
    final totalCount = getTotalLevelsCount();
    return unlockedCount / totalCount;
  }
}
