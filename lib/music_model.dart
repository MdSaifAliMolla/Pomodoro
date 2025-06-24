class Sound {
  final String title;
  final String assetPath;

  Sound({
    required this.title,
    required this.assetPath,
  });
}

class Sounds{
  final List<Sound> _sounds = [
    Sound(
      title: 'Rainy day in Town',
      assetPath: 'assets/sound/rainy-day-in-town.mp3',
    ),
    Sound(
      title: 'Birds chirping in early spring',
      assetPath: 'assets/sound/birds-chirping-in-early-spring.mp3',
    ),
    Sound(
      title: 'Forest ambience at night',
      assetPath: 'assets/sound/forest-ambience-at-night.mp3',
    ),

  ];

  List<Sound> get sounds => _sounds;
}