import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FailingMarkAllRepository implements NotificationsRepository {
  final items = [
    AppNotification(
      id: 'notification-1',
      title: 'Booking diperbarui',
      body: 'Jadwal baru tersedia.',
      createdAt: DateTime(2026, 7, 27),
      type: 'toyota_service_booking',
    ),
  ];

  var markAllCalls = 0;

  @override
  Future<List<AppNotification>> getNotifications() async => items;

  @override
  Future<int> getUnreadCount() async => 1;

  @override
  Future<void> markAllAsRead() async {
    markAllCalls += 1;
    throw StateError('offline');
  }

  @override
  Future<void> markAsRead(String notificationId) async {}
}

class _SwitchableAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => AuthAuthenticated(_user('user-a'));

  void switchTo(String id) => state = AuthAuthenticated(_user(id));
}

class _AccountRepository implements NotificationsRepository {
  var listCalls = 0;

  @override
  Future<List<AppNotification>> getNotifications() async {
    listCalls += 1;
    final owner = listCalls == 1 ? 'user-a' : 'user-b';
    return [
      AppNotification(
        id: owner,
        title: owner,
        body: owner,
        createdAt: DateTime(2026, 7, 27),
        type: 'test',
      ),
    ];
  }

  @override
  Future<int> getUnreadCount() async => 0;

  @override
  Future<void> markAllAsRead() async {}

  @override
  Future<void> markAsRead(String notificationId) async {}
}

void main() {
  testWidgets('mark-all failure keeps unread inbox and shows retry feedback',
      (tester) async {
    final repository = _FailingMarkAllRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(_SwitchableAuthNotifier.new),
          notificationsRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('id'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const NotificationsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tandai semua dibaca'));
    await tester.pumpAndSettle();

    expect(repository.markAllCalls, 1);
    expect(find.text('Booking diperbarui'), findsOneWidget);
    expect(find.byType(Badge), findsOneWidget);
    expect(
      find.text(
        'Notifikasi gagal ditandai dibaca. Silakan coba lagi.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  test('account switch rebuilds inbox without exposing account A cache',
      () async {
    final repository = _AccountRepository();
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(_SwitchableAuthNotifier.new),
        notificationsRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final accountA = await container.read(notificationsListProvider.future);
    expect(accountA.single.id, 'user-a');

    (container.read(authProvider.notifier) as _SwitchableAuthNotifier)
        .switchTo('user-b');
    final duringSwitch = container.read(visibleNotificationsListProvider);
    expect(duringSwitch.value?.any((item) => item.id == 'user-a') ?? false,
        isFalse);
    final accountB = await container.read(notificationsListProvider.future);
    expect(accountB.single.id, 'user-b');
  });
}

User _user(String id) => User(
      id: id,
      name: id,
      email: '$id@example.com',
      profileCompleted: true,
    );
