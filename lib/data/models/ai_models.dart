class AIChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? messageId;

  const AIChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.messageId,
  });

  factory AIChatMessage.user(String text) {
    return AIChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      messageId: _generateId(),
    );
  }

  factory AIChatMessage.ai(String text) {
    return AIChatMessage(
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      messageId: _generateId(),
    );
  }

  factory AIChatMessage.fromJson(Map<String, dynamic> json) {
    return AIChatMessage(
      text: json['text'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      messageId: json['messageId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'messageId': messageId,
    };
  }

  AIChatMessage copyWith({
    String? text,
    bool? isUser,
    DateTime? timestamp,
    String? messageId,
  }) {
    return AIChatMessage(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      messageId: messageId ?? this.messageId,
    );
  }

  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AIChatMessage &&
        other.text == text &&
        other.isUser == isUser &&
        other.timestamp == timestamp &&
        other.messageId == messageId;
  }

  @override
  int get hashCode {
    return text.hashCode ^
        isUser.hashCode ^
        timestamp.hashCode ^
        messageId.hashCode;
  }

  @override
  String toString() {
    return 'AIChatMessage(text: $text, isUser: $isUser, timestamp: $timestamp, messageId: $messageId)';
  }
}

class AIConversationState {
  final List<AIChatMessage> messages;
  final bool isLoading;
  final String? errorMessage;
  final bool isInitialized;

  const AIConversationState({
    this.messages = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isInitialized = false,
  });

  AIConversationState copyWith({
    List<AIChatMessage>? messages,
    bool? isLoading,
    String? errorMessage,
    bool? isInitialized,
  }) {
    return AIConversationState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AIConversationState &&
        other.messages == messages &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage &&
        other.isInitialized == isInitialized;
  }

  @override
  int get hashCode {
    return messages.hashCode ^
        isLoading.hashCode ^
        errorMessage.hashCode ^
        isInitialized.hashCode;
  }
}
