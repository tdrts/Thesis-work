class User{
  String email;
  String displayName;
  String photoUrl;

  User(this.email, this.displayName, this.photoUrl);

  @override
  String toString() {
    return 'User{email: $email, displayName: $displayName, photoUrl: $photoUrl}';
  }

  Map<String, dynamic> toJson() => {
    'email' : email,
    'displayName' : displayName,
    'photoUrl' : photoUrl,
  };
}