import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:audioplayers/audioplayers.dart';

class PomodoroProvider extends ChangeNotifier {
  int _sessionDuration = 25 * 60; 
  int _breakDuration = 5 * 60; 
  int _sessionCount = 2;
  int _currentSession = 0;
  int _remainingTime = 25 * 60;
  bool _isRunning = false;
  bool _isBreak = false;
  Timer? _timer;
  int _coins = 0;
  
  PomodoroProvider() {
    _loadData();
  }
  
  int get sessionDuration => _sessionDuration;
  int get breakDuration => _breakDuration;
  int get sessionCount => _sessionCount;
  int get currentSession => _currentSession;
  int get remainingTime => _remainingTime;
  bool get isRunning => _isRunning;
  bool get isBreak => _isBreak;
  int get coins => _coins;
  set coins(int value) {
    _coins = value;
    notifyListeners();
  }
  
  String get formattedTime {
    final minutes = (_remainingTime ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingTime % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
  
  String get statusText {
    if (_isBreak) {
      return 'Break Time';
    } else if (_currentSession < _sessionCount) {
      return 'Session ${_currentSession + 1} / $_sessionCount';
    } else {
      return 'Complete!';
    }
  }
  
  void _loadData() {
    final pomodoroBox = Hive.box('pomodoroBox');
    final coinsBox = Hive.box('coinsBox');
    final focusTimeBox = Hive.box('focusTimeBox');
    final sessionBox = Hive.box('sessionBox');
    
    _sessionDuration = pomodoroBox.get('sessionDuration', defaultValue: 25 * 60);
    _breakDuration = pomodoroBox.get('breakDuration', defaultValue: 5 * 60);
    _sessionCount = pomodoroBox.get('sessionCount', defaultValue: 2);
    _coins = coinsBox.get('coins', defaultValue: 10);
    
    // Load incomplete session if exists
    final Map<dynamic, dynamic>? incompleteSession = sessionBox.get('incompleteSession');
    if (incompleteSession != null) {
      _currentSession = incompleteSession['currentSession'] ?? 0;
      _remainingTime = incompleteSession['remainingTime'] ?? _sessionDuration;
      _isBreak = incompleteSession['isBreak'] ?? false;
    } else {
      _remainingTime = _sessionDuration;
    }
  }
  
  void _saveData() {
    final pomodoroBox = Hive.box('pomodoroBox');
    final coinsBox = Hive.box('coinsBox');
    final focusTimeBox = Hive.box('focusTimeBox');
    final sessionBox = Hive.box('sessionBox');
    
    pomodoroBox.put('sessionDuration', _sessionDuration);
    pomodoroBox.put('breakDuration', _breakDuration);
    pomodoroBox.put('sessionCount', _sessionCount);
    coinsBox.put('coins', _coins);
    
    // Save incomplete session
    if (_isRunning || (_currentSession > 0 && _currentSession < _sessionCount)) {
      sessionBox.put('incompleteSession', {
        'currentSession': _currentSession,
        'remainingTime': _remainingTime,
        'isBreak': _isBreak
      });
    } else {
      sessionBox.delete('incompleteSession');
    }
    notifyListeners();
  }
 
  void startTimer() {
    if (_coins < 0 && _currentSession == 0) {
      return; 
    }
    
    if (_currentSession == 0) {
      _saveData();
    }
    
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        _remainingTime--;
      
        if (!_isBreak) {
          _logFocusTime(1); 
        }
      } else {
        timer.cancel();
        

        if (_isBreak) {
          // Break finished, move to next session
          _playAlert();
          _isBreak = false;
          _currentSession++;
          
          if (_currentSession < _sessionCount) {
            _remainingTime = _sessionDuration;
          } else {
            // All sessions completed
            _playAlert();
            _isRunning = false;
            _currentSession = 0;
            _remainingTime = _sessionDuration;
            _coins-=10;
          }
        } else {
          // Session finished, start break
          _playAlert(); 
          _isBreak = true;
          _remainingTime = _breakDuration;
        }
      }
      
      _saveData();
      notifyListeners();
    });
    
    notifyListeners();
  }
  void _playAlert() {
  final audioPlayer = AudioPlayer();
  audioPlayer.play(AssetSource('sound/alert.mp3'));
}
  
  void pauseTimer() {
    _timer?.cancel();
    _isRunning = false;
    _saveData();
    notifyListeners();
  }
  
  void resetTimer() {
    _timer?.cancel();
    _isRunning = false;
    _isBreak = false;
    _currentSession = 0;
    _remainingTime = _sessionDuration;
    _saveData();
    notifyListeners();
  }
  
  void incrementSessionCount() {
    if(_coins >= 10){_sessionCount++;
    _coins-=10;
    _saveData();
    notifyListeners();}
  }
  
  void decrementSessionCount() {
    if (_sessionCount > 1) {
      _sessionCount--;
      _coins+=10;
      _saveData();
      notifyListeners();
    }
  }
  
  void updateSessionDuration(int minutes) {
    _sessionDuration = minutes * 60;
    if (!_isRunning && !_isBreak) {
      _remainingTime = _sessionDuration;
    }
    _saveData();
    notifyListeners();
  }
  
  void updateBreakDuration(int minutes) {
    _breakDuration = minutes * 60;
    if (!_isRunning && _isBreak) {
      _remainingTime = _breakDuration;
    }
    _saveData();
    notifyListeners();
  }
  
//=========================================================================

void _logFocusTime(int seconds) {
  final focusTimeBox = Hive.box('focusTimeBox');
  
  // Get today's date in ISO format (YYYY-MM-DD)
  final today = DateTime.now();
  final todayKey = today.toIso8601String().split('T')[0]; // Proper ISO date format
  
  // Load or initialize the focus time log
  Map<String, int> focusTimeLog = Map<String, int>.from(
    focusTimeBox.get('focusTimeLog', defaultValue: {})
  );
  
  // Update today's focus time
  focusTimeLog[todayKey] = (focusTimeLog[todayKey] ?? 0) + seconds;
  
  // Save updated data
  focusTimeBox.put('focusTimeLog', focusTimeLog);
  
}

// Fixed function to get focus time for a specific day
int getTotalFocusTimeForDay(DateTime day) {
  final focusTimeBox = Hive.box('focusTimeBox');
  final focusTimeLog = Map<String, int>.from(
    focusTimeBox.get('focusTimeLog', defaultValue: {})
  );
  
  // Format the date consistently 
  final dayKey = day.toIso8601String().split('T')[0];
  
  return focusTimeLog[dayKey] ?? 0;
}

// Fixed function to get weekly focus time
Map<DateTime, int> getWeeklyFocusTime() {
  final focusTimeBox = Hive.box('focusTimeBox');
  final focusTimeLog = Map<String, int>.from(
    focusTimeBox.get('focusTimeLog', defaultValue: {})
  );
  
  final today = DateTime.now();
  final startOfWeek = today.subtract(Duration(days: today.weekday - 1)); // Monday
  final Map<DateTime, int> weeklyData = {};
  
  for (int i = 0; i < 7; i++) {
    final day = startOfWeek.add(Duration(days: i));
    final dayKey = day.toIso8601String().split('T')[0];
    weeklyData[day] = focusTimeLog[dayKey] ?? 0;
  }
  
  return weeklyData;
}

// Fixed function to get monthly focus time
int getTotalFocusTimeForMonth(int year, int month) {
  final focusTimeBox = Hive.box('focusTimeBox');
  final focusTimeLog = Map<String, int>.from(
    focusTimeBox.get('focusTimeLog', defaultValue: {})
  );
  
  int totalFocus = 0;
  
  // Get the last day of the month correctly
  final lastDay = DateTime(year, month + 1, 0).day;
  
  for (int i = 1; i <= lastDay; i++) {
    // Create a DateTime for this day and convert to ISO format key
    final day = DateTime(year, month, i);
    final dayKey = day.toIso8601String().split('T')[0];
    
    totalFocus += focusTimeLog[dayKey] ?? 0;
  }  
  return totalFocus;
}

Map<DateTime, int> getMonthlyFocusTime() {
  final Map<DateTime, int> monthlyData = {};
  final today = DateTime.now();
  
  for (int i = 0; i < 12; i++) {
    final month = i + 1;
    final monthDate = DateTime(today.year, month, 1);
    final totalFocus = getTotalFocusTimeForMonth(today.year, month);
    monthlyData[monthDate] = totalFocus;
    
  }
  
  return monthlyData;
}

// Improved function to clean up old data
void _cleanupOldData() {
  final focusTimeBox = Hive.box('focusTimeBox');
  Map<String, int> focusTimeLog = Map<String, int>.from(
    focusTimeBox.get('focusTimeLog', defaultValue: {})
  );
  
  final oneYearAgo = DateTime.now().subtract(Duration(days: 365));
  final oneYearAgoKey = oneYearAgo.toIso8601String().split('T')[0];
  
  // Use properly formatted keys for comparison
  focusTimeLog.removeWhere((key, value) {
    try {
      return key.compareTo(oneYearAgoKey) < 0;
    } catch (e) {
      print('Error processing date key: $key - $e');
      return false; // Keep entries that can't be parsed
    }
  });
  
  focusTimeBox.put('focusTimeLog', focusTimeLog);
}
  
    
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}