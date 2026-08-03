import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Google services includes every active Android signing certificate', () {
    final configFile = [
      File('android/app/google-services.json'),
      File('apps/main/android/app/google-services.json'),
    ].firstWhere(
      (file) => file.existsSync(),
      orElse: () => throw StateError('google-services.json was not found'),
    );
    final config =
        jsonDecode(configFile.readAsStringSync()) as Map<String, dynamic>;

    final projectInfo = config['project_info'] as Map<String, dynamic>;
    expect(projectInfo['project_id'], 'triva-7138e');

    final clients =
        (config['client'] as List<dynamic>).cast<Map<String, dynamic>>();
    final androidClient = clients.singleWhere((client) {
      final clientInfo = client['client_info'] as Map<String, dynamic>;
      final androidInfo =
          clientInfo['android_client_info'] as Map<String, dynamic>;
      return androidInfo['package_name'] == 'id.rnq.triva';
    });
    final clientInfo = androidClient['client_info'] as Map<String, dynamic>;
    expect(
      clientInfo['mobilesdk_app_id'],
      '1:1074553653742:android:a577626fe1b33fcda526ff',
    );

    final oauthClients = (androidClient['oauth_client'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final certificateHashes = oauthClients
        .where((client) => client['client_type'] == 1)
        .map((client) {
      final androidInfo = client['android_info'] as Map<String, dynamic>;
      return androidInfo['certificate_hash'] as String;
    }).toSet();

    expect(
      certificateHashes,
      containsAll(<String>{
        // Upload certificate used by locally signed release artifacts.
        'b90847534e3103fb923e6a1421a6331c7f6d6c85',
        // Original Play App Signing certificate used by older installs.
        'f3cc122434aaf0b0deb36163231bf508bba9c4f7',
        // Current Play App Signing certificate used by Play version code 10+.
        'b6d17f3d5ff2c8a868dc50e82f8c3ec3257bf399',
      }),
    );

    expect(
      oauthClients.where((client) => client['client_type'] == 3),
      isNotEmpty,
      reason: 'Firebase Auth needs a web OAuth client for ID tokens.',
    );
  });
}
