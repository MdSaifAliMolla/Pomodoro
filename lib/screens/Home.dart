import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pomodoro/provider/ad_manager.dart';
import 'package:pomodoro/provider/pomodoro_provider.dart';
import 'package:pomodoro/screens/analytics_screen.dart';
import 'package:pomodoro/screens/music_screen.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          TimerScreen(),
          MusicScreen(),
          AnalyticsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.stopwatch),
            label: '',
            
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.music_note),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_bar_alt_fill),
            label: '',
          ),
        ],
      ),
    );
  }
}
//=============================================================================
class TimerScreen extends StatelessWidget {
  const TimerScreen({Key? key}) : super(key: key);
 
  @override
  Widget build(BuildContext context) {
    return Consumer2<PomodoroProvider,AdManager>(  
      builder: (context, provider,provider2, child) {
         //int randomNumber = Random().nextInt(5) + 1;
        return SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10,),
                Consumer<PomodoroProvider>(
                    builder: (context, provider, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Spacer(),
                          const Icon(Icons.diamond_rounded, size: 20, color: Color.fromARGB(135, 72, 73, 73)),
                          const SizedBox(width: 3),
                          Text('${provider.coins}', style: const TextStyle(
                            fontWeight: FontWeight.w500,fontSize: 13,color:Color.fromARGB(255, 128, 125, 125), )),

                          IconButton(
                            onPressed: () => _showAdDialog(context),
                            icon: const Icon(Icons.add,size: 20,),
                          ),
                          SizedBox(width: 20),
                        ],
                      );
                    },
                  ),
                // Status text
                const SizedBox(height: 40),
                Text(
                  provider.statusText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 20),
                _buildSessionDots(provider),
                //const SizedBox(height: 10),
                // Timer countdown
                Text(
                  provider.formattedTime,
                  style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.w200,
                  ),
                ),
                Image.asset(
                  provider.isBreak? 'assets/break/1.png':'assets/sess/2.png',
                  width: 200,
                  height: 200,
                  color: provider.isBreak? Colors.white: Colors.transparent,
                  colorBlendMode: BlendMode.color,
                ),  
                // Timer controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!provider.isRunning)
                      _buildCircleButton(
                        icon: CupertinoIcons.play,
                        onPressed: provider.coins > 0 || provider.currentSession > 0
                            ? provider.startTimer
                            : null,
                        primary: true,
                      )
                    else
                      _buildCircleButton(
                        icon: CupertinoIcons.stop,
                        onPressed: provider.pauseTimer,
                        primary: true,
                      ),
                    const SizedBox(width: 20),
                    _buildCircleButton(
                      icon: CupertinoIcons.refresh,
                      onPressed: provider.resetTimer,
                      primary: false,
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // Settings button
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: TextButton.icon(
                    onPressed: () => _showSettingsBottomSheet(context, provider),
                    icon: const Icon(CupertinoIcons.gear_big, size: 19),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool primary,
  }) {
    return Material(
      elevation: 0,
      shape: const CircleBorder(),
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 38,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
  
  Widget _buildSessionDots(PomodoroProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        provider.sessionCount,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black45, width: 1.5),
              color: index < provider.currentSession
                  ? Colors.black
                  : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
  
  void _showSettingsBottomSheet(BuildContext context, PomodoroProvider provider) {
    // Controllers for text inputs
    final sessionController = TextEditingController(
        text: (provider.sessionDuration ~/ 60).toString());
    final breakController = TextEditingController(
        text: (provider.breakDuration ~/ 60).toString());
        
    showModalBottomSheet(
      elevation: 0,
      backgroundColor: Colors.grey[100],
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        int sessioncount = provider.sessionCount;
      return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Sessions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Session count
            Row(
              children: [
                const Text('Sessions:'),
                const Spacer(),
                IconButton(
                  icon: const Icon(CupertinoIcons.minus),
                  onPressed: () {
                      if (sessioncount > 1) {
                        setState(() {
                          sessioncount--;
                        });
                        provider.decrementSessionCount();
                      }
                    },
                ),
                Text(
                  '$sessioncount',
                  style: const TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.add),
                  onPressed: () {
                      setState(() {
                        sessioncount++;
                      });
                      provider.incrementSessionCount();
                    },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Session duration with text input
            TextField(
              controller: sessionController,
              decoration: const InputDecoration(
                labelText: 'Session duration (minutes)',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  final minutes = int.tryParse(value);
                  if (minutes != null && minutes > 0 && minutes <= 60) {
                    provider.updateSessionDuration(minutes);
                  }
                }
              },
            ),
            
            const SizedBox(height: 16),
            
            // Break duration with text input
            TextField(
              controller: breakController,
              decoration: const InputDecoration(
                labelText: 'Break duration (minutes)',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  final minutes = int.tryParse(value);
                  if (minutes != null && minutes > 0 && minutes <= 30) {
                    provider.updateBreakDuration(minutes);
                  }
                }
              },
            ),
            
            const SizedBox(height: 24),
            
            // Apply button
            Row(
              children: [
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    // Parse and validate session duration
                    final sessionMinutes = int.tryParse(sessionController.text);
                    if (sessionMinutes != null && sessionMinutes > 0 && sessionMinutes <= 60) {
                      provider.updateSessionDuration(sessionMinutes);
                    }
                    
                    // Parse and validate break duration
                    final breakMinutes = int.tryParse(breakController.text);
                    if (breakMinutes != null && breakMinutes > 0 && breakMinutes <= 30) {
                      provider.updateBreakDuration(breakMinutes);
                    }
                    
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.white54,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      side: BorderSide(color: Colors.black26, width: 1.5),
                    ),
                    foregroundColor: Colors.black54,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      );
      });}
    );
  }
  
  void _showAdDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Watch an ad'),
        backgroundColor: Colors.white,
        content: Container(
          height: 150,
          child: Column(
            children: [
              const Text('Help this broke developer \n(┬┬﹏┬┬)'),
              Image.asset(
                'assets/dev/dev.jpg',
                width: 90,
                colorBlendMode: BlendMode.color,
                height:90,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',style: TextStyle(color: Colors.black54),),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black54,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.black26, width: 1.5),
              ),
            ),
            onPressed: () {
              Provider.of<AdManager>(context, listen: false).watchAd();
              Provider.of<PomodoroProvider>(context, listen: false).coins += 10;
              
              Navigator.pop(context);
            },
            child: const Text('get 60 gems!'),
          ),
        ],
      ),
    );
  }
}

