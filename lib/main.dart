//import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async'; // Importer le package pour utiliser Timer
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Importer le package intl pour manipuler les dates
//import 'package:perfect_volume_control/perfect_volume_control.dart';
import 'package:ZenFlow/duration_picker.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'package:just_audio/just_audio.dart';
import 'info.dart'; // Make sure to import the correct path
import 'package:wakelock/wakelock.dart';
import 'consecutivedays.dart';
import 'package:flutter/widgets.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter services are initialized
  final consecutiveDaysManager = ConsecutiveDaysManager();
  await consecutiveDaysManager.loadConsecutiveDays();

  runApp(MyApp(consecutiveDaysManager: consecutiveDaysManager));
}

class MyApp extends StatelessWidget {
  final ConsecutiveDaysManager consecutiveDaysManager;

  MyApp({required this.consecutiveDaysManager, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
          consecutiveDaysManager: consecutiveDaysManager), // Remove 'const'
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  final ConsecutiveDaysManager consecutiveDaysManager;

  MyHomePage({required this.consecutiveDaysManager, Key? key})
      : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String selectedMusic = '';
  Duration meditationDuration = Duration(minutes: 15);
  late AudioPlayer _player;
  Timer? _timer; // Variable pour le minuteur
  //bool _isPlaying = false; // Booléen pour vérifier si la musique est en cours de lecture
  int consecutiveDays = 0;
  DateTime?
      lastMeditationDate; // Variable pour stocker la date de la dernière méditation réussie
  final gongPlayer = AudioPlayer();
  bool showDurationPicker = false;

  void _toggleDurationPicker() {
    setState(() {
      showDurationPicker = !showDurationPicker;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadConsecutiveDays(); // Charger les valeurs du nombre de jours consécutifs et de la date de la dernière méditation
  }

  void _loadConsecutiveDays() async {
    await widget.consecutiveDaysManager
        .loadConsecutiveDays(); // Use widget to access the manager
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _showPopupDialog() {
    _play(meditationDuration, selectedMusic);
    showDialog(
      context: context,
      barrierColor: Colors.black45,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                const Color.fromARGB(255, 255, 36, 226).withOpacity(1),
                const Color.fromARGB(255, 39, 205, 255).withOpacity(1)
              ])),
          child: AlertDialog(
            backgroundColor: Colors.blue,
            elevation: 7,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            content: Container(
              color: Colors.blue,
              height: 440,
              width: 850,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        tooltip: 'Fermer',
                        icon: const Icon(Icons.close),
                        color: Color.fromRGBO(142, 45, 226, 1),
                        iconSize: 70),
                  ),
                  WaveWidget(
                    config: CustomConfig(
                      gradients: [
                        [Colors.blue.shade200, Colors.pinkAccent],
                        [Colors.blue.shade200, Colors.pink],
                        [Colors.blue, Colors.blue.shade200],
                        [Colors.blue.shade200, Colors.blue.shade400],
                        [Colors.blue.shade400, Colors.blue.shade200],
                        [Colors.blue.shade200, Colors.blue],
                      ],
                      durations: [65000, 45000, 29440, 22800, 20000, 32000],
                      heightPercentages: [0.1, 0.15, 0.23, 0.25, 0.30, 0.65],
                      blur: const MaskFilter.blur(BlurStyle.solid, 1),
                      gradientBegin: Alignment.bottomLeft,
                      gradientEnd: Alignment.topRight,
                      // ... Your wave animation configuration ...
                    ),
                    waveAmplitude: 54,
                    backgroundColor: Colors.transparent,
                    size: Size(double.infinity, 300),
                  ),
                  SizedBox(height: 400),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.play_arrow),
                        onPressed: () {
                          // Start the music here
                          _play(meditationDuration, selectedMusic);
                        },
                        iconSize: 80,
                      ),
                      IconButton(
                        icon: Icon(Icons.pause),
                        onPressed: () {
                          // Pause the music here
                          _pause();
                        },
                        iconSize: 80,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _player.dispose();
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
            color: meditationDuration == duration
                ? Colors.white70
                : Colors.transparent,
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
                      color: meditationDuration == duration
                          ? Colors.white
                          : Colors.white70,
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
        minimumSize: Size(250, 150),
        maximumSize: Size(250, 150),
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

  void _play(Duration duration, String musicAsset) async {
    Wakelock.enable();
    _player = AudioPlayer();
    await _player.setAudioSource(AudioSource.uri(
        Uri.parse("https://gilleshelleu.com/zenflow/$musicAsset")));

    _player.positionStream.listen((position) {
      if (position >= duration - Duration(seconds: 20)) {
        final remainingTime = duration - position;
        final volumeMultiplier = remainingTime.inSeconds / 20.0;
        _player.setVolume(volumeMultiplier);
      }
    });

    if (_timer != null) {
      _timer!.cancel();
    }

    _timer = Timer(duration, () async {
      await gongPlayer
          .setAsset('https://gilleshelleu.com/zenflow/assets/gong2.mp3');
      await gongPlayer.play();

      await Future.delayed(Duration(seconds: 3));

      await _player.stop();
      Wakelock.disable();

      Navigator.of(context, rootNavigator: true).pop(_showPopupDialog);
      widget.consecutiveDaysManager.incrementConsecutiveDays();
    });

    await _player.play();
  }

  void _pause() {
    _player.pause();
    if (_timer != null) {
      _timer!.cancel();
      _timer =
          null; // Remettre le minuteur à null pour indiquer qu'il n'est plus actif
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ZenFlow"),
        backgroundColor: Color.fromRGBO(15, 25, 63, 1),
        titleTextStyle: TextStyle(
            color: Colors.white, fontSize: 25, fontWeight: FontWeight.w600),
        actions: [
          IconButton(
              onPressed: () => dialogBuilder(context,
                  consecutiveDays), // Show the popup when the play button is pressed
              tooltip: 'Informations',
              icon: const Icon(
                Icons.info_outline,
                size: 30,
              ),
              color: Color.fromRGBO(142, 45, 226, 1),
              iconSize: 100),
        ],
        centerTitle: true,
      ),
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
                          musicButton('OM 417Hz', 'om417.mp3'),
                          musicButton('Son du Bol', 'bol.mp3'),
                          musicButton('Son Blanc', 'blanc.mp3'),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
              Divider(),
              title('Choisir la durée'),
// Button to toggle the duration picker
              DurationPicker(
                duration: meditationDuration,
                onChange: (val) {
                  setState(() {
                    meditationDuration = val; // Update the meditation duration
                  });
                },
              ),
              playButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget playButton() {
    return IconButton(
        onPressed:
            _showPopupDialog, // Show the popup when the play button is pressed
        tooltip: 'Play',
        icon: const Icon(Icons.play_arrow),
        color: Color.fromRGBO(142, 45, 226, 1),
        iconSize: 90);
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
      padding: EdgeInsets.only(left: 15, bottom: 20, right: 20, top: 20),
      child: Text(text,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 30,
            color: Colors.white,
          )),
    );
  }
}

class TickerProviderImpl extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}
