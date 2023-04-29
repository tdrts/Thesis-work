class User{
  //String id;
  String email;
  String displayName;
  String photoUrl;

  //User(this.id, this.email, this.displayName, this.photoUrl);
  User(this.email, this.displayName, this.photoUrl);

  @override
  String toString() {
    //return 'User{id: $id, email: $email, displayName: $displayName, photoUrl: $photoUrl}';
    return 'User{email: $email, displayName: $displayName, photoUrl: $photoUrl}';
  }

  Map<String, dynamic> toJson() => {
    //'id' : id,
    'email' : email,
    'displayName' : displayName,
    'photoUrl' : photoUrl,
  };
}