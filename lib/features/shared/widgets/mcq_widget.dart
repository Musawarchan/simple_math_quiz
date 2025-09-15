import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class MCQWidget extends StatefulWidget {
  final List<int> options;
  final int correctAnswer;
  final Function(int) onAnswerSelected;

  const MCQWidget({
    super.key,
    required this.options,
    required this.correctAnswer,
    required this.onAnswerSelected,
  });

  @override
  State<MCQWidget> createState() => _MCQWidgetState();
}

class _MCQWidgetState extends State<MCQWidget> {
  int? selectedOption;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: isMobile ? 12 : 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose the correct answer:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                  fontSize: isMobile ? 14 : 16,
                ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          ...widget.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = selectedOption == option;

            return Container(
              margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedOption = option;
                    });
                    widget.onAnswerSelected(option);
                  },
                  borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isMobile ? 16 : 20),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryPurple.withOpacity(0.1)
                          : AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryPurple
                            : Colors.grey.withOpacity(0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: isMobile ? 24 : 28,
                          height: isMobile ? 24 : 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AppTheme.primaryPurple
                                : Colors.grey.withOpacity(0.3),
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + index), // A, B, C, D
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: isMobile ? 12 : 14,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: isMobile ? 12 : 16),
                        Expanded(
                          child: Text(
                            '$option',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? AppTheme.primaryPurple
                                      : AppTheme.textPrimary,
                                  fontSize: isMobile ? 16 : 18,
                                ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: AppTheme.primaryPurple,
                            size: isMobile ? 20 : 24,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
