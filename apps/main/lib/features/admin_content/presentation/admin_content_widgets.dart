import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

/// Gambar yang baru dipilih admin dan belum diunggah.
class PickedImage {
  const PickedImage({required this.bytes, required this.name});

  final Uint8List bytes;
  final String name;
}

/// Membuka galeri. [compress] dimatikan untuk logo supaya PNG transparan
/// tidak dikodekan ulang.
Future<PickedImage?> pickAdminImage({bool compress = true}) async {
  final file = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxWidth: compress ? 2000 : null,
    imageQuality: compress ? 85 : null,
  );
  if (file == null) return null;
  return PickedImage(bytes: await file.readAsBytes(), name: file.name);
}

String formatAdminRupiah(int value) => NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);

/// Pesan dari server (validasi 422 atau pesan error) bila ada, selain itu
/// pesan umum.
String adminContentErrorMessage(AppLocalizations l10n, Object error) {
  final cause =
      error is DioException && error.error != null ? error.error : error;
  if (cause is ServerException) {
    if (cause.validationErrors.isNotEmpty) {
      return cause.validationErrors.values
          .expand((messages) => messages)
          .join('\n');
    }
    if (cause.message.trim().isNotEmpty) return cause.message;
  }
  if (cause is NetworkException) return l10n.submissionNetworkError;
  return l10n.adminContentSaveFailed;
}

bool isAdminOfflineError(Object error) {
  if (error is NetworkException) return true;
  if (error is! DioException) return false;
  return error.error is NetworkException ||
      error.type == DioExceptionType.connectionError ||
      error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.sendTimeout;
}

void showAdminSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

Future<bool> confirmAdminDelete(BuildContext context, String name) async {
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await showAdaptiveDialog<bool>(
    context: context,
    builder: (context) => AlertDialog.adaptive(
      title: Text(l10n.adminContentDeleteConfirmTitle(name)),
      content: Text(l10n.adminContentDeleteConfirmDescription),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: Text(l10n.adminContentDelete),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// Layar admin yang diblokir: arahkan ke beranda, sama seperti modul admin
/// lain, sambil menampilkan alasan selama satu bingkai.
class AdminContentAccessDenied extends StatelessWidget {
  const AdminContentAccessDenied({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) context.go('/');
    });
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: AdminContentMessage(
        icon: Icons.lock_outline_rounded,
        title: l10n.adminAccessDenied,
        description: l10n.adminAccessDeniedDescription,
      ),
    );
  }
}

class AdminContentMessage extends StatelessWidget {
  const AdminContentMessage({
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: AppIconSize.large, color: colors.primary),
            const SizedBox(height: AppSpacing.large),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.small),
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

/// Isi daftar admin untuk keadaan memuat, gagal, kosong, dan berisi.
class AdminContentListBody<T> extends StatelessWidget {
  const AdminContentListBody({
    super.key,
    required this.items,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyDescription,
    required this.onRefresh,
    required this.itemBuilder,
  });

  final AsyncValue<List<T>> items;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyDescription;
  final Future<void> Function() onRefresh;
  final Widget Function(BuildContext context, T item) itemBuilder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return items.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) {
        final offline = isAdminOfflineError(error);
        return AdminContentMessage(
          icon: offline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
          title: offline ? l10n.bookingOfflineError : l10n.loadFailed,
          description:
              offline ? l10n.submissionNetworkError : l10n.errorGeneral,
          action: OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.retry),
          ),
        );
      },
      data: (values) => RefreshIndicator(
        onRefresh: onRefresh,
        child: values.isEmpty
            ? ListView(
                children: [
                  AdminContentMessage(
                    icon: emptyIcon,
                    title: emptyTitle,
                    description: emptyDescription,
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.large,
                  AppSpacing.small,
                  AppSpacing.large,
                  // Ruang untuk tombol tambah melayang.
                  96,
                ),
                itemCount: values.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.small),
                itemBuilder: (context, index) =>
                    itemBuilder(context, values[index]),
              ),
      ),
    );
  }
}

/// Label status kecil di daftar admin.
class AdminStatusChip extends StatelessWidget {
  const AdminStatusChip({
    super.key,
    required this.label,
    this.positive = false,
  });

  final String label;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background =
        positive ? colors.primaryContainer : colors.surfaceContainerHighest;
    final foreground =
        positive ? colors.onPrimaryContainer : colors.onSurfaceVariant;
    return DecoratedBox(
      decoration:
          BoxDecoration(color: background, borderRadius: AppRadius.pill),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.small,
          vertical: 2,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

/// Pratinjau gambar yang tersimpan atau yang baru dipilih, beserta tombol
/// pilih/ganti gambar.
class AdminImageField extends StatelessWidget {
  const AdminImageField({
    super.key,
    required this.label,
    required this.helperText,
    required this.aspectRatio,
    required this.onPick,
    this.picked,
    this.currentUrl,
    this.errorText,
    this.fit = BoxFit.contain,
    this.lightBackground = false,
  });

  final String label;
  final String helperText;
  final double aspectRatio;
  final VoidCallback onPick;
  final PickedImage? picked;
  final String? currentUrl;
  final String? errorText;
  final BoxFit fit;

  /// Logo mitra selalu berdudukan putih di beranda; pratinjaunya mengikuti.
  final bool lightBackground;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final picked = this.picked;
    final currentUrl = this.currentUrl;
    final hasImage = picked != null || (currentUrl?.isNotEmpty ?? false);
    final Widget preview;
    if (picked != null) {
      preview = Image.memory(picked.bytes, fit: fit);
    } else if (currentUrl != null && currentUrl.isNotEmpty) {
      preview = Image.network(
        currentUrl,
        fit: fit,
        errorBuilder: (_, __, ___) => Icon(
          Icons.image_not_supported_outlined,
          color: colors.onSurfaceVariant,
        ),
      );
    } else {
      preview = Icon(
        Icons.add_photo_alternate_outlined,
        size: AppIconSize.large,
        color: colors.onSurfaceVariant,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.small),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280, maxHeight: 320),
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: Material(
                color: lightBackground
                    ? AppColors.surfaceLight
                    : colors.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.medium,
                  side: BorderSide(
                    color: errorText == null
                        ? colors.outlineVariant
                        : colors.error,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onPick,
                  child: Padding(
                    padding: lightBackground
                        ? const EdgeInsets.all(AppSpacing.medium)
                        : EdgeInsets.zero,
                    child: Center(child: preview),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        Center(
          child: OutlinedButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(
              hasImage
                  ? l10n.adminContentReplaceImage
                  : l10n.adminContentPickImage,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xSmall),
        Text(
          errorText ?? helperText,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color:
                    errorText == null ? colors.onSurfaceVariant : colors.error,
              ),
        ),
      ],
    );
  }
}

/// Validasi angka bulat dalam rentang tertutup.
String? Function(String?) adminIntRangeValidator(
  AppLocalizations l10n, {
  required int min,
  required int max,
}) {
  return (value) {
    final parsed = int.tryParse(digitsOnly(value ?? ''));
    if (parsed == null || parsed < min || parsed > max) {
      return l10n.adminContentNumberRange(min, max);
    }
    return null;
  };
}

/// Validasi tautan opsional: kosong lolos, selain itu wajib http(s) lengkap.
String? adminOptionalUrlValidator(AppLocalizations l10n, String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return null;
  return isAdminHttpUrl(text) ? null : l10n.adminContentInvalidUrl;
}

bool isAdminHttpUrl(String value) {
  final uri = Uri.tryParse(value.trim());
  return uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.host.isNotEmpty;
}
