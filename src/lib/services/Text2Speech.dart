import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/cupertino.dart';

enum isPlaying { playing, stopped }

class TextTSpeech with ChangeNotifier {
  FlutterTts flutterTts;

  String voiceText;
  bool isPlaying = false;

  // Initializing voiceText as empty string
  TextTSpeech() {
    this.voiceText = "";
    initTts();
  }

  // Initializing Text To Speech Instance
  initTts() {
    flutterTts = FlutterTts();
    flutterTts.setStartHandler(() {
      this.isPlaying = true;
    });

    flutterTts.setLanguage('en-IN');
    flutterTts.setCompletionHandler(() {
      print("Complete");
      this.isPlaying = false;
      notifyListeners();
    });

    flutterTts.setErrorHandler((msg) {
      this.isPlaying = false;
    });
  }

  // Async Function To speak the current value of this.voiceText
  Future<bool> speak() async {
    if (voiceText != null) {
      if (voiceText.isNotEmpty) {
        var result = await flutterTts.speak(voiceText);
        if (result == 1) isPlaying = true;
      }
    }
    await waitTillPlayStop();
    print("I am done");
    return true;
  }

  // Async Function To stop the current event
  Future stop() async {
    var result = await flutterTts.stop();
    if (result == 1) isPlaying = false;

    // waitWhile(test).
  }

  // Helper Async Function To Wait Till Event Finishes 
  Future waitTillPlayStop([Duration pollInterval = Duration.zero]) {
    var completer = new Completer();
    check() {
      if (!isPlaying) {
        completer.complete();
      } else {
        new Timer(pollInterval, check);
      }
    }
    check();
    return completer.future;
  }
}
