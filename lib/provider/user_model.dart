class UserModel {
  String? uid;
  String? displayName;
  String? email;

  UserModel({
    this.uid,
    this.displayName,
    this.email,
  });

  // Receiving data from server
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      displayName: map['displayName'],
      email: map['email'],
    );
  }

  // Sending data to server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
    };
  }
}
