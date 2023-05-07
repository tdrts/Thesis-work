import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:versalis/Model/user.dart';
import 'package:versalis/audioplayer.dart';
import 'package:versalis/Model/song.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Versalis',
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
              //addSongsToServer(); //to use only when adding new songs to the db
              addUserToServer(email: value!.email!, name: value!.displayName!, photo: value.photoUrl!);
              Navigator.push(context, MaterialPageRoute(builder: (context)=> SuccessScreen(userEmail: value!.email!)));
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

Future<void> addUserToServer({required String email, required String name, required String photo}) async {
  final docUser = FirebaseFirestore.instance.collection('users').doc(email);
  final user = User(email, name, photo);

  final json = user.toJson();
  await docUser.set(json);
  print('${user} logged in succesfully');
}

Future<void> addSongsToServer() async {
  final docUser = FirebaseFirestore.instance.collection('songs').doc();

  final Song song1 = Song(docUser.id,'I Love Kanye', 'Kanye West', 'https://samplesongs.netlify.app/album-arts/faded.jpg', 'https://samplesongs.netlify.app/Faded.mp3',
      ["I miss the old Kanye, straight from the 'Go Kanye",
        "That's all it was Kanye, we still love Kanye"
      ]
  );
  final json = song1.toJson();
  await docUser.set(json);
}

class SuccessScreen extends StatefulWidget {
  SuccessScreen({Key? key, required this.userEmail}) : super(key: key);

  final String userEmail;

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            StreamBuilder<List<Song>>(
                stream: readSongs(),
              builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print(snapshot.error);
                    return Text("Something went wrong ${snapshot.error}");
                  } else if (snapshot.hasData) {
                      final songs = snapshot.data!;

                      return ListView(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        primary: false,
                        children: songs.map(buildSong).toList(),
                      );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
              }
            ),
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

  Widget buildSong(Song song) => ListTile(
    title: Text('${song.title} by ${song.artist}'),
    onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context)=> Audioplayer(song: song,email: widget.userEmail,)));},
  );
  
}

Stream<List<Song>> readSongs() => FirebaseFirestore.instance.collection('songs')
    .snapshots()
    .map((snapshot) =>
    snapshot.docs.map((doc) => Song.fromJson(doc.data())).toList());
