import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sales_ai_examples/src/sales_ai/bloc/sales_ai_bloc.dart';
import 'package:sales_ai_examples/src/sales_ai/utils/helpers.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';



enum ListenStatus { error, listening, done }

class PromptField extends StatefulWidget {
  const PromptField({
    super.key,
  });

  @override
  State<PromptField> createState() => _PromptFieldState();
}

class _PromptFieldState extends State<PromptField> {
  final GlobalKey<FormState> _salesAIKey = GlobalKey();
  late final TextEditingController _salesAIController;
  late final SpeechToText _speech;
  ListenStatus _listenStatus = ListenStatus.done;
  // Duration to listen for
  Duration listenFor = const Duration(minutes: 1);
  int listenNow = 0;
  Timer? listenTimer;

  LogicalKeyboardKey? immediateKeyboardKey;

  @override
  void initState() {
    _salesAIController = TextEditingController();
    _speech = SpeechToText();
    super.initState();
  }

  @override
  void dispose() {
    _salesAIController.dispose();
    _speech.cancel();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _salesAIKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            switch (_listenStatus) {
              ListenStatus.done => IconButton.outlined(
                  onPressed: _start,
                  icon: const Icon(Icons.mic),
                ),
              ListenStatus.listening => IconButton.outlined(
                  onPressed: _stop,
                  icon: Text("$listenNow"),
                ),
              ListenStatus.error => IconButton.outlined(
                  onPressed: requestAllNeededPermissions,
                  icon: const Icon(Icons.mic_external_off),
                  color: Theme.of(context).colorScheme.error,
                ),
            },
            Flexible(
              child: TextFormField(
                controller: _salesAIController,
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                  ),
                ),
              ),
            ),
            IconButton.filled(
              onPressed: _sendUserChat,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }

  void _sendUserChat() {
    if (_salesAIKey.currentState!.validate()) {
      context.read<SalesAiBloc>().add(
            SendUserChat(
              _salesAIController.text,
            ),
          );
      _salesAIController.clear();
    }
  }

  Future<void> _start() async {
    bool available = await _speech.initialize(
      onStatus: statusListener,
      onError: errorListener,
    );
    if (available) {
      setState(() {
        listenNow = listenFor.inSeconds;
        _listenStatus = ListenStatus.listening;
      });
      await _speech.listen(
        onResult: resultListener,
        listenFor: listenFor,
      );
      // Automatic stoping at timeout
      listenTimer = Timer.periodic(
        const Duration(seconds: 1),
        (Timer timer) async {
          if (listenNow < 1) {
            timer.cancel();
            await _stop();
          } else {
            setState(() {
              listenNow--;
            });
          }
        },
      );
    } else {
      debugPrint("The user has denied the use of speech recognition.");
      setState(() {
        _listenStatus = ListenStatus.error;
      });
    }
  }

  Future<void> _stop() async {
    await _speech.stop();
    listenTimer?.cancel();
    setState(() {
      _listenStatus = ListenStatus.done;
    });
  }

  void statusListener(String status) async {
    debugPrint(status);
    if (status == "done") {
      await _stop();
    }
  }

  void errorListener(SpeechRecognitionError errorNotification) {
    debugPrint("error");
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      _salesAIController.text = result.recognizedWords;
    });
  }
}

