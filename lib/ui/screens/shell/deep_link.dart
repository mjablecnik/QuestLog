import 'package:app_links/app_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'questlog_tab_bar.dart';

/// The tab a `questlog://<tab>` link opens: `quests`, `missions`, `calendar`,
/// `notes` or `settings`. Null for any other link, so a stray URL is ignored.
ShellTab? shellTabFromUri(Uri uri) {
  if (uri.scheme != 'questlog') return null;
  final String name = uri.host.isNotEmpty ? uri.host : (uri.pathSegments.isEmpty ? '' : uri.pathSegments.first);
  for (final ShellTab tab in ShellTab.values) {
    if (tab.name == name.toLowerCase()) return tab;
  }
  return null;
}

/// The links that open the app, the one that launched it first. Empty by
/// default (tests, Linux); `main` swaps in [appLinksStream] on the device.
final deepLinksProvider = Provider<Stream<Uri>>((ref) => const Stream<Uri>.empty());

/// The launching link, then every later one, from the platform.
Stream<Uri> appLinksStream() async* {
  final AppLinks links = AppLinks();
  final Uri? first = await links.getInitialLink();
  if (first != null) yield first;
  yield* links.uriLinkStream;
}
