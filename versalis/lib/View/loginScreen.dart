
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:versalis/Service/userService.dart';

import '../Service/serviceLocator.dart';
import 'homeScreen.dart';

class LogIn extends StatelessWidget {
  LogIn({Key? key}) : super(key: key);

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final userService = getIt<UserService>();

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
        userService.addUserToServer(email: value!.email!, name: value!.displayName!, photo: value.photoUrl!);
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(userEmail: value!.email!)));
      });
    },
    child: Image.asset(
      'assets/images/google.png',
      width: 400,
    ),
  );
}