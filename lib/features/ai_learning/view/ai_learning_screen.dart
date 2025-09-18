import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

class AILearningScreen extends StatefulWidget {
  const AILearningScreen({super.key});

  @override
  State<AILearningScreen> createState() => _AILearningScreenState();
}

class _AILearningScreenState extends State<AILearningScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _questionController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _addWelcomeMessage();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  void _addWelcomeMessage() {
    _messages.add(ChatMessage(
      text:
          "Hello! I'm your AI Learning Assistant. I can help you learn about:\n\n"
          "📚 Math concepts and problem-solving\n"
          "🧮 Advanced arithmetic techniques\n"
          "📊 Data analysis and statistics\n"
          "🔢 Number theory and patterns\n"
          "📈 Mathematical applications in real life\n\n"
          "What would you like to learn today?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'AI Learning Assistant',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
                fontSize: 18,
              ),
        ),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') {
                    _handleLogout(context);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        const Icon(Icons.logout),
                        const SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    authProvider.currentUser?.name
                            .substring(0, 1)
                            .toUpperCase() ??
                        'U',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Quick Learning Topics
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildQuickTopics(),
            ),
          ),

          // Chat Messages
          Expanded(
            child: _buildChatMessages(),
          ),

          // Input Area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildQuickTopics() {
    final topics = [
      {'title': 'Fractions', 'icon': Icons.calculate, 'color': Colors.blue},
      {'title': 'Algebra', 'icon': Icons.functions, 'color': Colors.green},
      {
        'title': 'Geometry',
        'icon': Icons.shape_line_outlined,
        'color': Colors.orange
      },
      {'title': 'Statistics', 'icon': Icons.bar_chart, 'color': Colors.purple},
      {'title': 'Trigonometry', 'icon': Icons.waves, 'color': Colors.red},
      {'title': 'Calculus', 'icon': Icons.trending_up, 'color': Colors.teal},
    ];

    return Container(
      margin: const EdgeInsets.all(20),
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
                Icons.lightbulb_outline,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Quick Learning Topics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: topics.map((topic) {
              return GestureDetector(
                onTap: () => _askAboutTopic(topic['title'] as String),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: (topic['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (topic['color'] as Color).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        topic['icon'] as IconData,
                        color: topic['color'] as Color,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        topic['title'] as String,
                        style: TextStyle(
                          color: topic['color'] as Color,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessages() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          return _buildMessageBubble(message);
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.smart_toy,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Theme.of(context).primaryColor
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: message.isUser
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: message.isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.grey[800],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey[500],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.person,
                color: Colors.grey[600],
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _questionController,
                decoration: const InputDecoration(
                  hintText: 'Ask me anything about math...',
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                maxLines: null,
                onSubmitted: _isLoading ? null : (value) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _isLoading ? null : _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isLoading
                    ? Colors.grey[300]
                    : Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _askAboutTopic(String topic) {
    _questionController.text = "Can you explain $topic in simple terms?";
    _sendMessage();
  }

  void _sendMessage() {
    final text = _questionController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _questionController.clear();

    // Simulate AI response
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: _generateAIResponse(text),
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });
      }
    });
  }

  String _generateAIResponse(String question) {
    final lowerQuestion = question.toLowerCase();

    if (lowerQuestion.contains('fraction')) {
      return "Fractions represent parts of a whole! Think of a pizza cut into slices. If you have 3 slices out of 8 total slices, that's 3/8. The top number (numerator) tells you how many parts you have, and the bottom number (denominator) tells you how many equal parts the whole is divided into. Would you like me to explain how to add, subtract, multiply, or divide fractions?";
    } else if (lowerQuestion.contains('algebra')) {
      return "Algebra is like solving puzzles with letters! Instead of just numbers, we use variables (like x, y) to represent unknown values. For example, if x + 5 = 12, we can figure out that x = 7. Algebra helps us solve real-world problems and understand patterns. Would you like to start with basic equations or learn about specific algebraic concepts?";
    } else if (lowerQuestion.contains('geometry')) {
      return "Geometry is the study of shapes, sizes, and space! It's everywhere around us - from the rectangular screens we look at to the circular wheels on cars. We learn about points, lines, angles, triangles, circles, and 3D shapes. Geometry helps us understand how things fit together and measure distances and areas. What specific geometric concept interests you?";
    } else if (lowerQuestion.contains('statistics')) {
      return "Statistics helps us make sense of data! It's about collecting, organizing, and interpreting information. For example, if you want to know the average height of students in your class, you'd collect everyone's height, add them up, and divide by the number of students. Statistics helps us spot trends, make predictions, and make informed decisions. Would you like to learn about mean, median, mode, or data visualization?";
    } else if (lowerQuestion.contains('trigonometry')) {
      return "Trigonometry is about the relationships between angles and sides in triangles! It's incredibly useful in engineering, physics, and even computer graphics. The main trigonometric functions are sine, cosine, and tangent. They help us calculate distances, heights, and angles in real-world situations. Would you like to start with the basics of right triangles or explore specific applications?";
    } else if (lowerQuestion.contains('calculus')) {
      return "Calculus is the mathematics of change! It helps us understand how things change over time - like how fast a car is accelerating or how a population grows. There are two main branches: differential calculus (finding rates of change) and integral calculus (finding areas under curves). Calculus is essential in physics, engineering, economics, and many other fields. Would you like to explore derivatives or integrals?";
    } else {
      return "That's a great question! I'd be happy to help you learn about that topic. Could you be more specific about what aspect you'd like to explore? For example, are you looking for:\n\n• Basic concepts and definitions\n• Step-by-step problem solving\n• Real-world applications\n• Practice problems\n• Visual explanations\n\nFeel free to ask me anything about math, and I'll do my best to explain it in a way that makes sense!";
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
