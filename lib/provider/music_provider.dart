import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:pomodoro/music_model.dart';

class MusicPlayerProvider with ChangeNotifier {
  AudioPlayer? _audioPlayer;
  Sound? _currentSound;
  bool _isPlaying = false;

  Sound? get currentSound => _currentSound;
  bool get isPlaying => _isPlaying;

  MusicPlayerProvider() {
    _audioPlayer = AudioPlayer();

    _audioPlayer?.onPlayerStateChanged.listen((PlayerState state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });
  }

  Future<void> playSound(Sound sound) async {

    if (_isPlaying) {
      await _audioPlayer?.stop();
    }

    _currentSound = sound;
    await _audioPlayer?.play(AssetSource(sound.assetPath.replaceAll('assets/', '')));

    _audioPlayer?.onPlayerComplete.listen((_) {
    playSound(sound);
    });
    notifyListeners();
  }

  Future<void> pauseSound() async {
    await _audioPlayer?.pause();
    notifyListeners();
  }

  Future<void> resumeSound() async {
    await _audioPlayer?.resume();
    notifyListeners();
  }

  Future<void> stopSound() async {
    await _audioPlayer?.stop();
    _currentSound = null;
    notifyListeners();
  }

  // Cleanup
  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }
}