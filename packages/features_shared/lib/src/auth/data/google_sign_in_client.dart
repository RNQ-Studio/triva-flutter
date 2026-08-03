import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInClient {
  GoogleSignInClient({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    bool? isWeb,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _injectedGoogleSignIn = googleSignIn,
        _isWeb = isWeb ?? kIsWeb;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn? _injectedGoogleSignIn;
  final bool _isWeb;
  late final GoogleSignIn _googleSignIn =
      _injectedGoogleSignIn ?? GoogleSignIn();

  Future<String> signInAndGetFirebaseIdToken() async {
    try {
      final result = _isWeb
          ? await _firebaseAuth.signInWithPopup(
              GoogleAuthProvider()
                ..setCustomParameters({'prompt': 'select_account'}),
            )
          : await _signInNatively();
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
      if (error.code == 'popup-closed-by-user' ||
          error.code == 'cancelled-popup-request') {
        throw const SignInCancelledException();
      }
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

  Future<UserCredential> _signInNatively() async {
    final account = await _googleSignIn.signIn();
    if (account == null) {
      throw const SignInCancelledException();
    }

    final authentication = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: authentication.accessToken,
      idToken: authentication.idToken,
    );
    return _firebaseAuth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    if (_isWeb) {
      await _firebaseAuth.signOut();
      return;
    }

    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}
