import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart' hide User;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockGoogleSignIn extends Mock implements GoogleSignIn {}

class _MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class _MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class _MockUserCredential extends Mock implements UserCredential {}

class _MockUser extends Mock implements User {}

class _TestFirebaseAuthException extends FirebaseAuthException {
  _TestFirebaseAuthException({required super.code, super.message});
}

void main() {
  setUpAll(() {
    registerFallbackValue(GoogleAuthProvider());
    registerFallbackValue(
      GoogleAuthProvider.credential(accessToken: 'fallback-access-token'),
    );
  });

  late _MockFirebaseAuth firebaseAuth;
  late _MockGoogleSignIn googleSignIn;

  GoogleSignInClient createClient({
    required bool isWeb,
    bool injectGoogleSignIn = true,
  }) {
    return GoogleSignInClient(
      firebaseAuth: firebaseAuth,
      googleSignIn: injectGoogleSignIn ? googleSignIn : null,
      isWeb: isWeb,
    );
  }

  setUp(() {
    firebaseAuth = _MockFirebaseAuth();
    googleSignIn = _MockGoogleSignIn();
  });

  group('web sign-in', () {
    test('uses Firebase popup and returns a refreshed Firebase ID token',
        () async {
      final credential = _MockUserCredential();
      final user = _MockUser();
      when(() => firebaseAuth.signInWithPopup(any()))
          .thenAnswer((_) async => credential);
      when(() => credential.user).thenReturn(user);
      when(() => user.getIdToken(true))
          .thenAnswer((_) async => 'firebase-id-token');

      final token = await createClient(
        isWeb: true,
        injectGoogleSignIn: false,
      ).signInAndGetFirebaseIdToken();

      expect(token, 'firebase-id-token');
      final provider = verify(
        () => firebaseAuth.signInWithPopup(captureAny()),
      ).captured.single as GoogleAuthProvider;
      expect(provider.providerId, 'google.com');
      expect(provider.parameters, {'prompt': 'select_account'});
      verifyNever(() => googleSignIn.signIn());
    });

    for (final code in ['popup-closed-by-user', 'cancelled-popup-request']) {
      test('maps $code to sign-in cancellation', () async {
        when(() => firebaseAuth.signInWithPopup(any())).thenThrow(
          _TestFirebaseAuthException(code: code),
        );

        await expectLater(
          createClient(isWeb: true).signInAndGetFirebaseIdToken(),
          throwsA(isA<SignInCancelledException>()),
        );
      });
    }

    test('maps Firebase network errors to NetworkException', () async {
      when(() => firebaseAuth.signInWithPopup(any())).thenThrow(
        _TestFirebaseAuthException(code: 'network-request-failed'),
      );

      await expectLater(
        createClient(isWeb: true).signInAndGetFirebaseIdToken(),
        throwsA(isA<NetworkException>()),
      );
    });

    test('maps other Firebase errors to AuthConfigurationException', () async {
      when(() => firebaseAuth.signInWithPopup(any())).thenThrow(
        _TestFirebaseAuthException(
          code: 'popup-blocked',
          message: 'Popup was blocked.',
        ),
      );

      await expectLater(
        createClient(isWeb: true).signInAndGetFirebaseIdToken(),
        throwsA(
          isA<AuthConfigurationException>().having(
            (error) => error.message,
            'message',
            'Popup was blocked.',
          ),
        ),
      );
    });

    test('rejects a popup result without a Firebase user', () async {
      final credential = _MockUserCredential();
      when(() => firebaseAuth.signInWithPopup(any()))
          .thenAnswer((_) async => credential);
      when(() => credential.user).thenReturn(null);

      await expectLater(
        createClient(isWeb: true).signInAndGetFirebaseIdToken(),
        throwsA(isA<AuthConfigurationException>()),
      );
    });

    for (final token in <String?>[null, '']) {
      test('rejects a ${token == null ? 'null' : 'empty'} Firebase ID token',
          () async {
        final credential = _MockUserCredential();
        final user = _MockUser();
        when(() => firebaseAuth.signInWithPopup(any()))
            .thenAnswer((_) async => credential);
        when(() => credential.user).thenReturn(user);
        when(() => user.getIdToken(true)).thenAnswer((_) async => token);

        await expectLater(
          createClient(isWeb: true).signInAndGetFirebaseIdToken(),
          throwsA(isA<AuthConfigurationException>()),
        );
      });
    }

    test('sign-out does not initialize or call GoogleSignIn', () async {
      when(() => firebaseAuth.signOut()).thenAnswer((_) async {});

      await createClient(isWeb: true, injectGoogleSignIn: false).signOut();

      verify(() => firebaseAuth.signOut()).called(1);
      verifyNever(() => googleSignIn.signOut());
    });
  });

  test('native sign-in keeps using GoogleSignIn credentials', () async {
    final account = _MockGoogleSignInAccount();
    final authentication = _MockGoogleSignInAuthentication();
    final credential = _MockUserCredential();
    final user = _MockUser();
    when(() => googleSignIn.signIn()).thenAnswer((_) async => account);
    when(() => account.authentication).thenAnswer((_) async => authentication);
    when(() => authentication.accessToken).thenReturn('google-access-token');
    when(() => authentication.idToken).thenReturn('google-id-token');
    when(() => firebaseAuth.signInWithCredential(any()))
        .thenAnswer((_) async => credential);
    when(() => credential.user).thenReturn(user);
    when(() => user.getIdToken(true))
        .thenAnswer((_) async => 'firebase-id-token');

    final token =
        await createClient(isWeb: false).signInAndGetFirebaseIdToken();

    expect(token, 'firebase-id-token');
    verify(() => googleSignIn.signIn()).called(1);
    verify(() => firebaseAuth.signInWithCredential(any())).called(1);
    verifyNever(() => firebaseAuth.signInWithPopup(any()));
  });
}
