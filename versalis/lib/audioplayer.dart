import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Audioplayer extends StatefulWidget {
  const Audioplayer({Key? key}) : super(key: key);

  @override
  State<Audioplayer> createState() => _AudioplayerState();
}

class _AudioplayerState extends State<Audioplayer> {
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  String title = 'Song Name';
  String artist = 'Artist Name';
  String artwork = 'https://images.unsplash.com/photo-1494232410401-ad00d5433cfa?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2670&q=80';
  String url = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3';
  List<String> lyrics = [
    "The rings all ringed out",
    "Burn out, cave in",
    "Blackened to dark out",
    "I'm mixed now, fleshed out",
    "There's light with no heat",
    "We cooled out, it's cool out",
    "Life is precious",
    "We found out, we found out",
    "We found out",
    "The rings all ringed out",
    "Burn out, cave in",
    "Blackened to dark out",
    "I'm mixed now, fleshed out",
    "There's light with no heat",
    "We cooled out, it's cool out",
    "Life is precious",
    "We found out, we found out",
    "We found out",
    "The rings all ringed out",
    "Burn out, cave in",
    "Blackened to dark out",
    "I'm mixed now, fleshed out",
    "There's light with no heat",
    "We cooled out, it's cool out",
    "Life is precious",
    "We found out, we found out",
    "We found out",
    "The rings all ringed out",
    "Burn out, cave in",
    "Blackened to dark out",
    "I'm mixed now, fleshed out",
    "There's light with no heat",
    "We cooled out, it's cool out",
    "Life is precious",
    "We found out, we found out",
    "We found out",
  ];

  @override
  void initState() {
    super.initState();

    audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted){
        setState(() {
          isPlaying = state == PlayerState.playing;
        });
      }
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted){
        setState(() {
          duration = newDuration;
        });
      }
    });

    audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          position = newPosition;
        });
      }
    });
  }


  @override
  void dispose() {
    audioPlayer.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(artwork,
                    width: double.infinity,
                    height: 350,
                    fit: BoxFit.cover,)
                ),
            const SizedBox(height: 32),
              Text (
            title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
            ),
            const SizedBox(height: 4),
              Text (
              artist,
              style: const TextStyle(fontSize: 20),
            ),
              Slider(
                min: 0,
                max: duration.inSeconds.toDouble(),
                value: position.inSeconds.toDouble(),
                onChanged: (value) async {
                  final position = Duration(seconds: value.toInt());
                  await audioPlayer.seek(position);
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatTime(position)),
                    Text(formatTime(duration)),
                  ],
                )
              ),
              CircleAvatar(
                radius: 35,
                child: IconButton(
                  icon: Icon(
                    isPlaying? Icons.pause : Icons.play_arrow,
                  ),
                  iconSize: 50,
                  onPressed: () async {
                    if (isPlaying) {
                      await audioPlayer.pause();
                    } else {
                      await audioPlayer.play(UrlSource(url));
                    }
                  },
                ),
              ),
              const Padding(
                  padding: EdgeInsets.all(30),
                  child :
                      Text('Lyrics',
                        style: TextStyle(
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                      ),),
              ),
              ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: lyrics.length,
                itemBuilder: (context, index) {
                  final item = lyrics[index];

                  return ListTile(
                    title: Text(item),
                  );
                },
              ),
          ],
          ),
        ),
      ),
    );
  }


  String formatTime(Duration duration) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final hours = twoDigits (duration.inHours) ;
      final minutes = twoDigits(duration.inMinutes. remainder (60)) ;
      final seconds = twoDigits (duration.inSeconds. remainder (60));
      return [
        if (duration.inHours > 0) hours, minutes, seconds, ].join(':');
  }
}
