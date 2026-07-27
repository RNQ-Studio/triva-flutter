import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triva_app/features/profile/presentation/profile_route.dart';

class _ProfileAuthNotifier extends AuthNotifier {
  _ProfileAuthNotifier(this.user);

  final User user;

  @override
  AuthState build() => AuthAuthenticated(user);
}

class _ProfileRepository implements ProfileRepository {
  const _ProfileRepository();

  @override
  Future<Profile?> getProfile() async => const Profile(
        id: 'user-1',
        name: 'Admin TRIVA',
        email: 'admin@example.com',
      );

  @override
  Future<void> updateProfile(Profile profile) async {}
}

void main() {
  Future<void> pumpProfile(
    WidgetTester tester, {
    required User user,
    ThemeData? theme,
  }) async {
    tester.view
      ..physicalSize = const Size(360, 690)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        key: ValueKey(user.id),
        overrides: [
          authProvider.overrideWith(() => _ProfileAuthNotifier(user)),
          profileRepositoryProvider.overrideWithValue(
            const _ProfileRepository(),
          ),
        ],
        child: MaterialApp(
          theme: theme ?? AppTheme.light,
          locale: const Locale('id'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.3),
            ),
            child: child!,
          ),
          home: const ProfileRouteScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final brightness in Brightness.values) {
    testWidgets(
      'Profile shows Admin Panel for admin in ${brightness.name} theme',
      (tester) async {
        await pumpProfile(
          tester,
          theme:
              brightness == Brightness.light ? AppTheme.light : AppTheme.dark,
          user: const User(
            id: 'admin',
            name: 'Admin',
            email: 'admin@example.com',
            profileCompleted: true,
            roles: ['admin'],
          ),
        );
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('profile-admin-panel-menu')),
          200,
        );
        expect(
          find.byKey(const ValueKey('profile-admin-panel-menu')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Profile hides Admin Panel menu from staff', (tester) async {
    await pumpProfile(
      tester,
      user: const User(
        id: 'staff',
        name: 'Staff',
        email: 'staff@example.com',
        profileCompleted: true,
        roles: ['staff'],
        permissions: ['service_bookings.viewAny'],
      ),
    );
    expect(
      find.byKey(const ValueKey('profile-admin-panel-menu')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}
