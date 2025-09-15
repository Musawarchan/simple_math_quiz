import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/addition_drill_provider.dart';
import '../../shared/widgets/timer_widget.dart';
import '../../shared/widgets/answer_input_widget.dart';

class AdditionDrillView extends StatefulWidget {
  const AdditionDrillView({super.key});

  @override
  State<AdditionDrillView> createState() => _AdditionDrillViewState();
}

class _AdditionDrillViewState extends State<AdditionDrillView> {
  @override
  void initState() {
    super.initState();
    // Start the session when the view is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdditionDrillProvider>().startSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        title: const Text('Addition Drill'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<AdditionDrillProvider>().resetSession(),
            tooltip: 'Reset Session',
          ),
        ],
      ),
      body: Consumer<AdditionDrillProvider>(
        builder: (context, viewModel, child) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                children: [
                  // Score Display
                  _buildScoreDisplay(context, viewModel),

                  const SizedBox(height: 32),

                  // Timer
                  Center(
                    child: TimerWidget(
                      durationSeconds: AppConstants.timerDurationSeconds,
                      onTimeUp: viewModel.onTimeUp,
                      onTick: () {}, // Optional: Add any tick-based logic here
                      isActive: viewModel.isWaitingForAnswer,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Question Display
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (viewModel.currentQuestion != null) ...[
                          _buildQuestionDisplay(context, viewModel),

                          const SizedBox(height: 32),

                          // Result Message
                          if (viewModel.showResult)
                            _buildResultMessage(context, viewModel),

                          const SizedBox(height: 32),

                          // Answer Input
                          if (viewModel.isWaitingForAnswer)
                            AnswerInputWidget(
                              onAnswerSubmitted: viewModel.submitAnswer,
                              isEnabled: viewModel.isWaitingForAnswer,
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScoreDisplay(
      BuildContext context, AdditionDrillProvider viewModel) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScoreItem(context, 'Score', '${viewModel.session.score}',
              AppTheme.primaryGreen),
          _buildScoreItem(context, 'Questions',
              '${viewModel.session.totalQuestions}', AppTheme.primaryBlue),
          _buildScoreItem(
              context,
              'Accuracy',
              '${(viewModel.session.accuracy * 100).toStringAsFixed(0)}%',
              AppTheme.primaryOrange),
        ],
      ),
    );
  }

  Widget _buildScoreItem(
      BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildQuestionDisplay(
      BuildContext context, AdditionDrillProvider viewModel) {
    final question = viewModel.currentQuestion!;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            question.questionText,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildNumberBox(
                  context, question.operand1, AppTheme.primaryGreen),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  question.operationSymbol,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                ),
              ),
              const SizedBox(width: 16),
              _buildNumberBox(
                  context, question.operand2, AppTheme.primaryGreen),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '=',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  '?',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberBox(BuildContext context, int number, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Text(
        '$number',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
      ),
    );
  }

  Widget _buildResultMessage(
      BuildContext context, AdditionDrillProvider viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: viewModel.isCorrect ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        border: Border.all(
          color: viewModel.isCorrect ? Colors.green[200]! : Colors.red[200]!,
        ),
      ),
      child: Text(
        viewModel.resultMessage,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: viewModel.isCorrect ? Colors.green[700] : Colors.red[700],
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
