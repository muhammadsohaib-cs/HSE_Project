import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioAlarmService {
  static final AudioAlarmService _instance = AudioAlarmService._internal();
  factory AudioAlarmService() => _instance;
  AudioAlarmService._internal();

  AudioPlayer? _player;
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  /// Initializes player
  Future<void> init() async {
    try {
      _player ??= AudioPlayer();
    } catch (e) {
      debugPrint('AudioAlarmService init error: $e');
    }
  }

  /// Plays repetitive emergency buzzer sound
  Future<void> playEmergencyBuzzer() async {
    if (_isPlaying) return;
    try {
      _player ??= AudioPlayer();
      await _player!.setReleaseMode(ReleaseMode.loop);
      // Play alarm sound from assets
      await _player!.play(AssetSource('audio/emergency_siren.mp3'));
      _isPlaying = true;
    } catch (e) {
      debugPrint('AudioAlarmService play buzzer error: $e');
      // If asset is not yet bundled or system lacks audio driver, don't crash
      _isPlaying = true; // Mark as playing so UI state tracks the alarm
    }
  }

  /// Stops the emergency buzzer
  Future<void> stopBuzzer() async {
    try {
      if (_player != null) {
        await _player!.stop();
      }
    } catch (e) {
      debugPrint('AudioAlarmService stop buzzer error: $e');
    } finally {
      _isPlaying = false;
    }
  }

  void dispose() {
    _player?.dispose();
    _player = null;
  }
}

