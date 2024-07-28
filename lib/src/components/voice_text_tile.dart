import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceTextTile extends StatefulWidget {
  const VoiceTextTile(
    this.title, {
    super.key,
    this.subtitle,
    this.titleAlign = WrapAlignment.start,
    this.subtitleAlign = MainAxisAlignment.start,
    this.voiceActive = false,
    this.autoVoiceActive = false,
  });

  final String title;
  final String? subtitle;
  final WrapAlignment titleAlign;
  final MainAxisAlignment subtitleAlign;
  final bool voiceActive, autoVoiceActive;

  @override
  State<VoiceTextTile> createState() => _VoiceTextTileState();
}

class _VoiceTextTileState extends State<VoiceTextTile> {
  late final FlutterTts flutterTts;
  @override
  void initState() {
    flutterTts = FlutterTts();
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (Platform.isIOS) {
        // Set IOS Platform settings
        await flutterTts.setSharedInstance(true);
        await flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.ambient,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers
          ],
          IosTextToSpeechAudioMode.voicePrompt,
        );
      }
      // Set General Platform settings
      await flutterTts.awaitSpeakCompletion(true);
      await flutterTts.awaitSynthCompletion(true);
      await flutterTts.setSpeechRate(0.7);
      if (widget.autoVoiceActive) {
        await _speak();
      }
    });
  }

  Future _speak() async {
    await flutterTts.speak(widget.title);
  }

  Future _stop() async {
    await flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Markdown(
        data: widget.title,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          p: Theme.of(context).textTheme.bodyLarge,
          textAlign: widget.titleAlign,
        ),
      ),
      subtitle: Row(
        mainAxisAlignment: widget.subtitleAlign,
        children: [
          Text(widget.subtitle ?? ""),
          Visibility(
            visible: widget.voiceActive,
            child: IconButton.filledTonal(
              onPressed: _speak,
              icon: const Icon(Icons.voice_chat),
              iconSize: 18,
            ),
          )
        ],
      ),
    );
  }
}
