import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../data/models/auth_models.dart';
import '../../../services/session_history_service.dart';
import '../../../services/gamification_service.dart';

class UserInfoTab extends StatefulWidget {
  const UserInfoTab({super.key});

  @override
  State<UserInfoTab> createState() => _UserInfoTabState();
}

class _UserInfoTabState extends State<UserInfoTab> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
    }
  }

  Future<void> _updateProfile() async {
    if (!_isEditing) {
      setState(() {
        _isEditing = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isEditing = false;
      });

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Failed to update profile'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        if (user == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            children: [
              // Profile Header
              _buildProfileHeader(context, user, isMobile),

              SizedBox(height: isMobile ? 24 : 32),

              // User Stats
              _buildUserStats(context, isMobile),

              SizedBox(height: isMobile ? 24 : 32),

              // Profile Form
              _buildProfileForm(context, isMobile),

              SizedBox(height: isMobile ? 24 : 32),

              // Action Buttons
              _buildActionButtons(context, isMobile),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, User user, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withOpacity(0.3),
            blurRadius: isMobile ? 15 : 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: isMobile ? 80 : 100,
            height: isMobile ? 80 : 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(isMobile ? 40 : 50),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                user.name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: isMobile ? 32 : 40,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          SizedBox(height: isMobile ? 16 : 20),

          // Name
          Text(
            user.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: isMobile ? 20 : 24,
                ),
          ),

          SizedBox(height: isMobile ? 4 : 8),

          // Email
          Text(
            user.email,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: isMobile ? 14 : 16,
                ),
          ),

          SizedBox(height: isMobile ? 8 : 12),

          // Member Since
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
            ),
            child: Text(
              'Member since ${_formatDate(user.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isMobile ? 12 : 14,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStats(BuildContext context, bool isMobile) {
    return Consumer2<SessionHistoryService, GamificationService>(
      builder: (context, historyService, gamificationService, child) {
        return FutureBuilder(
          future: Future.wait([
            historyService.getAllSessions(),
            historyService.getUserProfile(),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: isMobile ? 120 : 140,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundCard,
                  borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Container(
                height: isMobile ? 120 : 140,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundCard,
                  borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Unable to load stats',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ),
              );
            }

            final sessions = snapshot.data?[0] as List<dynamic> ?? [];
            final profile = snapshot.data?[1] as dynamic;

            final totalSessions = sessions.length;
            final totalQuestions = sessions.length * 10; // Simplified for now
            final correctAnswers = sessions.length * 8; // Simplified for now
            final accuracy = totalQuestions > 0
                ? (correctAnswers / totalQuestions * 100).round()
                : 0;

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
                    'Your Stats',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  SizedBox(height: isMobile ? 16 : 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Sessions',
                          totalSessions.toString(),
                          Icons.play_circle_outline,
                          Colors.blue,
                          isMobile,
                        ),
                      ),
                      SizedBox(width: isMobile ? 12 : 16),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Questions',
                          totalQuestions.toString(),
                          Icons.quiz_outlined,
                          Colors.green,
                          isMobile,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 12 : 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Accuracy',
                          '$accuracy%',
                          Icons.gps_fixed,
                          Colors.orange,
                          isMobile,
                        ),
                      ),
                      SizedBox(width: isMobile ? 12 : 16),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Level',
                          '${profile?.level ?? 1}',
                          Icons.star_outline,
                          Colors.purple,
                          isMobile,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: isMobile ? 24 : 28,
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  fontSize: isMobile ? 18 : 22,
                ),
          ),
          SizedBox(height: isMobile ? 4 : 6),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: isMobile ? 12 : 14,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm(BuildContext context, bool isMobile) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profile Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
              ),
              IconButton(
                onPressed: _updateProfile,
                icon: Icon(
                  _isEditing ? Icons.save : Icons.edit,
                  color: AppTheme.primaryPurple,
                ),
              ),
            ],
          ),

          SizedBox(height: isMobile ? 20 : 24),

          // Name Field
          TextFormField(
            controller: _nameController,
            enabled: _isEditing,
            decoration: InputDecoration(
              labelText: 'Full Name',
              prefixIcon:
                  Icon(Icons.person_outline, color: AppTheme.primaryPurple),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                borderSide: BorderSide(color: AppTheme.primaryPurple, width: 2),
              ),
              filled: true,
              fillColor: _isEditing
                  ? AppTheme.surfaceElevated
                  : Colors.grey.withOpacity(0.1),
            ),
          ),

          SizedBox(height: isMobile ? 16 : 20),

          // Email Field
          TextFormField(
            controller: _emailController,
            enabled: _isEditing,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon:
                  Icon(Icons.email_outlined, color: AppTheme.primaryPurple),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                borderSide: BorderSide(color: AppTheme.primaryPurple, width: 2),
              ),
              filled: true,
              fillColor: _isEditing
                  ? AppTheme.surfaceElevated
                  : Colors.grey.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isMobile) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: isMobile ? 56 : 64,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _updateProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    width: isMobile ? 20 : 24,
                    height: isMobile ? 20 : 24,
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    _isEditing ? 'Save Changes' : 'Edit Profile',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: isMobile ? 16 : 18,
                        ),
                  ),
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),
        SizedBox(
          width: double.infinity,
          height: isMobile ? 56 : 64,
          child: OutlinedButton(
            onPressed: () {
              // TODO: Implement change password
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Change password feature coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryPurple,
              side: BorderSide(color: AppTheme.primaryPurple),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
              ),
            ),
            child: Text(
              'Change Password',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryPurple,
                    fontSize: isMobile ? 16 : 18,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
