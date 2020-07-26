import 'package:accountingapp/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  // create user obj based on Firebase
  User _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(uid: user.uid) : null;
  }

  // auth change user stream
  Stream<User> get user {
    return _auth.onAuthStateChanged
        .map(_userFromFirebaseUser);
  }

  // sign in anon
  Future signInAnon() async {
    try {
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print("failed: " + e.toString());
      return null;
    }
  }

  // sign in with email & password
  Future signInUsernamePassword(String username, String password) async {
    username += "@abc.com";
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: username, password: password);
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print("failed: " + e.toString());
      return null;
    }
  }

  // sign in with google
  Future googleSignIn() async {
    try {
      GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print("failed: " + e.toString());
      return null;
    }
  }

  // register with email & password
  Future registerWithEmailAndPassword(String username, String password,
      String fullname) async {
    username += "@abc.com";
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: username, password: password);
      FirebaseUser user = result.user;
      UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
      userUpdateInfo.displayName = fullname;
      await user.updateProfile(userUpdateInfo);
      await user.reload();
    return _userFromFirebaseUser(user);
    } catch (e) {
    print(e.toString());
    return null;
    }
  }

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}