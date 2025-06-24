import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pomodoro/provider/ad_manager.dart';
import 'package:pomodoro/provider/music_provider.dart';
import 'package:pomodoro/provider/pomodoro_provider.dart';
import 'package:pomodoro/screens/Home.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize(); 
  await Hive.initFlutter();
  await Hive.openBox('pomodoroBox');
  await Hive.openBox('coinsBox');
  await Hive.openBox('focusTimeBox');
  await Hive.openBox('sessionBox');
  
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => PomodoroProvider()),
      ChangeNotifierProvider(create: (_) => MusicPlayerProvider()),
      ChangeNotifierProvider(create: (_) => AdManager()),
    ],
    child: MyApp(),)
  );
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro Timer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.light,
      home: const HomePage(),
    );
  }
}