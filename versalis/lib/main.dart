import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:versalis/audioplayer.dart';
import 'package:versalis/song.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LogIn(),
    );
  }
}

class LogIn extends StatelessWidget {
  LogIn({Key? key}) : super(key: key);

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: MaterialButton(
          onPressed: () {
            _googleSignIn.signIn().then((value) {
              print('Succes!');
              String userName = value!.displayName!;
              String profilePicture = value.photoUrl!;
              print(userName);
              print(profilePicture);
              Navigator.push(context, MaterialPageRoute(builder: (context)=> SuccessScreen()));
            });
          },
          color: Colors.red,
          height: 50,
          minWidth: 100,
          child: const Text(
            'Google SignIn',
            style: TextStyle(
              color: Colors.white
            ),
          ),
        ),
      ),
    );
  }
}

class SuccessScreen extends StatefulWidget {
  SuccessScreen({Key? key}) : super(key: key);

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final Song song1 = Song('Song Name', 'Artist Name', 'https://images.unsplash.com/photo-1494232410401-ad00d5433cfa?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2670&q=80', 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3', [
    "Real friends, how many of us?",
    "How many of us, how many jealous? Real friends",
    "It's not many of us, we smile at each other",
    "But how many honest? Trust issues",
    "Switched up the number, I can't be bothered",
    "I cannot blame you for havin' an angle",
    "I ain't got no issues, I'm just doin' my thing",
    "Hope you're doin' your thing, too",
    "I'm a deadbeat cousin, I hate family reunions",
    "Fuck the church up by drinkin' at the communion",
    "Spillin' free wine, now my tux is ruined",
    "In town for a day, what the fuck we doin'?",
    "Who your real friends? We all came from the bottom",
    "I'm always blamin' you, but what's sad, you're not the problem",
    "Damn I forgot to call her, shit I thought it was Thursday",
    "Why you wait a week to call my phone in the first place?",
    "When was the last time I remembered a birthday?",
    "When was the last time I wasn't in a hurry?"
  ]);

  final Song song2 = Song('Wolves', 'Kanye West', 'https://samplesongs.netlify.app/album-arts/bad-liar.jpg', 'https://samplesongs.netlify.app/Bad%20Liar.mp3', [
    "Lost out, beat up",
    "Dancin', down there",
    "I found you, somewhere out",
    "'Round 'round there, right right there",
    "Lost and beat up",
    "Down there, dancin'",
    "I found you, somewhere out",
    "Right down there, right 'round there"
  ]);

  final Song song3 = Song('I Love Kanye', 'Kanye West', 'https://samplesongs.netlify.app/album-arts/faded.jpg', 'https://samplesongs.netlify.app/Faded.mp3', [
    "I miss the old Kanye, straight from the 'Go Kanye",
    "Chop up the soul Kanye, set on his goals Kanye",
    "I hate the new Kanye, the bad mood Kanye",
    "The always rude Kanye, spaz in the news Kanye",
    "I miss the sweet Kanye, chop up the beats Kanye",
    "I gotta say, at that time I'd like to meet Kanye",
    "See, I invented Kanye, it wasn't any Kanyes",
    "And now I look and look around and there's so many Kanyes",
    "I used to love Kanye, I used to love Kanye",
    "I even had the pink Polo, I thought I was Kanye",
    "What if Kanye made a song about Kanye?",
    "Called \"I Miss The Old Kanye\"?",
    "Man that'd be so Kanye",
    "That's all it was Kanye, we still love Kanye",
    "And I love you like Kanye loves Kanye"
  ]);

  List<Song> songList = [];

  @override
  void initState() {
    songList.add(song1);
    songList.add(song2);
    songList.add(song3);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              primary: false,
              itemCount: songList.length,
              itemBuilder: (context, index) {
                final item = songList[index];

                return ListTile(
                  title: Text('${item.title} by ${item.artist}'),
                  onTap:() {Navigator.push(context, MaterialPageRoute(builder: (context)=> Audioplayer(song: item,)));
                    },
                );
              },
            ),
            // MaterialButton(
            //   onPressed: () {
            //     Navigator.push(context, MaterialPageRoute(builder: (context)=> Audioplayer(song: song2,)));
            //   },
            //   color: Colors.green,
            //   height: 50,
            //   minWidth: 100,
            //   child: const Text(
            //     'Audio player',
            //     style: TextStyle(
            //         color: Colors.white
            //     ),
            //   ),
            // ),
            MaterialButton(
              onPressed: () {
                _googleSignIn.disconnect().then((value) => print("Logged out"));
                Navigator.push(context, MaterialPageRoute(builder: (context)=> LogIn()));
              },
              color: Colors.blue,
              child: const Text(
                'Log out',
                style: TextStyle(
                    color: Colors.white
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

