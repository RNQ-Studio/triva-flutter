## [Unreleased]

### Changed
- Migrated all state providers (Auth, Profile, Notifications, Settings) to Riverpod Generator (`@riverpod` and `@Riverpod(keepAlive: true)`).
- Re-architected providers naming conventions (`authNotifierProvider` -> `authProvider`, etc.) to match generator standards.

### Added
- Added premium `SplashScreen` with gradient background, fade-in + scale animation, and auto-navigation logic.
- Added `OnboardingScreen` with 3-page PageView, animated dot indicator, skip button, and CTA.
- Added `OnboardingNotifier` and `OnboardingRepository` for persistent onboarding state management.
- Added `BiometricAuthService` wrapper around `local_auth` for fingerprint/Face ID authentication.
- Added `loginWithBiometric()` method to `AuthNotifier` for biometric-based session restoration.
- Added biometric login button to `LoginScreen` (conditionally shown when device supports and user enables biometrics).
- Updated `authRedirect` to allow `/splash` and `/onboarding` routes without auth redirect.

## 0.0.1

- Initial release of shared feature modules.
- Added the initial auth, profile, notification, theme, and locale foundations.
