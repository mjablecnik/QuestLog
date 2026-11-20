# Design Document: Deep Links

## Overview

`app_links` delivers the launching URL and later ones as a `Stream<Uri>`. `deepLinksProvider` holds it, empty by default so tests and Linux need no platform plugin; `main` overrides it with `appLinksStream()`. `shellTabFromUri` (pure) maps a URL to a `ShellTab`; `AppShell` listens, pops to the first route and selects the tab. iOS gets `CFBundleURLTypes` with the scheme `questlog` and `FlutterDeepLinkingEnabled` false, so Flutter's own route-based deep linking does not also handle the URL.

## Project Structure

```
lib/ui/screens/shell/deep_link.dart   NEW: shellTabFromUri, deepLinksProvider, appLinksStream
lib/ui/screens/shell/app_shell.dart   listens to the links
ios/Runner/Info.plist                 URL scheme
```

## Components and Interfaces

```dart
ShellTab? shellTabFromUri(Uri uri);
final deepLinksProvider = Provider<Stream<Uri>>(...);
Stream<Uri> appLinksStream();
```

## Correctness Properties

`shellTabFromUri` returns a tab only for scheme `questlog` and a host (or first path segment) equal to a tab name, ignoring case.

## Error Handling

A stream error is ignored.

## Testing Strategy

A unit test of `shellTabFromUri` and a Shell widget test that sends links through an injected stream. The iOS registration and the Shortcuts icon are checked by hand on a device.
