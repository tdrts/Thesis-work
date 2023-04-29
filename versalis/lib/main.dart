import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

class SuccessScreen extends StatelessWidget {
  SuccessScreen({Key? key}) : super(key: key);

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: [
                ListTile(title: Text('Piesa 1')),
                ListTile(title: Text('Piesa 2')),
                ListTile(title: Text('Piesa 3')),
              ],
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
}

