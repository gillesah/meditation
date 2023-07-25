import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:async'; // Importer le package pour utiliser Timer
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Importer le package intl pour manipuler les dates



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  //const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String selectedMusic = '';
  Duration meditationDuration = Duration(minutes: 5);
  AudioPlayer? _player;
  Timer? _timer; // Variable pour le minuteur
  bool _isPlaying = false; // Booléen pour vérifier si la musique est en cours de lecture
  int consecutiveDays = 0;
  DateTime? lastMeditationDate; // Variable pour stocker la date de la dernière méditation réussie

  @override
  void initState() {
    super.initState();
    _loadConsecutiveDays(); // Charger les valeurs du nombre de jours consécutifs et de la date de la dernière méditation
  }

  void _loadConsecutiveDays() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      consecutiveDays = prefs.getInt('consecutiveDays') ?? 0;
      String? lastMeditationDateString = prefs.getString('lastMeditationDate');
      lastMeditationDate = lastMeditationDateString != null ? DateTime.parse(lastMeditationDateString) : null;
    });
  }

  void _saveConsecutiveDays() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('consecutiveDays', consecutiveDays);
    if (lastMeditationDate != null) {
      await prefs.setString('lastMeditationDate', DateFormat('yyyy-MM-dd').format(lastMeditationDate!));
    }
  }

  void _resetConsecutiveDays() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('consecutiveDays');
    await prefs.remove('lastMeditationDate');
    setState(() {
      consecutiveDays = 0;
      lastMeditationDate = null;
    });
  }
  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  ElevatedButton durationButton(Duration duration) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          meditationDuration = duration;
        });
      },
      style: ElevatedButton.styleFrom(

        primary: Colors.transparent,
        minimumSize: Size(80, 60),
        maximumSize: Size(80, 60),
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: meditationDuration == duration ? Colors.white70 : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Stack(
        children: [
          Card(
            elevation: 15,
            margin: const EdgeInsets.all(0),
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(67, 100, 247, 1),
                    Color.fromRGBO(0, 82, 212, 1),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: FractionallySizedBox(
              widthFactor: 1.6, // Ajuster la largeur du dégradé et du texte ici
              heightFactor: 1, // Ajuster la hauteur du dégradé et du texte ici
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(67, 100, 247, 1),
                      Color.fromRGBO(0, 82, 212, 1),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    '${duration.inMinutes} min',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: meditationDuration == duration ? Colors.white : Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ElevatedButton musicButton(String displayText, String musicAsset) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.transparent,
        minimumSize: Size(200, 150),
        maximumSize: Size(200, 150),
        padding: null,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(
            color: selectedMusic == musicAsset
                ? Colors.white70
                : Colors.transparent,
            width: 4,
          ),
        ),

      ),


      child: Stack(
        children: [
          Card(
            color: Colors.transparent,
            elevation: 15,
            margin: const EdgeInsets.all(0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,

              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),

                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(74, 0, 224, 1),
                      Color.fromRGBO(142, 45, 226, 1),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              displayText,
              style: TextStyle(
                color:
                    selectedMusic == musicAsset ? Colors.white : Colors.white70,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      onPressed: () {
        setState(() {
          selectedMusic = musicAsset;
        });
      },
    );
  }

  void _play(Duration duration, String musicAsset) {
    _player?.dispose();
    final player = _player = AudioPlayer();
    //Duration meditationDuration = Duration(minutes: 1); // Durée de méditation par défaut
    //meditationDuration = Duration(minutes: 1);
    // duration = Duration(minutes: 1);
    Duration duration = meditationDuration;
    player.play(AssetSource(musicAsset));
       //print(_play(duration, musicAsset));
    // Démarrer le minuteur pour arrêter la musique après la durée de méditation spécifiée
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(meditationDuration, () {
      player.stop();
      _timer = null;
      _incrementConsecutiveDays(); // Incrémenter le nombre de jours consécutifs à la fin de la méditation réussie
    });
  }

  void _incrementConsecutiveDays() {
    setState(() {
      if (lastMeditationDate == null || !_isSameDay(lastMeditationDate!, DateTime.now())) {
        // Si c'est un nouveau jour, réinitialiser le nombre de jours consécutifs
        consecutiveDays = 1;
      } else {
        consecutiveDays++;
      }
      lastMeditationDate = DateTime.now();
      _saveConsecutiveDays(); // Sauvegarder la nouvelle valeur du nombre de jours consécutifs et la date de la dernière méditation
    });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  void _pause() {
    _player?.pause();
    if (_timer != null) {
      _timer!.cancel();
      _timer =
          null; // Remettre le minuteur à null pour indiquer qu'il n'est plus actif
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color.fromRGBO(15, 25, 63, 1),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    title('Choisir le son'),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          musicButton('La mer', 'mer.mp3'),
                          musicButton('Aum', 'aum.mp3'),
                          musicButton('Son Blanc', 'blanc.mp3'),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
              Divider(),
              title('Choisir la durée'),

              SingleChildScrollView(
        scrollDirection: Axis.horizontal,
             child: Row(
                  children: [
                    durationButton(Duration(minutes: 1)),
                    durationButton(Duration(minutes: 5)),
                    durationButton(Duration(minutes: 10)),
                    durationButton(Duration(minutes: 15)),
                    durationButton(Duration(minutes: 25)),
                    durationButton(Duration(minutes: 30)),
                    durationButton(Duration(minutes: 35)),
                    durationButton(Duration(minutes: 40)),
                    durationButton(Duration(minutes: 45)),
                    durationButton(Duration(minutes: 50)),
                    durationButton(Duration(minutes: 55)),
                    durationButton(Duration(minutes: 60)),
                  ],
                ),
      ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [playButton(), pauseButton()],
              ),
              Text('Nombre de jours consécutifs : $consecutiveDays'),
              ElevatedButton(
                onPressed: _resetConsecutiveDays,
                child: Text('Réinitialiser'),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget playButton() {
    return IconButton(
      onPressed: () => _play(meditationDuration, selectedMusic),
      tooltip: 'Play',
      icon: const Icon(Icons.play_arrow),
      color: Color.fromRGBO(142, 45, 226, 1),
      iconSize: 80,

    );
  }

  Widget pauseButton() {
    return IconButton(
      onPressed: _pause,
      tooltip: 'Pause',
      icon: const Icon(Icons.pause),
      color: Color.fromRGBO(142, 45, 226, 1),
      iconSize: 80,

    );
  }

  Widget title(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 15, bottom: 40, right: 20, top: 20),
      child: Text(text,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 40,
            color: Colors.white,
          )),
    );
  }
}
