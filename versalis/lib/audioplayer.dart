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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network('https://images.unsplash.com/photo-1494232410401-ad00d5433cfa?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2670&q=80',
                  width: double.infinity,
                  height: 350,
                  fit: BoxFit.cover,)
              ),
          const SizedBox(height: 32),
          const Text (
          'First Song',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
          ),
          const SizedBox(height: 4),
          const Text (
            'Unnamed artist',
            style: TextStyle( fontSize: 20),
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
                    String url = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3';
                    await audioPlayer.play(UrlSource(url));
                  }
                },
              ),
            ),
        ],
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
