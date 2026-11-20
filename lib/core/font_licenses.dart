import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Font families whose SIL OFL text is bundled in `assets/fonts/licenses/`.
///
/// Each entry is the family name shown on the licence page and the licence
/// file name stem. Delete an entry together with its fonts and licence file.
const List<({String name, String file})> bundledFontLicenses =
    <({String name, String file})>[
      (name: 'Figtree', file: 'Figtree'),
    ];

/// Asset path of the licence text for [file].
String fontLicenseAsset(String file) => 'assets/fonts/licenses/$file-OFL.txt';

/// Adds one entry per bundled font family to Flutter's [LicenseRegistry], so
/// the standard licence page lists them next to the framework and package
/// licences, which stay untouched.
void registerFontLicenses({AssetBundle? bundle}) {
  final source = bundle ?? rootBundle;
  for (final font in bundledFontLicenses) {
    LicenseRegistry.addLicense(() async* {
      final text = await source.loadString(fontLicenseAsset(font.file));
      yield LicenseEntryWithLineBreaks(<String>['${font.name} (font)'], text);
    });
  }
}
