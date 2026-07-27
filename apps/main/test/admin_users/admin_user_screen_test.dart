import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:triva_app/features/admin_users/data/admin_user_repository.dart';
import 'package:triva_app/features/admin_users/domain/admin_user_models.dart';
import 'package:triva_app/features/admin_users/presentation/admin_user_controller.dart';
import 'package:triva_app/features/admin_users/presentation/admin_user_screen.dart';

class _AdminAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthAuthenticated(
        User(
          id: 'admin-1',
          name: 'Admin',
          email: 'admin@example.com',
          profileCompleted: true,
          roles: ['admin'],
          permissions: ['users.viewAny', 'users.update'],
        ),
      );
}

class _MockAdminUserRepository extends Mock implements AdminUserRepository {}

void main() {
  late _MockAdminUserRepository repository;

  setUp(() {
    repository = _MockAdminUserRepository();
    when(
      () => repository.listUsers(
        search: any(named: 'search'),
        page: any(named: 'page'),
      ),
    ).thenAnswer(
      (_) async => const AdminUserPage(
        users: [
          AdminUser(
            id: 'user-1',
            name: 'Existing Customer',
            email: 'customer@example.com',
            isActive: true,
            isAdmin: false,
            roles: [],
          ),
          AdminUser(
            id: 'user-2',
            name: 'Existing Admin',
            email: 'admin.two@example.com',
            isActive: true,
            isAdmin: true,
            roles: ['admin'],
          ),
        ],
        currentPage: 1,
        lastPage: 1,
      ),
    );
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required ThemeData theme,
  }) async {
    tester.view
      ..physicalSize = const Size(360, 690)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(_AdminAuthNotifier.new),
          adminUserRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: theme,
          locale: const Locale('id'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.3),
            ),
            child: child!,
          ),
          home: const AdminUserScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final brightness in Brightness.values) {
    testWidgets(
      'admin user list is compact in ${brightness.name} theme',
      (tester) async {
        await pumpScreen(
          tester,
          theme:
              brightness == Brightness.light ? AppTheme.light : AppTheme.dark,
        );

        expect(find.text('Existing Customer'), findsOneWidget);
        expect(find.text('Existing Admin'), findsOneWidget);
        expect(find.text('Jadikan admin'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('grant action confirms and updates the promoted row',
      (tester) async {
    when(() => repository.grantAdmin('user-1')).thenAnswer(
      (_) async => const AdminUser(
        id: 'user-1',
        name: 'Existing Customer',
        email: 'customer@example.com',
        isActive: true,
        isAdmin: true,
        roles: ['admin'],
      ),
    );
    await pumpScreen(tester, theme: AppTheme.light);

    await tester.tap(find.text('Existing Customer'));
    await tester.pumpAndSettle();
    expect(
      find.text('Jadikan Existing Customer sebagai admin?'),
      findsOneWidget,
    );

    await tester.tap(find.text('Jadikan admin').last);
    await tester.pumpAndSettle();

    expect(
      find.text('Akses admin untuk Existing Customer berhasil diberikan.'),
      findsOneWidget,
    );
    expect(find.text('Sudah memiliki akses admin'), findsNWidgets(2));
    verify(() => repository.grantAdmin('user-1')).called(1);
    expect(tester.takeException(), isNull);
  });
}
