import 'package:cloud_firestore/cloud_firestore.dart';

import '../Model/user.dart';

class UserService {

  //add a new user logged in
  Future<void> addUserToServer({required String email, required String name, required String photo, FirebaseFirestore? firebase}) async {
    final docUser = (firebase ?? FirebaseFirestore.instance).collection('users').doc(email);
    final user = User(email, name, photo);

    final json = user.toJson();
    await docUser.set(json);
  }
}