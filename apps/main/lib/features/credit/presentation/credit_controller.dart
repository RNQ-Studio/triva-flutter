import 'dart:math';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/credit_repository.dart';
import '../domain/credit_models.dart';

final creditRepositoryProvider = Provider<CreditRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final auth = ref.watch(authProvider);
  return CreditRepository(
    dio: DioClient(
      storage,
      onLogout: () => ref.read(authProvider.notifier).expireSession(),
    ).dio,
    storage: storage,
    userId: auth is AuthAuthenticated ? auth.user.id : null,
  );
});

final creditProgramsProvider = FutureProvider<List<CreditProgram>>((ref) {
  return ref.watch(creditRepositoryProvider).listPrograms();
}, retry: (_, __) => null);

final creditSimulationsProvider = FutureProvider<List<CreditSimulation>>((ref) {
  return ref.watch(creditRepositoryProvider).listSimulations();
}, retry: (_, __) => null);

final creditSimulationProvider =
    FutureProvider.family<CreditSimulation, String>((ref, id) {
  return ref.watch(creditRepositoryProvider).getSimulation(id);
}, retry: (_, __) => null);

class CreditFlowState {
  const CreditFlowState({
    required this.draft,
    this.calculation,
    this.scenarios = const [],
    this.savedSimulation,
    this.isCalculating = false,
    this.isSaving = false,
    this.isRequestingFollowUp = false,
    this.error,
  });

  final CreditSimulationDraft draft;
  final CreditCalculation? calculation;
  final List<CreditCalculation> scenarios;
  final CreditSimulation? savedSimulation;
  final bool isCalculating;
  final bool isSaving;
  final bool isRequestingFollowUp;
  final String? error;

  CreditFlowState copyWith({
    CreditSimulationDraft? draft,
    CreditCalculation? calculation,
    List<CreditCalculation>? scenarios,
    CreditSimulation? savedSimulation,
    bool? isCalculating,
    bool? isSaving,
    bool? isRequestingFollowUp,
    String? error,
    bool clearCalculation = false,
    bool clearSaved = false,
    bool clearError = false,
  }) =>
      CreditFlowState(
        draft: draft ?? this.draft,
        calculation: clearCalculation ? null : calculation ?? this.calculation,
        scenarios: scenarios ?? this.scenarios,
        savedSimulation:
            clearSaved ? null : savedSimulation ?? this.savedSimulation,
        isCalculating: isCalculating ?? this.isCalculating,
        isSaving: isSaving ?? this.isSaving,
        isRequestingFollowUp: isRequestingFollowUp ?? this.isRequestingFollowUp,
        error: clearError ? null : error ?? this.error,
      );
}

class CreditFlowController extends AsyncNotifier<CreditFlowState> {
  int _inputRevision = 0;

  CreditRepository get _repository => ref.read(creditRepositoryProvider);

  @override
  Future<CreditFlowState> build() async =>
      CreditFlowState(draft: await _repository.loadDraft());

  Future<void> setSourceAppraisal(String? appraisalId) async {
    final current = state.value;
    if (current == null ||
        appraisalId == null ||
        appraisalId == current.draft.tradeInAppraisalId) {
      return;
    }
    await _saveDraft(
      current.draft.copyWith(
        tradeInAppraisalId: appraisalId,
        manualTradeInValue: 0,
        useTradeInAsDp: false,
      ),
    );
  }

  Future<void> setCampaignSource(String? campaignSource) async {
    final current = state.value;
    final raw = campaignSource?.trim();
    final normalized =
        raw != null && raw.length > 100 ? raw.substring(0, 100) : raw;
    if (current == null ||
        normalized == null ||
        normalized.isEmpty ||
        normalized == current.draft.campaignSource) {
      return;
    }
    await _saveDraft(
      current.draft.copyWith(campaignSource: normalized),
    );
  }

  Future<void> selectProgram(CreditProgram program) async {
    final current = state.value;
    if (current == null) return;
    await _saveDraft(
      current.draft.copyWith(
        programId: program.id,
        otrPrice: program.otrPrice,
        cashDownPayment: max(
          program.minimumDpAmount - program.approvedDiscount,
          0,
        ),
        tenorMonths: program.tenorOptions.first.tenorMonths,
      ),
    );
  }

  Future<void> updateInputs({
    required int cashDownPayment,
    required int manualTradeInValue,
    required bool useTradeInAsDp,
    required int oldVehiclePayoff,
    required int tenorMonths,
    required bool acceptExpiredAppraisal,
  }) async {
    final current = state.value;
    if (current == null) return;
    await _saveDraft(
      current.draft.copyWith(
        cashDownPayment: cashDownPayment,
        manualTradeInValue: manualTradeInValue,
        useTradeInAsDp: useTradeInAsDp,
        oldVehiclePayoff: oldVehiclePayoff,
        tenorMonths: tenorMonths,
        acceptExpiredAppraisal: acceptExpiredAppraisal,
      ),
    );
  }

  void markInputsDirty() {
    _inputRevision++;
    final current = state.value;
    if (current == null ||
        (current.calculation == null && current.savedSimulation == null)) {
      return;
    }
    state = AsyncData(
      current.copyWith(
        clearCalculation: true,
        clearSaved: true,
        clearError: true,
      ),
    );
  }

  Future<void> persistInputsOnExit({
    required int cashDownPayment,
    required int manualTradeInValue,
    required bool useTradeInAsDp,
    required int oldVehiclePayoff,
    required int tenorMonths,
    required bool acceptExpiredAppraisal,
  }) async {
    final current = state.value;
    if (current == null) return;
    _inputRevision++;
    try {
      await _repository.saveDraft(
        current.draft
            .copyWith(
              cashDownPayment: cashDownPayment,
              manualTradeInValue: manualTradeInValue,
              useTradeInAsDp: useTradeInAsDp,
              oldVehiclePayoff: oldVehiclePayoff,
              tenorMonths: tenorMonths,
              acceptExpiredAppraisal: acceptExpiredAppraisal,
            )
            .copyWith(clearIdempotency: true),
      );
    } on Object {
      // This is a best-effort flush during widget teardown. The next edit will
      // retry normal persistence and surface failures through the flow state.
    }
  }

  Future<CreditCalculation?> calculate() async {
    var current = state.value;
    if (current == null ||
        current.isCalculating ||
        !current.draft.canCalculate) {
      return null;
    }
    final inputRevision = _inputRevision;
    state = AsyncData(
      current.copyWith(isCalculating: true, clearError: true),
    );
    try {
      final result = await _repository.calculate(current.draft);
      current = state.value!;
      if (inputRevision != _inputRevision) {
        state = AsyncData(
          current.copyWith(
            isCalculating: false,
            clearCalculation: true,
            clearSaved: true,
          ),
        );
        return null;
      }
      state = AsyncData(
        current.copyWith(
          calculation: result,
          isCalculating: false,
          clearSaved: true,
        ),
      );
      return result;
    } catch (error) {
      current = state.value!;
      state = AsyncData(
        current.copyWith(
          isCalculating: false,
          error: friendlyCreditError(error),
        ),
      );
      return null;
    }
  }

  Future<bool> addScenario() async {
    var current = state.value;
    final calculation = current?.calculation;
    if (current == null || calculation == null) return false;
    if (current.scenarios.any(
      (item) => item.scenarioKey == calculation.scenarioKey,
    )) {
      state = AsyncData(
        current.copyWith(error: 'scenario_duplicate'),
      );
      return false;
    }
    if (current.scenarios.length >= 3) {
      state = AsyncData(current.copyWith(error: 'scenario_limit'));
      return false;
    }
    var draft = current.draft;
    if (draft.comparisonGroupId == null) {
      draft = draft.copyWith(
        comparisonGroupId: _uuidV4(),
        clearIdempotency: true,
      );
      await _repository.saveDraft(draft);
    }
    current = state.value!;
    state = AsyncData(
      current.copyWith(
        draft: draft,
        scenarios: [...current.scenarios, calculation],
        clearError: true,
      ),
    );
    return true;
  }

  Future<CreditSimulation?> save() async {
    var current = state.value;
    if (current == null || current.isSaving || current.calculation == null) {
      return null;
    }
    var draft = current.draft;
    if (draft.idempotencyKey == null) {
      draft = draft.copyWith(idempotencyKey: _uuidV4());
      await _repository.saveDraft(draft);
    }
    state = AsyncData(
      current.copyWith(
        draft: draft,
        isSaving: true,
        clearError: true,
      ),
    );
    try {
      final simulation = await _repository.save(draft);
      current = state.value!;
      state = AsyncData(
        current.copyWith(
          savedSimulation: simulation,
          isSaving: false,
        ),
      );
      ref.invalidate(creditSimulationsProvider);
      return simulation;
    } catch (error) {
      current = state.value!;
      state = AsyncData(
        current.copyWith(
          isSaving: false,
          error: friendlyCreditError(error),
        ),
      );
      return null;
    }
  }

  Future<CreditSimulation?> requestFollowUp(String contactChannel) async {
    var current = state.value;
    final saved = current?.savedSimulation;
    if (current == null || saved == null || current.isRequestingFollowUp) {
      return null;
    }
    state = AsyncData(
      current.copyWith(isRequestingFollowUp: true, clearError: true),
    );
    try {
      final updated = await _repository.requestFollowUp(
        saved.id,
        contactChannel: contactChannel,
      );
      current = state.value!;
      state = AsyncData(
        current.copyWith(
          savedSimulation: updated,
          isRequestingFollowUp: false,
        ),
      );
      ref.invalidate(creditSimulationProvider(saved.id));
      ref.invalidate(creditSimulationsProvider);
      ref.invalidate(notificationsListProvider);
      ref.invalidate(unreadNotificationCountProvider);
      return updated;
    } catch (error) {
      current = state.value!;
      state = AsyncData(
        current.copyWith(
          isRequestingFollowUp: false,
          error: friendlyCreditError(error),
        ),
      );
      return null;
    }
  }

  Future<void> reset() async {
    await _repository.clearDraft();
    state = const AsyncData(
      CreditFlowState(draft: CreditSimulationDraft()),
    );
  }

  Future<void> _saveDraft(CreditSimulationDraft draft) async {
    if (state.value == null) return;
    draft = draft.copyWith(clearIdempotency: true);
    final inputRevision = ++_inputRevision;
    await _repository.saveDraft(draft);
    if (inputRevision != _inputRevision) return;
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        draft: draft,
        clearCalculation: true,
        clearSaved: true,
        clearError: true,
      ),
    );
  }

  String _uuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final value =
        bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return '${value.substring(0, 8)}-${value.substring(8, 12)}-'
        '${value.substring(12, 16)}-${value.substring(16, 20)}-'
        '${value.substring(20)}';
  }
}

final creditFlowProvider =
    AsyncNotifierProvider<CreditFlowController, CreditFlowState>(
  CreditFlowController.new,
  retry: (_, __) => null,
);

String friendlyCreditError(Object error) {
  if (error is DioException) {
    final body = error.response?.data;
    if (body is Map<String, dynamic>) {
      final errors = body['errors'];
      if (errors is Map<String, dynamic>) {
        final messages = errors.values
            .whereType<List<dynamic>>()
            .expand((items) => items)
            .map((item) => item.toString())
            .where((item) => item.isNotEmpty)
            .join('\n');
        if (messages.isNotEmpty) return messages;
      }
      final message = body['message']?.toString();
      if (message != null && message.isNotEmpty) return message;
    }
  }
  return 'general';
}
