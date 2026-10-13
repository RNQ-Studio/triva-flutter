import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

/// Menangkap URL yang dibuka lewat `launchUrl` supaya test bisa memeriksa
/// nomor dan isi pesan WhatsApp tanpa meluncurkan aplikasi lain.
class FakeUrlLauncher extends UrlLauncherPlatform
    with MockPlatformInterfaceMixin {
  final launched = <Uri>[];

  /// Diset `false` untuk meniru perangkat tanpa WhatsApp.
  bool result = true;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launched.add(Uri.parse(url));
    return result;
  }

  /// Memasang pemalsu ini dan mengembalikan pemasangan asli saat test selesai.
  static FakeUrlLauncher install() {
    final previous = UrlLauncherPlatform.instance;
    final fake = FakeUrlLauncher();
    UrlLauncherPlatform.instance = fake;
    addTearDown(() => UrlLauncherPlatform.instance = previous);
    return fake;
  }
}
