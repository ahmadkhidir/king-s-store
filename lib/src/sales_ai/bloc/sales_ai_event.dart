part of 'sales_ai_bloc.dart';


sealed class SalesAiEvent {}


class LoadToMemory extends SalesAiEvent {
  final List<Map<String, dynamic>> memory;
  LoadToMemory(this.memory);
}

class SendAIChat extends SalesAiEvent {
  final String message;
  SendAIChat(this.message);
}

class SendUserChat extends SalesAiEvent {
  final String message;
  SendUserChat(this.message);
}

class DeleteAICommand extends SalesAiEvent {
  final Key commandKey;
  DeleteAICommand(this.commandKey);
}