import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:speech_recognition/speech_recognition.dart';


class SpeechTText with ChangeNotifier {
  SpeechRecognition _speechRecognition;
  bool isAvailable = false;
  bool isListening = false;
  String resultText;
  dynamic ttsState;

  // Initializing Speech Recognizer
  Future<void> initSpeechRecognizer() async {
    _speechRecognition = SpeechRecognition();
    _speechRecognition.setRecognitionStartedHandler(
      () => isListening = true,
    );
    _speechRecognition.setRecognitionResultHandler((String speech) {
      resultText = speech;
      notifyListeners();
    });

    _speechRecognition.setRecognitionCompleteHandler(() {
      isListening = false;
    });

    await _speechRecognition.activate();
    isAvailable = true;
  }

  // Async Function To Stop Current Event
  Future<dynamic> stop() async {
    if (isListening) {
      dynamic result = await _speechRecognition.stop();
      return result;
    } else {
      return "ERROR";
    }
  }

  // Async Function To Cancel Current Event
  Future<bool> cancel() async {
    if (isListening) {
      dynamic result = await _speechRecognition.cancel();
      isListening = result;
    }
    return true;
  }

  // Async Function To Start A New Event
  Future<bool> listen() async {
    if (isAvailable && !isListening) {
      await _speechRecognition.listen(locale: "en_IN");
      isListening = true;
      await waitTillListening();
    }
    print('winking');
    return true;
  }

  // Helper Async Function To Wait Till Event Finishes 
  Future waitTillListening([Duration pollInterval = Duration.zero]) {
    var completer = new Completer();
    check() {
      if (isAvailable && !isListening) {
        completer.complete();
      } else {
        new Timer(pollInterval, check);
      }
    }
    check();
    return completer.future;
  }
}
