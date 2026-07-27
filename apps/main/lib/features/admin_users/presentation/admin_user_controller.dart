import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/admin_user_repository.dart';
import '../domain/admin_user_models.dart';

final adminUserRepositoryProvider = Provider<AdminUserRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return AdminUserRepository(
    DioClient(
      storage,
      onLogout: () => ref.read(authProvider.notifier).expireSession(),
    ).dio,
  );
});

class AdminUserAccessState {
  const AdminUserAccessState({
    required this.users,
    required this.search,
    required this.currentPage,
    required this.lastPage,
    this.isLoadingMore = false,
    this.promotingUserId,
  });

  final List<AdminUser> users;
  final String search;
  final int currentPage;
  final int lastPage;
  final bool isLoadingMore;
  final String? promotingUserId;

  bool get canLoadMore => currentPage < lastPage;

  AdminUserAccessState copyWith({
    List<AdminUser>? users,
    String? search,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore,
    String? promotingUserId,
    bool clearPromotingUser = false,
  }) =>
      AdminUserAccessState(
        users: users ?? this.users,
        search: search ?? this.search,
        currentPage: currentPage ?? this.currentPage,
        lastPage: lastPage ?? this.lastPage,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        promotingUserId:
            clearPromotingUser ? null : promotingUserId ?? this.promotingUserId,
      );
}

class AdminUserAccessController extends AsyncNotifier<AdminUserAccessState> {
  AdminUserRepository get _repository => ref.read(adminUserRepositoryProvider);

  @override
  Future<AdminUserAccessState> build() => _load(search: '', page: 1);

  Future<void> search(String value) async {
    final search = value.trim();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(search: search, page: 1));
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.canLoadMore) {
      return;
    }
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final page = await _repository.listUsers(
        search: current.search,
        page: current.currentPage + 1,
      );
      state = AsyncData(
        current.copyWith(
          users: [...current.users, ...page.users],
          currentPage: page.currentPage,
          lastPage: page.lastPage,
          isLoadingMore: false,
        ),
      );
    } on Object catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<bool> grantAdmin(String userId) async {
    final current = state.value;
    if (current == null || current.promotingUserId != null) return false;
    state = AsyncData(current.copyWith(promotingUserId: userId));
    try {
      final updated = await _repository.grantAdmin(userId);
      state = AsyncData(
        current.copyWith(
          users: [
            for (final user in current.users)
              if (user.id == updated.id) updated else user,
          ],
          clearPromotingUser: true,
        ),
      );
      return true;
    } on Object {
      state = AsyncData(current.copyWith(clearPromotingUser: true));
      return false;
    }
  }

  Future<AdminUserAccessState> _load({
    required String search,
    required int page,
  }) async {
    final result = await _repository.listUsers(search: search, page: page);
    return AdminUserAccessState(
      users: result.users,
      search: search,
      currentPage: result.currentPage,
      lastPage: result.lastPage,
    );
  }
}

final adminUserAccessProvider =
    AsyncNotifierProvider<AdminUserAccessController, AdminUserAccessState>(
  AdminUserAccessController.new,
);
