// import 'package:flutter/material.dart';
// import '../../../core/theme/app_theme.dart';
// import '../../../core/constants/app_constants.dart';

// class HomeView extends StatefulWidget {
//   const HomeView({super.key});

//   @override
//   State<HomeView> createState() => _HomeViewState();
// }

// class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
//   late AnimationController _fadeController;
//   late AnimationController _slideController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeOut,
//     ));

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _slideController,
//       curve: Curves.easeOutCubic,
//     ));

//     _fadeController.forward();
//     _slideController.forward();
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _slideController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isMobile = screenWidth < 768;
//     final padding = isMobile ? 16.0 : 24.0;

//     return Scaffold(
//       backgroundColor: AppTheme.backgroundLight,
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return SingleChildScrollView(
//               padding: EdgeInsets.all(padding),
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(
//                   minHeight: constraints.maxHeight - (padding * 2),
//                 ),
//                 child: Column(
//                   children: [
//                     SizedBox(height: isMobile ? 20 : 40),

//                     // Hero Section
//                     FadeTransition(
//                       opacity: _fadeAnimation,
//                       child: SlideTransition(
//                         position: _slideAnimation,
//                         child: _buildHeroSection(context, isMobile),
//                       ),
//                     ),

//                     SizedBox(height: isMobile ? 30 : 60),

//                     // Mode Selection Cards
//                     FadeTransition(
//                       opacity: _fadeAnimation,
//                       child: Column(
//                         children: [
//                           // Addition Card
//                           _buildModeCard(
//                             context: context,
//                             title: 'Addition Practice',
//                             subtitle: 'Master basic addition with numbers 0-9',
//                             icon: Icons.add_circle_outline,
//                             gradient: AppTheme.successGradient,
//                             onTap: () => Navigator.pushNamed(
//                                 context, AppConstants.additionRoute),
//                             isMobile: isMobile,
//                           ),

//                           SizedBox(height: isMobile ? 16 : 20),

//                           // Multiplication Card
//                           _buildModeCard(
//                             context: context,
//                             title: 'Multiplication Practice',
//                             subtitle:
//                                 'Master basic multiplication with numbers 0-9',
//                             icon: Icons.close_rounded,
//                             gradient: AppTheme.primaryGradient,
//                             onTap: () => Navigator.pushNamed(
//                                 context, AppConstants.multiplicationRoute),
//                             isMobile: isMobile,
//                           ),
//                         ],
//                       ),
//                     ),

//                     SizedBox(height: isMobile ? 30 : 40),

//                     // Instructions Card
//                     FadeTransition(
//                       opacity: _fadeAnimation,
//                       child: _buildInstructionsCard(context, isMobile),
//                     ),

//                     SizedBox(height: isMobile ? 16 : 20),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildHeroSection(BuildContext context, bool isMobile) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(isMobile ? 24 : 32),
//       decoration: BoxDecoration(
//         gradient: AppTheme.primaryGradient,
//         borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
//         boxShadow: [
//           BoxShadow(
//             color: AppTheme.primaryPurple.withOpacity(0.3),
//             blurRadius: isMobile ? 15 : 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Container(
//             padding: EdgeInsets.all(isMobile ? 16 : 20),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
//             ),
//             child: Icon(
//               Icons.school_outlined,
//               size: isMobile ? 48 : 64,
//               color: Colors.white,
//             ),
//           ),
//           SizedBox(height: isMobile ? 16 : 24),
//           Text(
//             'Math Drill Master',
//             style: Theme.of(context).textTheme.displayMedium?.copyWith(
//                   fontWeight: FontWeight.w700,
//                   color: Colors.white,
//                   fontSize: isMobile ? 24 : 28,
//                 ),
//             textAlign: TextAlign.center,
//           ),
//           SizedBox(height: isMobile ? 8 : 12),
//           Text(
//             'Build confidence through practice',
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                   color: Colors.white.withOpacity(0.9),
//                   fontWeight: FontWeight.w500,
//                   fontSize: isMobile ? 14 : 16,
//                 ),
//             textAlign: TextAlign.center,
//           ),
//           SizedBox(height: isMobile ? 4 : 8),
//           Text(
//             'Perfect for ages 6-12',
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   color: Colors.white.withOpacity(0.8),
//                   fontSize: isMobile ? 12 : 14,
//                 ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildModeCard({
//     required BuildContext context,
//     required String title,
//     required String subtitle,
//     required IconData icon,
//     required LinearGradient gradient,
//     required VoidCallback onTap,
//     required bool isMobile,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: isMobile ? 15 : 20,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
//           child: Container(
//             padding: EdgeInsets.all(isMobile ? 20 : 24),
//             decoration: BoxDecoration(
//               color: AppTheme.backgroundCard,
//               borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
//               border: Border.all(
//                 color: Colors.grey.withOpacity(0.1),
//                 width: 1,
//               ),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(isMobile ? 12 : 16),
//                   decoration: BoxDecoration(
//                     gradient: gradient,
//                     borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: gradient.colors.first.withOpacity(0.3),
//                         blurRadius: isMobile ? 8 : 12,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Icon(
//                     icon,
//                     size: isMobile ? 24 : 32,
//                     color: Colors.white,
//                   ),
//                 ),
//                 SizedBox(width: isMobile ? 16 : 20),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         title,
//                         style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                               fontWeight: FontWeight.w600,
//                               color: AppTheme.textPrimary,
//                               fontSize: isMobile ? 16 : 18,
//                             ),
//                       ),
//                       SizedBox(height: isMobile ? 4 : 6),
//                       Text(
//                         subtitle,
//                         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                               color: AppTheme.textSecondary,
//                               fontSize: isMobile ? 12 : 14,
//                             ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.all(isMobile ? 6 : 8),
//                   decoration: BoxDecoration(
//                     color: AppTheme.surfaceElevated,
//                     borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
//                   ),
//                   child: Icon(
//                     Icons.arrow_forward_ios_rounded,
//                     size: isMobile ? 12 : 16,
//                     color: AppTheme.textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInstructionsCard(BuildContext context, bool isMobile) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(isMobile ? 20 : 24),
//       decoration: BoxDecoration(
//         color: AppTheme.backgroundCard,
//         borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
//         border: Border.all(
//           color: Colors.grey.withOpacity(0.1),
//           width: 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: isMobile ? 12 : 15,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(isMobile ? 6 : 8),
//                 decoration: BoxDecoration(
//                   color: AppTheme.info.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
//                 ),
//                 child: Icon(
//                   Icons.lightbulb_outline,
//                   color: AppTheme.info,
//                   size: isMobile ? 16 : 20,
//                 ),
//               ),
//               SizedBox(width: isMobile ? 8 : 12),
//               Text(
//                 'How to Play',
//                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.w600,
//                       color: AppTheme.textPrimary,
//                       fontSize: isMobile ? 16 : 18,
//                     ),
//               ),
//             ],
//           ),
//           SizedBox(height: isMobile ? 12 : 16),
//           _buildInstructionItem(
//             context,
//             '⏱️',
//             '3 seconds per question',
//             'Quick thinking builds confidence',
//             isMobile,
//           ),
//           SizedBox(height: isMobile ? 8 : 12),
//           _buildInstructionItem(
//             context,
//             '🎯',
//             'Earn points for correct answers',
//             'Track your progress in real-time',
//             isMobile,
//           ),
//           SizedBox(height: isMobile ? 8 : 12),
//           _buildInstructionItem(
//             context,
//             '🔄',
//             'Practice makes perfect',
//             'Reset anytime to start fresh',
//             isMobile,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInstructionItem(
//     BuildContext context,
//     String emoji,
//     String title,
//     String subtitle,
//     bool isMobile,
//   ) {
//     return Row(
//       children: [
//         Text(
//           emoji,
//           style: TextStyle(fontSize: isMobile ? 16 : 20),
//         ),
//         SizedBox(width: isMobile ? 8 : 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.w600,
//                       color: AppTheme.textPrimary,
//                       fontSize: isMobile ? 14 : 16,
//                     ),
//               ),
//               Text(
//                 subtitle,
//                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                       color: AppTheme.textSecondary,
//                       fontSize: isMobile ? 11 : 12,
//                     ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
