import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/admin_directory_repository.dart';
import '../domain/admin_directory_models.dart';

final adminDirectoryRepositoryProvider =
    Provider<AdminDirectoryRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return AdminDirectoryRepository(
    DioClient(
      storage,
      onLogout: () => ref.read(authProvider.notifier).expireSession(),
    ).dio,
  );
});

/// Kondisi satu daftar admin: isi, kata kunci, saringan, dan posisi paginasi.
class AdminListState<T> {
  const AdminListState({
    required this.items,
    required this.search,
    required this.currentPage,
    required this.lastPage,
    this.status,
    this.isLoadingMore = false,
  });

  final List<T> items;
  final String search;
  final String? status;
  final int currentPage;
  final int lastPage;
  final bool isLoadingMore;

  bool get canLoadMore => currentPage < lastPage;

  AdminListState<T> copyWith({
    List<T>? items,
    String? search,
    String? status,
    bool clearStatus = false,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore,
  }) =>
      AdminListState<T>(
        items: items ?? this.items,
        search: search ?? this.search,
        status: clearStatus ? null : status ?? this.status,
        currentPage: currentPage ?? this.currentPage,
        lastPage: lastPage ?? this.lastPage,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}

/// Perilaku bersama daftar admin: cari, saring status, dan muat halaman lain.
abstract class AdminListController<T> extends AsyncNotifier<AdminListState<T>> {
  AdminDirectoryRepository get repository =>
      ref.read(adminDirectoryRepositoryProvider);

  Future<AdminPage<T>> fetch({
    required String search,
    required String? status,
    required int page,
  });

  @override
  Future<AdminListState<T>> build() => _load(search: '', status: null, page: 1);

  Future<void> search(String value) => _replace(
        search: value.trim(),
        status: state.value?.status,
      );

  Future<void> filterByStatus(String? status) => _replace(
        search: state.value?.search ?? '',
        status: status,
      );

  Future<void> refresh() => _replace(
        search: state.value?.search ?? '',
        status: state.value?.status,
      );

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.canLoadMore) {
      return;
    }
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final page = await fetch(
        search: current.search,
        status: current.status,
        page: current.currentPage + 1,
      );
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...page.items],
          currentPage: page.currentPage,
          lastPage: page.lastPage,
          isLoadingMore: false,
        ),
      );
    } on Object catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> _replace({
    required String search,
    required String? status,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _load(search: search, status: status, page: 1),
    );
  }

  Future<AdminListState<T>> _load({
    required String search,
    required String? status,
    required int page,
  }) async {
    final result = await fetch(search: search, status: status, page: page);
    return AdminListState<T>(
      items: result.items,
      search: search,
      status: status,
      currentPage: result.currentPage,
      lastPage: result.lastPage,
    );
  }
}

class AdminUserDirectoryController
    extends AdminListController<AdminUserRecord> {
  @override
  Future<AdminPage<AdminUserRecord>> fetch({
    required String search,
    required String? status,
    required int page,
  }) {
    return repository.listUsers(
      search: search,
      // Daftar pengguna memakai kolom saring yang sama untuk gender.
      gender: status,
      page: page,
    );
  }
}

final adminUserDirectoryProvider = AsyncNotifierProvider<
    AdminUserDirectoryController, AdminListState<AdminUserRecord>>(
  AdminUserDirectoryController.new,
);

final adminUserDetailProvider =
    FutureProvider.autoDispose.family<AdminUserRecord, String>((ref, userId) {
  return ref.watch(adminDirectoryRepositoryProvider).getUser(userId);
}, retry: (_, __) => null);

class AdminAppraisalListController
    extends AdminListController<AdminAppraisalRecord> {
  @override
  Future<AdminPage<AdminAppraisalRecord>> fetch({
    required String search,
    required String? status,
    required int page,
  }) {
    return repository.listAppraisals(
      search: search,
      status: status,
      page: page,
    );
  }
}

final adminAppraisalListProvider = AsyncNotifierProvider<
    AdminAppraisalListController, AdminListState<AdminAppraisalRecord>>(
  AdminAppraisalListController.new,
);

final adminAppraisalDetailProvider = FutureProvider.autoDispose
    .family<AdminAppraisalRecord, String>((ref, appraisalId) {
  return ref.watch(adminDirectoryRepositoryProvider).getAppraisal(appraisalId);
}, retry: (_, __) => null);

final adminAppraisalStatusesProvider =
    FutureProvider.autoDispose<List<AdminStatusOption>>((ref) {
  return ref.watch(adminDirectoryRepositoryProvider).appraisalStatuses();
}, retry: (_, __) => null);

class AdminCreditSimulationListController
    extends AdminListController<AdminCreditSimulationRecord> {
  @override
  Future<AdminPage<AdminCreditSimulationRecord>> fetch({
    required String search,
    required String? status,
    required int page,
  }) {
    return repository.listCreditSimulations(
      search: search,
      status: status,
      page: page,
    );
  }
}

final adminCreditSimulationListProvider = AsyncNotifierProvider<
    AdminCreditSimulationListController,
    AdminListState<AdminCreditSimulationRecord>>(
  AdminCreditSimulationListController.new,
);

final adminCreditSimulationDetailProvider = FutureProvider.autoDispose
    .family<AdminCreditSimulationRecord, String>((ref, simulationId) {
  return ref
      .watch(adminDirectoryRepositoryProvider)
      .getCreditSimulation(simulationId);
}, retry: (_, __) => null);

final adminCreditSimulationStatusesProvider =
    FutureProvider.autoDispose<List<AdminStatusOption>>((ref) {
  return ref.watch(adminDirectoryRepositoryProvider).creditSimulationStatuses();
}, retry: (_, __) => null);
