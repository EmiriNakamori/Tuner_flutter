import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Tuner',
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  double _volume = 1.0;

  @override
  void initState() {
    super.initState();
    _loadPlayState();
  }

  void _loadPlayState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPlaying = prefs.getBool('isPlaying') ?? false;
    });
    if (_isPlaying) {
      await _audioPlayer.play(AssetSource('442.wav'));
    }
  }

  void _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.setVolume(_volume);
      await _audioPlayer.play(AssetSource('442.wav'));
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isPlaying', _isPlaying);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('442Hz', style: TextStyle(fontSize: 36)),
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            iconSize: 80,
            onPressed: _togglePlayPause,
          ),
          Slider(
            value: _volume,
            min: 0,
            max: 1,
            onChanged: (value) {
              setState(() {
                _volume = value;
                _audioPlayer.setVolume(_volume);
              });
            },
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  void _openURL(String url) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => _openURL(
                'https://doc-hosting.flycricket.io/tunera-privacy-policy/da58ad16-59bb-4be5-a3c3-82d46e3c1d84/privacy'),
            child: Text('Privacy Policy'),
          ),
          ElevatedButton(
            onPressed: () => _openURL(
                'https://doc-hosting.flycricket.io/tunera-terms-of-use/3262f52a-69b7-4ca0-ad29-be5abe7aa237/terms'),
            child: Text('Terms of Service'),
          ),
        ],
      ),
    );
  }
}
