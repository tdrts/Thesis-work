import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:versalis/Model/user.dart';
import 'package:versalis/audioplayer.dart';
import 'package:versalis/Model/song.dart';
import 'package:versalis/Service/blockchainController.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  BlockchainController.instance;
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
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
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
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green,
                Colors.teal,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Versalis',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Support Your Artist',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 200),
              MaterialButton(
                onPressed: () {
                  _googleSignIn.signIn().then((value) {
                  //             //addSongsToServer(); //to use only when adding new songs to the db
                  addUserToServer(email: value!.email!, name: value!.displayName!, photo: value.photoUrl!);
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> SuccessScreen(userEmail: value!.email!)));
                  });
                },
                child: Image.asset('assets/images/google.png', width: 400,),
              ),
            ],
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
  final docUser = FirebaseFirestore.instance.collection('songs').doc("song0");

  final Song song1 = Song(docUser.id,'Coffee for Your Head', 'Powfu', 'artwork": "https://samplesongs.netlify.app/album-arts/death-bed.jpg', 'https://samplesongs.netlify.app/Death%20Bed.mp3',
      ["Don't stay awake for too long, don't go to bed",
        "I'll make a cup of coffee for your head",
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
        child: SizedBox.expand(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green,
                  Colors.teal,
                ],
              ),
            ),
            child: Column(
              children: [
                const SafeArea(
                  top: true,
                  child: Text(
                    'Playlist',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      color: Colors.white,
                    ),
                  ),
                ),
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
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: MaterialButton(
                      onPressed: () {
                        _googleSignIn.disconnect().then((value) => print("Logged out"));
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> LogIn()));
                      },
                      child: Image.asset('assets/images/google_out.png', width: 400,),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSong(Song song) => ListTile(
    title: Text(song.title,
      style: const TextStyle(
        fontSize: 20,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
    subtitle: Text(song.artist,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.white,
      ),),
    onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context)=> Audioplayer(song: song,email: widget.userEmail,)));},
  );
  
}

Stream<List<Song>> readSongs() => FirebaseFirestore.instance.collection('songs')
    .snapshots()
    .map((snapshot) =>
    snapshot.docs.map((doc) => Song.fromJson(doc.data())).toList());
