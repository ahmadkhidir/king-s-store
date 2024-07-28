part of 'sales_ai_bloc.dart';

enum SalesAIStatus { initial, loading, loaded, error }

class SalesAiState {
  final List<Map<String, dynamic>> memory;
  final SalesAIStatus status;
  final String? statusMessage;
  final List<ChatModel> chats;
  final List<CommandModel> commands;

  SalesAiState({
    this.memory = const [],
    this.status = SalesAIStatus.loading,
    this.statusMessage,
    this.chats = const [],
    this.commands = const [],
  });

  copyWith({
    List<Map<String, dynamic>>? memory,
    SalesAIStatus? status,
    String? statusMessage,
    List<ChatModel>? chats,
    List<CommandModel>? commands,
  }) {
    return SalesAiState(
      memory: memory ?? this.memory,
      status: status ?? this.status,
      statusMessage: statusMessage ?? this.statusMessage,
      chats: chats ?? this.chats,
      commands: commands ?? this.commands,
    );
  }
}
