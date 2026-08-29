import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'admin_directory_controller.dart';

/// Kerangka daftar admin: pencarian, saringan status, daftar, dan muat lagi.
class AdminListScaffold<T> extends ConsumerStatefulWidget {
  const AdminListScaffold({
    super.key,
    required this.title,
    required this.searchHint,
    required this.state,
    required this.controller,
    required this.itemBuilder,
    required this.emptyTitle,
    required this.emptyDescription,
    this.statusOptions = const <({String value, String label})>[],
    this.allStatusLabel,
  });

  final String title;
  final String searchHint;
  final AsyncValue<AdminListState<T>> state;
  final AdminListController<T> controller;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final String emptyTitle;
  final String emptyDescription;
  final List<({String value, String label})> statusOptions;
  final String? allStatusLabel;

  @override
  ConsumerState<AdminListScaffold<T>> createState() =>
      _AdminListScaffoldState<T>();
}

class _AdminListScaffoldState<T> extends ConsumerState<AdminListScaffold<T>> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_maybeLoadMore)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _maybeLoadMore() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 240) return;
    widget.controller.loadMore();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = widget.state;
    final selectedStatus = state.value?.status;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.large,
                AppSpacing.small,
                AppSpacing.large,
                AppSpacing.small,
              ),
              child: SearchBar(
                controller: _searchController,
                hintText: widget.searchHint,
                leading: const Icon(Icons.search_rounded),
                trailing: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                        widget.controller.search('');
                      },
                      icon: const Icon(Icons.close_rounded),
                      tooltip: l10n.clear,
                    ),
                ],
                textInputAction: TextInputAction.search,
                onChanged: (_) => setState(() {}),
                onSubmitted: widget.controller.search,
              ),
            ),
            if (widget.statusOptions.isNotEmpty)
              SizedBox(
                height: 52,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.large,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.small),
                      child: ChoiceChip(
                        label:
                            Text(widget.allStatusLabel ?? l10n.adminFilterAll),
                        selected: selectedStatus == null,
                        onSelected: (_) =>
                            widget.controller.filterByStatus(null),
                      ),
                    ),
                    for (final option in widget.statusOptions)
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.small),
                        child: ChoiceChip(
                          label: Text(option.label),
                          selected: selectedStatus == option.value,
                          onSelected: (_) =>
                              widget.controller.filterByStatus(option.value),
                        ),
                      ),
                  ],
                ),
              ),
            Expanded(
              child: state.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => AdminDirectoryMessage(
                  icon: isAdminDirectoryOffline(error)
                      ? Icons.wifi_off_rounded
                      : Icons.error_outline_rounded,
                  title: isAdminDirectoryOffline(error)
                      ? l10n.bookingOfflineError
                      : l10n.loadFailed,
                  description: isAdminDirectoryOffline(error)
                      ? l10n.submissionNetworkError
                      : l10n.errorGeneral,
                  action: OutlinedButton.icon(
                    onPressed: widget.controller.refresh,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l10n.retry),
                  ),
                ),
                data: (data) => data.items.isEmpty
                    ? AdminDirectoryMessage(
                        icon: Icons.inbox_outlined,
                        title: widget.emptyTitle,
                        description: widget.emptyDescription,
                      )
                    : RefreshIndicator(
                        onRefresh: widget.controller.refresh,
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.large,
                            AppSpacing.small,
                            AppSpacing.large,
                            AppSpacing.xLarge,
                          ),
                          itemCount:
                              data.items.length + (data.canLoadMore ? 1 : 0),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.small),
                          itemBuilder: (context, index) {
                            if (index >= data.items.length) {
                              return const Padding(
                                padding: EdgeInsets.all(AppSpacing.large),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return widget.itemBuilder(
                              context,
                              data.items[index],
                            );
                          },
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminDirectoryMessage extends StatelessWidget {
  const AdminDirectoryMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.action,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: colors.onSurfaceVariant),
            const SizedBox(height: AppSpacing.medium),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xSmall),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.large),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Baris label-nilai pada layar detail admin.
class AdminDetailRow extends StatelessWidget {
  const AdminDetailRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(width: AppSpacing.small),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class AdminDetailCard extends StatelessWidget {
  const AdminDetailCard({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.small),
            ...children,
          ],
        ),
      ),
    );
  }
}

String formatAdminDate(BuildContext context, DateTime? value) {
  if (value == null) return '—';
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMMMd(locale).add_Hm().format(value.toLocal());
}

String formatAdminDateOnly(BuildContext context, DateTime? value) {
  if (value == null) return '—';
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMMMd(locale).format(value.toLocal());
}

String formatAdminCurrency(BuildContext context, int? amount) {
  if (amount == null) return '—';
  final locale = Localizations.localeOf(context).toLanguageTag();
  return NumberFormat.currency(
    locale: locale,
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(amount);
}

bool isAdminDirectoryOffline(Object error) {
  if (error is NetworkException) return true;
  if (error is! DioException) return false;
  return error.type == DioExceptionType.connectionError ||
      error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.sendTimeout;
}
