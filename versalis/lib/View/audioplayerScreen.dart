import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:versalis/Extensions/durationExt.dart';
import 'package:versalis/Model/song.dart';
import 'package:versalis/Controller/auctionService.dart';

import '../View/lyricScreen.dart';
import '../Controller/serviceLocator.dart';
import 'homeScreen.dart';

class Audioplayer extends StatefulWidget {
  const Audioplayer({
    Key? key,
    required this.song,
    required this.email,
  }) : super(key: key);

  final Song song;
  final String email;

  @override
  State<Audioplayer> createState() => _AudioplayerState();
}

class _AudioplayerState extends State<Audioplayer> {
  final auctionService = getIt<AuctionService>();
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    playerStateChanged();
    durationStateChanged();
    positionChanged();
  }

  void playerStateChanged() {
    audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  void durationStateChanged() {
    audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          duration = newDuration;
        });
      }
    });
  }

  void positionChanged() {
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
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green,
                Colors.teal,
              ],
            ),
          ),
        ),
        leading: BackButton(
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeScreen(userEmail: widget.email)));
          },
        ),
        title: Text(
          widget.song.title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              songImage(),
              const SizedBox(height: 32),
              Text(
                widget.song.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.song.artist,
                style: const TextStyle(fontSize: 20),
              ),
              sliderWidget(),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(position.formatTime()),
                      Text(duration.formatTime()),
                    ],
                  )),
              playPauseButton(),
              const Padding(
                padding: EdgeInsets.all(30),
                child: Text(
                  'Lyrics',
                  style: TextStyle(
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              listOfLyrics(),
            ],
          ),
        ),
      ),
    );
  }

  Widget songImage() => ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.network(
        widget.song.artwork,
        width: double.infinity,
        height: 350,
        fit: BoxFit.cover,
      ));

  Widget playPauseButton() => CircleAvatar(
        radius: 35,
        child: IconButton(
          icon: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
          ),
          iconSize: 50,
          onPressed: () async {
            if (isPlaying) {
              await audioPlayer.pause();
            } else {
              await audioPlayer.play(UrlSource(widget.song.url));
            }
          },
        ),
      );

  Widget lyricTile(item, index) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<int>(
            future: auctionService.findIfLyricInProgress(widget.song.id, index, null),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              return ListTile(
                title: Text(item),
                leading: snapshot.data! == 0
                    ? const Icon(null)
                    : const Icon(Icons.timer_sharp),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LyricScreen(
                                lyric: item,
                                email: widget.email,
                                song: widget.song,
                                lyricIndex: index,
                              )));
                },
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.green, width: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }),
      );

  Widget listOfLyrics() => ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        primary: false,
        itemCount: widget.song.lyrics.length,
        itemBuilder: (context, index) {
          final item = widget.song.lyrics[index];

          return lyricTile(item, index);
        },
      );

  Widget sliderWidget() => Slider(
        min: 0,
        max: duration.inSeconds.toDouble(),
        value: position.inSeconds.toDouble(),
        onChanged: (value) async {
          final position = Duration(seconds: value.toInt());
          await audioPlayer.seek(position);
        },
      );
}
