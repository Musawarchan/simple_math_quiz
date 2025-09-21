import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/ai_learning_provider.dart';

class AITestScreen extends StatefulWidget {
  const AITestScreen({super.key});

  @override
  State<AITestScreen> createState() => _AITestScreenState();
}

class _AITestScreenState extends State<AITestScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  String? _testResult;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API Key',
                hintText: 'Enter your Gemini API key',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _testAPI,
              child: const Text('Test API Key'),
            ),
            const SizedBox(height: 16),
            if (_testResult != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_testResult!),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _testAPI() async {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      setState(() {
        _testResult = 'Please enter an API key';
      });
      return;
    }

    setState(() {
      _testResult = 'Testing API key...';
    });

    try {
      final aiProvider =
          Provider.of<AILearningProvider>(context, listen: false);
      await aiProvider.setApiKey(apiKey);

      final response =
          await aiProvider.sendMessage('Hello, can you help me with math?');

      setState(() {
        _testResult = 'Success! Response: $response';
      });
    } catch (e) {
      setState(() {
        _testResult = 'Error: $e';
      });
    }
  }
}
