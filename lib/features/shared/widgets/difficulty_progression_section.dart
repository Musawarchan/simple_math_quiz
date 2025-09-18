import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/difficulty_progression_service.dart';
import '../../../data/models/math_models.dart';

class DifficultyProgressionSection extends StatefulWidget {
  const DifficultyProgressionSection({super.key});

  @override
  State<DifficultyProgressionSection> createState() =>
      _DifficultyProgressionSectionState();
}

class _DifficultyProgressionSectionState
    extends State<DifficultyProgressionSection> {
  Map<DifficultyLevel, bool> _unlockedLevels = {};

  @override
  void initState() {
    super.initState();
    _loadProgressionState();
  }

  Future<void> _loadProgressionState() async {
    final progressionService =
        Provider.of<DifficultyProgressionService>(context, listen: false);
    final state = await progressionService.getProgressionState();
    if (mounted) {
      setState(() {
        _unlockedLevels = state;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Progress',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...DifficultyLevel.values.map((level) {
              final isUnlocked = _unlockedLevels[level] ?? false;
              final isCompleted = false; // TODO: Implement completion tracking

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      isCompleted
                          ? Icons.check_circle
                          : isUnlocked
                              ? Icons.radio_button_unchecked
                              : Icons.lock,
                      color: isCompleted
                          ? Colors.green
                          : isUnlocked
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        level.name.toUpperCase(),
                        style: TextStyle(
                          fontWeight:
                              isCompleted ? FontWeight.bold : FontWeight.normal,
                          color: isCompleted
                              ? Colors.green
                              : isUnlocked
                                  ? Colors.black
                                  : Colors.grey,
                        ),
                      ),
                    ),
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'COMPLETED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
