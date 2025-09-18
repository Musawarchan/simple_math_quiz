import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/session_history_service.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'Light';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        children: [
          // App Settings
          _buildAppSettings(context, isMobile),

          SizedBox(height: isMobile ? 24 : 32),

          // Account Settings
          _buildAccountSettings(context, isMobile),

          SizedBox(height: isMobile ? 24 : 32),

          // Data Management
          _buildDataManagement(context, isMobile),

          SizedBox(height: isMobile ? 24 : 32),

          // About Section
          _buildAboutSection(context, isMobile),
        ],
      ),
    );
  }

  Widget _buildAppSettings(BuildContext context, bool isMobile) {
    return Container(
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
            blurRadius: isMobile ? 10 : 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'App Settings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
          ),

          SizedBox(height: isMobile ? 20 : 24),

          // Sound Settings
          _buildSettingItem(
            context,
            'Sound Effects',
            'Play sounds for correct/incorrect answers',
            Icons.volume_up_outlined,
            _soundEnabled,
            (value) => setState(() => _soundEnabled = value),
            isMobile,
          ),

          SizedBox(height: isMobile ? 16 : 20),

          // Vibration Settings
          _buildSettingItem(
            context,
            'Vibration',
            'Haptic feedback for interactions',
            Icons.vibration,
            _vibrationEnabled,
            (value) => setState(() => _vibrationEnabled = value),
            isMobile,
          ),

          SizedBox(height: isMobile ? 16 : 20),

          // Notifications Settings
          _buildSettingItem(
            context,
            'Notifications',
            'Daily practice reminders',
            Icons.notifications_outlined,
            _notificationsEnabled,
            (value) => setState(() => _notificationsEnabled = value),
            isMobile,
          ),

          SizedBox(height: isMobile ? 20 : 24),

          // Language Selection
          _buildDropdownSetting(
            context,
            'Language',
            'Select your preferred language',
            Icons.language,
            _selectedLanguage,
            ['English', 'Spanish', 'French', 'German'],
            (value) => setState(() => _selectedLanguage = value!),
            isMobile,
          ),

          SizedBox(height: isMobile ? 16 : 20),

          // Theme Selection
          _buildDropdownSetting(
            context,
            'Theme',
            'Choose your preferred theme',
            Icons.palette_outlined,
            _selectedTheme,
            ['Light', 'Dark', 'Auto'],
            (value) => setState(() => _selectedTheme = value!),
            isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings(BuildContext context, bool isMobile) {
    return Container(
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
            blurRadius: isMobile ? 10 : 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Settings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
          ),

          SizedBox(height: isMobile ? 20 : 24),

          // Change Password
          _buildActionItem(
            context,
            'Change Password',
            'Update your account password',
            Icons.lock_outline,
            Colors.blue,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Change password feature coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            isMobile,
          ),

          SizedBox(height: isMobile ? 16 : 20),

          // Privacy Settings
          _buildActionItem(
            context,
            'Privacy Settings',
            'Manage your privacy preferences',
            Icons.privacy_tip_outlined,
            Colors.green,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Privacy settings coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            isMobile,
          ),

          SizedBox(height: isMobile ? 16 : 20),

          // Account Security
          _buildActionItem(
            context,
            'Account Security',
            'Two-factor authentication and security',
            Icons.security_outlined,
            Colors.orange,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Security settings coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagement(BuildContext context, bool isMobile) {
    return Container(
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
            blurRadius: isMobile ? 10 : 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data Management',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
          ),

          SizedBox(height: isMobile ? 20 : 24),

          // Export Data
          _buildActionItem(
            context,
            'Export Data',
            'Download your progress and statistics',
            Icons.download_outlined,
            Colors.blue,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data export feature coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            isMobile,
          ),

          SizedBox(height: isMobile ? 16 : 20),

          // Clear Cache
          _buildActionItem(
            context,
            'Clear Cache',
            'Free up storage space',
            Icons.cleaning_services_outlined,
            Colors.orange,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully!'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            isMobile,
          ),

          SizedBox(height: isMobile ? 16 : 20),

          // Reset Progress
          _buildActionItem(
            context,
            'Reset Progress',
            'Start over with a clean slate',
            Icons.refresh_outlined,
            Colors.red,
            () => _showResetProgressDialog(context, isMobile),
            isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context, bool isMobile) {
    return Container(
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
            blurRadius: isMobile ? 10 : 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
          ),

          SizedBox(height: isMobile ? 20 : 24),

          // App Version
          _buildInfoItem(
            context,
            'App Version',
            '1.0.0',
            Icons.info_outline,
            isMobile,
          ),

          SizedBox(height: isMobile ? 16 : 20),

          // Terms of Service
          _buildActionItem(
            context,
            'Terms of Service',
            'Read our terms and conditions',
            Icons.description_outlined,
            Colors.blue,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Terms of service coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            isMobile,
          ),

          SizedBox(height: isMobile ? 16 : 20),

          // Privacy Policy
          _buildActionItem(
            context,
            'Privacy Policy',
            'Learn about our privacy practices',
            Icons.privacy_tip_outlined,
            Colors.green,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Privacy policy coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            isMobile,
          ),

          SizedBox(height: isMobile ? 16 : 20),

          // Contact Support
          _buildActionItem(
            context,
            'Contact Support',
            'Get help and report issues',
            Icons.support_agent,
            Colors.purple,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contact support coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
    bool isMobile,
  ) {
    return Row(
      children: [
        Container(
          width: isMobile ? 40 : 48,
          height: isMobile ? 40 : 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryPurple,
            size: isMobile ? 20 : 24,
          ),
        ),
        SizedBox(width: isMobile ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
              ),
              SizedBox(height: isMobile ? 4 : 6),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryPurple,
        ),
      ],
    );
  }

  Widget _buildDropdownSetting(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
    bool isMobile,
  ) {
    return Row(
      children: [
        Container(
          width: isMobile ? 40 : 48,
          height: isMobile ? 40 : 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryPurple,
            size: isMobile ? 20 : 24,
          ),
        ),
        SizedBox(width: isMobile ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
              ),
              SizedBox(height: isMobile ? 4 : 6),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          underline: Container(),
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isMobile,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
          border: Border.all(
            color: color.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: isMobile ? 40 : 48,
              height: isMobile ? 40 : 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
              ),
              child: Icon(
                icon,
                color: color,
                size: isMobile ? 20 : 24,
              ),
            ),
            SizedBox(width: isMobile ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  SizedBox(height: isMobile ? 4 : 6),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.textSecondary,
              size: isMobile ? 16 : 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    bool isMobile,
  ) {
    return Row(
      children: [
        Container(
          width: isMobile ? 40 : 48,
          height: isMobile ? 40 : 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryPurple,
            size: isMobile ? 20 : 24,
          ),
        ),
        SizedBox(width: isMobile ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
              ),
              SizedBox(height: isMobile ? 4 : 6),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showResetProgressDialog(BuildContext context, bool isMobile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress'),
        content: const Text(
          'Are you sure you want to reset all your progress? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _resetProgress();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetProgress() async {
    try {
      final historyService =
          Provider.of<SessionHistoryService>(context, listen: false);
      await historyService.clearAllData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Progress reset successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to reset progress'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
