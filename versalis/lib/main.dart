import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:versalis/audioplayer.dart';
import 'package:versalis/Model/song.dart';
import 'package:versalis/Service/blockchainController.dart';
import 'package:versalis/statisticsScreen.dart';

import 'Service/utils.dart';

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
                'Support Your Artists',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 200),
              logInGoogleButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget logInGoogleButton(context) => MaterialButton(
        onPressed: () {
          _googleSignIn.signIn().then((value) {
            addUserToServer(email: value!.email!, name: value!.displayName!, photo: value.photoUrl!);
            Navigator.push(context, MaterialPageRoute(builder: (context) => SuccessScreen(userEmail: value!.email!)));
          });
        },
        child: Image.asset(
          'assets/images/google.png',
          width: 400,
        ),
  );
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
                listOfSongsWidget(context),
                statisticsButton(),
                logOutGoogleButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget listOfSongsWidget(context) => FutureBuilder<List<Song>>(
      future: sortSongsByRatioBetweenListensAndLyricsBought(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong ${snapshot.error}");
        } else if (snapshot.hasData) {
          final songs = snapshot.data!;
          return ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            primary: false,
            children: songs.map(songTile).toList(),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      }
  );

  Widget logOutGoogleButton(context) => Expanded(
    child: Align(
      alignment: Alignment.bottomCenter,
      child: MaterialButton(
        onPressed: () {
          _googleSignIn.disconnect().then((value) => {});
          Navigator.push(context, MaterialPageRoute(builder: (context)=> LogIn()));
        },
        child: Image.asset('assets/images/google_out.png', width: 200,),
      ),
    ),
  );

  Widget statisticsButton() => MaterialButton(
    onPressed: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const StatisticsScreen()));
    },
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5.0),
    ),
    color: Colors.white,
    child: const Text("See statistics",
      style: TextStyle(
        fontSize: 16,
        color: Color.fromRGBO(0, 0, 0, 0.54),
      ),
    ),
  );

  Widget songTile(Song song) => FutureBuilder<int>(
    future: findIfAuctionInProgress(song.id),
    builder: (context, snapshot) {
      if (!snapshot.hasData){
        return const CircularProgressIndicator();
      }
      return ListTile(
        title: Text(song.title,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: snapshot.data! == 0 ? const Icon(Icons.music_note) : const Icon(Icons.timer_sharp),
        subtitle: Text(song.artist,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),),
        onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context)=> Audioplayer(song: song,email: widget.userEmail,)));},
      );
    }
  );
}


