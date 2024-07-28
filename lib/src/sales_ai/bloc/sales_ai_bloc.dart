import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../utils/data_provider.dart';
import '../utils/models.dart';

part 'sales_ai_event.dart';
part 'sales_ai_state.dart';

class SalesAiBloc extends Bloc<SalesAiEvent, SalesAiState> {
  final SalesAIRepository _salesAIRepository;
  SalesAiBloc({
    required SalesAIRepository salesAIRepository,
  })  : _salesAIRepository = salesAIRepository,
        super(
          SalesAiState(),
        ) {
    on<LoadToMemory>(_onLoadToMemory);
    on<SendAIChat>(_onSendAIChat);
    on<SendUserChat>(_onSendUserChat);
    on<DeleteAICommand>(_onDeleteAICommand);
  }

  FutureOr<void> _onLoadToMemory(
    LoadToMemory event,
    Emitter<SalesAiState> emit,
  ) async {
    emit(state.copyWith(status: SalesAIStatus.loading));
    try {
      // final memory = await _salesAIRepository.loadData(event.memorySnapshot);
      emit(state.copyWith(status: SalesAIStatus.loaded, memory: event.memory));
    } catch (e) {
      emit(
        state.copyWith(
          status: SalesAIStatus.error,
          statusMessage: e.toString(),
        ),
      );
    }
  }

  FutureOr<void> _onSendAIChat(
    SendAIChat event,
    Emitter<SalesAiState> emit,
  ) {
    emit(state.copyWith(status: SalesAIStatus.loading));
    try {
      final doc = XmlDocument.parse(event.message);
      final message = doc.xpath("/response/text[1]/text()").firstOrNull;
      final chat = ChatModel(
        message: message?.value ?? "",
        sender: Sender.ai,
        time: DateTime.now(),
      );
      final commands = doc.xpath("/response/commands/cmd");
      final commandsList = commands.map((node) {
        debugPrint("COMMAND: ${node.getAttribute("type")}");
        debugPrint("VALUE: ${node.innerText}");
        return CommandModel(
          type: node.getAttribute("type") ?? "",
          value: node.innerText,
        );
      }).toList();
      emit(
        state.copyWith(
          status: SalesAIStatus.loaded,
          chats: state.chats + [chat],
          commands: state.commands + commandsList,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SalesAIStatus.error,
          statusMessage: e.toString(),
        ),
      );
    }
  }

  FutureOr<void> _onSendUserChat(
    SendUserChat event,
    Emitter<SalesAiState> emit,
  ) async {
    emit(state.copyWith(status: SalesAIStatus.loading));
    try {
      final chat = ChatModel(
        message: event.message,
        sender: Sender.user,
        time: DateTime.now(),
      );
      emit(
        state.copyWith(
          // Only keep the last 5 chats
          chats: (state.chats + [chat])
              // .skip(max(
              //   state.chats.length - 5,
              //   0,
              // ))
              // .toList(),
        ),
      );
      String? response = await _salesAIRepository.getResponse(
        // prepare prompt
          state.chats.fold<String>(
            "",
            (previousValue, element) => "$previousValue\n\n${element.message}",
          ),
        // attach memory data
          state.memory);

      emit(state.copyWith(status: SalesAIStatus.loaded));
      if (response != null) {
        add(SendAIChat(response));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: SalesAIStatus.error,
          statusMessage: e.toString(),
        ),
      );
    }
  }

  FutureOr<void> _onDeleteAICommand(
    DeleteAICommand event,
    Emitter<SalesAiState> emit,
  ) {
    final commands = state.commands
        .skipWhile((value) => value.key == event.commandKey)
        .toList();
    emit(state.copyWith(commands: commands));
  }
}
