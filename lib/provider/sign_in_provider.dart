import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'user_model.dart';

class SignInProvider extends ChangeNotifier {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  String? _uid;
  String? get uid => _uid;

  String? _displayName;
  String? get displayName => _displayName;

  String? _email;
  String? get email => _email;

  SignInProvider() {
    checkSignInUser();
  }

  Future checkSignInUser() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool('signed_in') ?? false;
    if (_isSignedIn) {
      await getDataFromSharedPreferences();
    }
    notifyListeners();
  }

  Future setSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.setBool('signed_in', true);
    _isSignedIn = true;
    notifyListeners();
  }

  Future signInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      try {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final User userDetails = (await firebaseAuth.signInWithCredential(credential)).user!;
        _uid = userDetails.uid;
        _email = userDetails.email;
        _displayName = userDetails.displayName;

        // Check if the user exists in Firestore
        await checkUserExists();
        await setSignIn();
        notifyListeners();
      } on FirebaseAuthException catch (e) {
        _errorCode = e.message;
        _hasError = true;
        notifyListeners();
      }
    } else {
      _hasError = true;
      notifyListeners();
    }
  }

  Future signInWithAppleID() async {
    final appleIdCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oAuthProvider = OAuthProvider('apple.com').credential(idToken: appleIdCredential.identityToken);
    try {
      final User userDetails = (await firebaseAuth.signInWithCredential(oAuthProvider)).user!;
      _uid = userDetails.uid;
      _email = userDetails.email;
      _displayName = userDetails.displayName ?? '${appleIdCredential.givenName ?? "User"}';

      // Check if the user exists in Firestore
      await checkUserExists();
      await setSignIn();
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _errorCode = 'Error signing in with Apple: ${e.message}';
      _hasError = true;
      notifyListeners();
    }
  }

  Future<void> getUserDataFromFirestore(String uid) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (snapshot.exists) {
        UserModel userModel = UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
        _uid = userModel.uid;
        _email = userModel.email;
        _displayName = userModel.displayName;

        // Save data to SharedPreferences
        await saveDataToSharedPreferences();
        notifyListeners();
      } else {
        print('User does not exist in Firestore');
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> saveDataToFirestore() async {
    UserModel userModel = UserModel(
      uid: _uid,
      email: _email,
      displayName: _displayName,
    );

    await FirebaseFirestore.instance.collection('users').doc(_uid).set(userModel.toMap());
  }

  Future<void> saveDataToSharedPreferences() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    if (_uid != null) s.setString('uid', _uid!);
    if (_email != null) s.setString('email', _email!);
    if (_displayName != null) s.setString('displayName', _displayName!);
  }

  Future<void> getDataFromSharedPreferences() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _uid = s.getString('uid');
    _email = s.getString('email');
    _displayName = s.getString('displayName');
    notifyListeners();
  }

  Future<bool> checkUserExists() async {
    if (_uid == null) return false;

    DocumentSnapshot snap = await FirebaseFirestore.instance.collection('users').doc(_uid).get();
    if (snap.exists) {
      print('EXISTING USER');
      await getUserDataFromFirestore(_uid!); // Fetch user data if exists
      return true;
    } else {
      print('NEW USER');
      await saveDataToFirestore(); // Save new user data
      await saveDataToSharedPreferences();
      return false;
    }
  }

  Future<void> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      _uid = userCredential.user?.uid;
      _email = userCredential.user?.email;

      // Fetch user data from Firestore
      if (_uid != null) {
        await getUserDataFromFirestore(_uid!);
      }
      await setSignIn();
    } catch (e) {
      print("Error in email/password login: $e");
      _hasError = true;
    }
    notifyListeners();
  }

  Future<void> userSignOut() async {
    await firebaseAuth.signOut();
    await googleSignIn.signOut();

    _isSignedIn = false;
    clearStoredData();
    notifyListeners();
  }

  Future<void> clearStoredData() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    await s.clear();
  }
}
