import 'package:core/core.dart';

class MainConfig extends AppConfig {
  @override
  Environment get environment => Environment.fromString(
        const String.fromEnvironment('ENV', defaultValue: 'dev'),
      );

  @override
  String get baseUrl => switch (environment) {
        Environment.dev => 'https://triva.ramadhanrosihadi.web.id/api/',
        Environment.staging => 'https://triva.ramadhanrosihadi.web.id/api/',
        Environment.prod => 'https://triva.ramadhanrosihadi.web.id/api/',
      };
}
