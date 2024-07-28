import 'package:flutter/material.dart';

enum Sender { ai, user }

class ChatModel {
  final Sender sender;
  final String message;
  final DateTime time;

  ChatModel({
    required this.sender,
    required this.message,
    required this.time,
  });
}

class CommandModel {
  final Key key = UniqueKey();
  final String type, value;

  CommandModel({
    required this.type,
    required this.value,
  });
}
