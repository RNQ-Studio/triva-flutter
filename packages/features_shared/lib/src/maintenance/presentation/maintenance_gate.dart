import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../data/maintenance_repository.dart';
import 'maintenance_screen.dart';

/// Membungkus seluruh aplikasi dan menggantinya dengan [MaintenanceScreen]
/// selama backend melaporkan sistem sedang dimatikan.
///
/// Tiga pemicu, supaya tidak ada celah:
///
/// 1. Saat app dibuka — membaca `v1/app/config`, menangkap kasus "sistem
///    sudah mati sebelum app dijalankan".
/// 2. Saat app kembali ke foreground — sesi yang ditinggal lama tidak
///    menampilkan layar biasa di atas sistem yang sudah mati.
/// 3. Kapan pun request mana pun menabrak 503 `MAINTENANCE_MODE`, lewat
///    [MaintenanceSignal] yang diisi interceptor jaringan.
///
/// Diletakkan di `builder` MaterialApp, bukan sebagai route, supaya layar ini
/// muncul di atas halaman apa pun tanpa mengganggu state router.
class MaintenanceGate extends StatefulWidget {
  const MaintenanceGate({
    super.key,
    required this.child,
    this.repository,
  });

  final Widget child;
  final MaintenanceRepository? repository;

  @override
  State<MaintenanceGate> createState() => _MaintenanceGateState();
}

class _MaintenanceGateState extends State<MaintenanceGate>
    with WidgetsBindingObserver {
  late final MaintenanceRepository _repository =
      widget.repository ?? MaintenanceRepository();

  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _check();
    }
  }

  Future<void> _check() async {
    if (_isChecking) return;
    _isChecking = true;
    if (mounted) setState(() {});

    try {
      final status = await _repository.fetch();
      // `null` berarti status tidak dapat dipastikan — misalnya jaringan
      // mati. Membiarkan state apa adanya lebih baik daripada mengunci user
      // di layar maintenance hanya karena koneksinya buruk.
      if (status != null) MaintenanceSignal.instance.apply(status);
    } finally {
      _isChecking = false;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MaintenanceStatus>(
      valueListenable: MaintenanceSignal.instance.status,
      builder: (context, status, _) {
        if (!status.isActive) return widget.child;

        return MaintenanceScreen(
          status: status,
          isRetrying: _isChecking,
          onRetry: _check,
        );
      },
    );
  }
}
