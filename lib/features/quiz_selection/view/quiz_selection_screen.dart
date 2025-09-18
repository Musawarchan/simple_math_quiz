import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/enhanced_drill_provider.dart';
import '../../../services/difficulty_progression_service.dart';
import '../../../data/models/math_models.dart';
import '../../enhanced_drill/view/enhanced_drill_view.dart';

class QuizSelectionScreen extends StatefulWidget {
  const QuizSelectionScreen({super.key});

  @override
  State<QuizSelectionScreen> createState() => _QuizSelectionScreenState();
}

class _QuizSelectionScreenState extends State<QuizSelectionScreen> {
  DifficultyLevel? _selectedDifficulty;
  OperationType? _selectedOperation;
  QuestionType _selectedQuestionType = QuestionType.fillInBlank;
  int _questionCount = 10;
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
        // Set default to first unlocked difficulty
        for (final level in DifficultyLevel.values) {
          if (state[level] ?? false) {
            _selectedDifficulty = level;
            break;
          }
        }
        _selectedOperation = OperationType.addition; // Default operation
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Quiz Selection',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
                fontSize: 18,
              ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Difficulty Selection
            _buildSectionCard(
              title: 'Select Difficulty',
              icon: Icons.trending_up,
              child: Column(
                children: DifficultyLevel.values.map((level) {
                  final isUnlocked = _unlockedLevels[level] ?? false;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isUnlocked ? Colors.white : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isUnlocked
                            ? Theme.of(context).primaryColor.withOpacity(0.2)
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: RadioListTile<DifficultyLevel>(
                      title: Row(
                        children: [
                          Text(
                            level.name.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isUnlocked
                                  ? Colors.grey[800]
                                  : Colors.grey[500],
                            ),
                          ),
                          if (!isUnlocked) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.lock,
                              size: 16,
                              color: Colors.grey[500],
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(
                        _getDifficultyDescription(level),
                        style: TextStyle(
                          color:
                              isUnlocked ? Colors.grey[600] : Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                      value: level,
                      groupValue: _selectedDifficulty,
                      onChanged: isUnlocked
                          ? (DifficultyLevel? value) {
                              setState(() {
                                _selectedDifficulty = value;
                              });
                            }
                          : null,
                      activeColor: Theme.of(context).primaryColor,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Operation Selection
            _buildSectionCard(
              title: 'Select Operation',
              icon: Icons.calculate,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: OperationType.values.map((operation) {
                  return FilterChip(
                    label: Text(_getOperationName(operation)),
                    selected: _selectedOperation == operation,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedOperation = operation;
                      });
                    },
                    selectedColor:
                        Theme.of(context).primaryColor.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).primaryColor,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: _selectedOperation == operation
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300]!,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Question Type Selection
            _buildSectionCard(
              title: 'Question Type',
              icon: Icons.quiz,
              child: Row(
                children: [
                  Expanded(
                    child: _buildQuestionTypeCard(
                      title: 'Fill in Blank',
                      subtitle: 'Type your answer',
                      icon: Icons.edit,
                      isSelected:
                          _selectedQuestionType == QuestionType.fillInBlank,
                      onTap: () {
                        setState(() {
                          _selectedQuestionType = QuestionType.fillInBlank;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuestionTypeCard(
                      title: 'Multiple Choice',
                      subtitle: 'Choose from options',
                      icon: Icons.radio_button_checked,
                      isSelected:
                          _selectedQuestionType == QuestionType.multipleChoice,
                      onTap: () {
                        setState(() {
                          _selectedQuestionType = QuestionType.multipleChoice;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Question Count Selection
            _buildSectionCard(
              title: 'Number of Questions',
              icon: Icons.numbers,
              child: Column(
                children: [
                  Text(
                    '$_questionCount Questions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: _questionCount.toDouble(),
                    min: 5,
                    max: 50,
                    divisions: 9,
                    label: '$_questionCount',
                    activeColor: Theme.of(context).primaryColor,
                    inactiveColor: Colors.grey[300],
                    onChanged: (double value) {
                      setState(() {
                        _questionCount = value.round();
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('5',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12)),
                      Text('50',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Start Quiz Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canStartQuiz() ? _startQuiz : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Start Quiz',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildQuestionTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  bool _canStartQuiz() {
    return _selectedDifficulty != null && _selectedOperation != null;
  }

  void _startQuiz() {
    if (!_canStartQuiz()) return;

    final drillProvider =
        Provider.of<EnhancedDrillProvider>(context, listen: false);

    // Configure the drill session
    drillProvider.startSession(
      operationType: _selectedOperation!,
      questionType: _selectedQuestionType,
      difficultyLevel: _selectedDifficulty!,
      questionLimit: _questionCount,
    );

    // Navigate to drill screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EnhancedDrillView(
          operationType: _selectedOperation!,
          questionType: _selectedQuestionType,
          difficultyLevel: _selectedDifficulty!,
          questionLimit: _questionCount,
        ),
      ),
    );
  }

  String _getDifficultyDescription(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return 'Numbers 1-10, simple operations';
      case DifficultyLevel.easy:
        return 'Numbers 5-24, mixed operations';
      case DifficultyLevel.medium:
        return 'Numbers 10-59, complex operations';
      case DifficultyLevel.hard:
        return 'Numbers 20-119, challenging operations';
      case DifficultyLevel.expert:
        return 'Numbers 50-249, advanced operations';
    }
  }

  String _getOperationName(OperationType operation) {
    switch (operation) {
      case OperationType.addition:
        return 'Addition (+)';
      case OperationType.subtraction:
        return 'Subtraction (-)';
      case OperationType.multiplication:
        return 'Multiplication (×)';
      case OperationType.division:
        return 'Division (÷)';
    }
  }
}
