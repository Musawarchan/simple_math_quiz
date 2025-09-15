import '../data/models/math_models.dart';

class DrillSessionService {
  final DrillSession _session = DrillSession();

  DrillSession get session => _session;

  void startNewSession() {
    _session.reset();
    _session.startSession();
  }

  void endSession() {
    _session.stopSession();
  }

  void answerQuestion(bool isCorrect) {
    _session.answerQuestion(isCorrect);
  }

  void resetSession() {
    _session.reset();
  }

  void setCurrentQuestion(MathQuestion question) {
    _session.currentQuestion = question;
  }

  MathQuestion? get currentQuestion => _session.currentQuestion;
}
