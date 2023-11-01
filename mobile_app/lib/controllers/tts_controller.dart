import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

// Controller for Flutter TTS
class TtsController extends GetxController {
  final _tts = FlutterTts();
  var _rate = 0.4;
  // Getter
  FlutterTts tts() {
    return this._tts;
  }

  get rate => this._rate;

  void changeRate(double value) {}

  void increaseRate() {
    changeRate(0.1);
    if (_rate <= 1.0) {
      this._rate += 0.1;
      this._tts.setSpeechRate(this._rate);
    }
    print("Current rate is : ${_rate}");
  }

  void decreaseRate() {
    if (_rate > 0) {
      this._rate -= 0.1;
      this._tts.setSpeechRate(this._rate);
    }
    print("Current rate is : ${_rate}");
  }

  // Change Language
  void setLanguage(String value) {
    this._tts.setLanguage(value);
  }

  // Change SpeechRate
  void setSpeechRate(double value) {
    this._tts.setSpeechRate(value);
  }

  // Speak value
  void speak(String value) {
    this._tts.speak(value);
  }
}
