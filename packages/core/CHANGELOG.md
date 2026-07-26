## [Unreleased]

### Added
- Added `WebMobileViewport` to keep desktop web navigation on a centered mobile canvas.
- Integrated Firebase Core & Firebase Cloud Messaging (FCM) services in `FirebaseService` and `FCMNotificationService`.
- Added Drift database structured local storage engine (`AppDatabase` with `CacheEntries` table) to support high-performance offline caching.
- Added `TokenRefreshInterceptor` (QueuedInterceptor) for automatic 401 token refresh with race-condition protection.
- Added `onLogout` callback support to `DioClient` for global logout events on token refresh failure.
- Added `keyOnboardingCompleted` and `keyBiometricEnabled` storage keys to `AppConstants`.

### Removed
- Removed the obsolete onboarding completion storage key and localization copy.

## 0.0.1

- Initial release of the shared core foundation.
- Added app configuration, environment handling, network client, storage abstraction, theme, localization, responsive utilities, route constants, reusable widgets, errors, extensions, and common validators.
