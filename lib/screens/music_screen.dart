import 'package:flutter/material.dart';
import 'package:pomodoro/music_model.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro/provider/music_provider.dart';

class MusicScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicPlayerProvider>(context);
    final sounds = Sounds().sounds;

    return Scaffold(
      appBar: AppBar(
        title: Text('White Noise', style: TextStyle(color: Colors.black, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: sounds.length,
        itemBuilder: (context, index) {
          final isCurrentSound =
          musicProvider.currentSound?.title == sounds[index].title;
      
          return Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 7),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Text(sounds[index].title), 
              tileColor: Colors.grey[50],
              trailing: IconButton(
                iconSize: 30,
                icon: Icon(
                  isCurrentSound && musicProvider.isPlaying
                      ? Icons.pause_circle_outline
                      : Icons.play_circle_outline,
                ),
                onPressed: () {
                  if (isCurrentSound && musicProvider.isPlaying) {
                    musicProvider.pauseSound();
                  } else {
                    musicProvider.playSound(sounds[index]);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
