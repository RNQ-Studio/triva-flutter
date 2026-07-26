import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInClient {
  GoogleSignInClient({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  Future<String> signInAndGetFirebaseIdToken() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        throw const SignInCancelledException();
      }

      final authentication = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: authentication.accessToken,
        idToken: authentication.idToken,
      );
      final result = await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = result.user;
      if (firebaseUser == null) {
        throw const AuthConfigurationException(
          'Google account did not create a Firebase session.',
        );
      }

      final idToken = await firebaseUser.getIdToken(true);
      if (idToken == null || idToken.isEmpty) {
        throw const AuthConfigurationException(
          'Firebase did not return an identity token.',
        );
      }

      return idToken;
    } on SignInCancelledException {
      rethrow;
    } on FirebaseAuthException catch (error) {
      if (error.code == 'network-request-failed') {
        throw const NetworkException('Google sign-in network request failed.');
      }
      throw AuthConfigurationException(
        error.message ?? 'Firebase could not complete Google sign-in.',
      );
    } on PlatformException catch (error) {
      if (error.code == 'sign_in_canceled') {
        throw const SignInCancelledException();
      }
      if (error.code == 'network_error') {
        throw const NetworkException('Google sign-in network request failed.');
      }
      throw AuthConfigurationException(
        error.message ?? 'Google sign-in is not configured correctly.',
      );
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}
