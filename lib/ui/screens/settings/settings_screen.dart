import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors.dart';
import '../../../core/validation.dart';
import '../../../data/preferences.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/providers.dart';
import '../../forms/error_text.dart';
import '../../forms/validators.dart';
import '../../state/ui_providers.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common/app_icon.dart';
import '../../widgets/common/questlog_segmented.dart';
import '../../widgets/common/snackbar_host.dart';
import 'export_row.dart';
import 'rules_section.dart';
import 'shortcut_guide.dart';

/// The "Nastavení" tab: profile, language, appearance, recurring rules,
/// the Home Screen shortcut guide and About.
///
/// Every value is read from streams that already hold the stored settings, so
/// a change of language or theme repaints this screen in place: the list keeps
/// its scroll position and nothing falls back to a loading state.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        // The tab bar below already clears the bottom inset.
        bottom: false,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(
            Space.s20,
            Space.s16,
            Space.s20,
            Space.s24,
          ),
          children: <Widget>[
            Semantics(
              header: true,
              child: Text(
                l.settings_title,
                style: context.displayText.headlineLarge,
              ),
            ),
            const SizedBox(height: Space.s24),
            _Group(
              label: l.settings_groupProfile,
              child: const _HeroNameField(),
            ),
            const SizedBox(height: Space.s24),
            _Group(
              label: l.settings_groupLanguage,
              child: const _LanguageControl(),
            ),
            const SizedBox(height: Space.s24),
            _Group(
              label: l.settings_groupAppearance,
              child: const _ThemeControl(),
            ),
            const SizedBox(height: Space.s24),
            // This one draws its own group header.
            const RulesSection(),
            const SizedBox(height: Space.s24),
            _Group(
              label: l.settings_shortcutTitle,
              child: const ShortcutGuide(),
            ),
            const SizedBox(height: Space.s24),
            _Group(label: l.settings_groupData, child: const ExportRow()),
            const SizedBox(height: Space.s24),
            _Group(label: l.settings_groupAbout, child: const _AboutRow()),
          ],
        ),
      ),
    );
  }
}

/// A caps label above its content.
class _Group extends StatelessWidget {
  const _Group({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(
            label.toUpperCase(),
            style: context.bodyText.labelSmall!.copyWith(
              color: context.palette.textFaint,
            ),
          ),
        ),
        const SizedBox(height: Space.s8),
        child,
      ],
    );
  }
}

/// Shows a localized message for a failed write; never exception text.
void _reportFailure(BuildContext context, Object error) {
  if (error is! DomainError) return;
  showQuestlogSnack(
    context,
    domainErrorText(AppLocalizations.of(context), error),
  );
}

class _LanguageControl extends ConsumerWidget {
  const _LanguageControl();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final effective = ref.watch(effectiveLocaleProvider).languageCode;
    return QuestlogSegmented<AppLanguage>(
      options: <SegmentedOption<AppLanguage>>[
        SegmentedOption<AppLanguage>(
          value: AppLanguage.cs,
          label: l.settings_languageCs,
        ),
        SegmentedOption<AppLanguage>(
          value: AppLanguage.en,
          label: l.settings_languageEn,
        ),
      ],
      selected: effective == 'cs' ? AppLanguage.cs : AppLanguage.en,
      onChanged: (AppLanguage language) async {
        try {
          await ref.read(settingsServiceProvider).setLanguage(language);
        } catch (e) {
          if (!context.mounted) return;
          _reportFailure(context, e);
        }
      },
    );
  }
}

class _ThemeControl extends ConsumerWidget {
  const _ThemeControl();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final stored = ref.watch(
      settingsProvider.select((s) => s.value?.theme ?? AppTheme.system),
    );
    return QuestlogSegmented<AppTheme>(
      options: <SegmentedOption<AppTheme>>[
        SegmentedOption<AppTheme>(
          value: AppTheme.light,
          label: l.settings_themeLight,
          icon: IconAsset.sun,
        ),
        SegmentedOption<AppTheme>(
          value: AppTheme.dark,
          label: l.settings_themeDark,
          icon: IconAsset.moon,
        ),
        SegmentedOption<AppTheme>(
          value: AppTheme.system,
          label: l.settings_themeSystem,
          icon: IconAsset.auto,
        ),
      ],
      selected: stored,
      onChanged: (AppTheme theme) async {
        try {
          await ref.read(settingsServiceProvider).setTheme(theme);
        } catch (e) {
          if (!context.mounted) return;
          _reportFailure(context, e);
        }
      },
    );
  }
}

/// Application name and the version from the platform build information.
class _AboutRow extends ConsumerWidget {
  const _AboutRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final version = ref.watch(appVersionProvider).value;
    final style = context.bodyText.bodyMedium!.copyWith(
      color: context.palette.textFaint,
      fontSize: 13,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.s2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(l.app_name, style: style),
              if (version != null)
                Text(l.settings_version(version), style: style),
            ],
          ),
        ),
        const SizedBox(height: Space.s8),
        _LicensesRow(version: version),
      ],
    );
  }
}

/// Opens Flutter's licence page, which lists the framework, package and
/// bundled-font licences.
class _LicensesRow extends StatelessWidget {
  const _LicensesRow({required this.version});

  final String? version;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l.settings_licenses,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.control),
        onTap: () {
          showLicensePage(
            context: context,
            applicationName: l.app_name,
            applicationVersion: version,
          );
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.s2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  l.settings_licenses,
                  style: context.bodyText.bodyMedium!.copyWith(
                    color: p.brassText,
                  ),
                ),
                AppIcon(
                  IconAsset.chevronRight,
                  size: Metrics.iconSmall,
                  color: p.textFaint,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Hero-name field: saved when it loses focus or is submitted, with the
/// counter and the Total_XP underneath.
class _HeroNameField extends ConsumerStatefulWidget {
  const _HeroNameField();

  @override
  ConsumerState<_HeroNameField> createState() => _HeroNameFieldState();
}

class _HeroNameFieldState extends ConsumerState<_HeroNameField> {
  late final TextEditingController _controller;
  final FocusNode _focus = FocusNode();
  FieldError? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(settingsProvider).value?.heroName ?? '',
    );
    _focus.addListener(() {
      if (!_focus.hasFocus) _commit();
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Validates and stores the name; an invalid name is kept in the field and
  /// not saved.
  Future<void> _commit() async {
    final raw = _controller.text;
    final error = validateHeroName(raw);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() => _error = null);
    final stored = ref.read(settingsProvider).value?.heroName ?? '';
    final trimmed = raw.trim();
    if (trimmed != raw) {
      _controller.value = TextEditingValue(
        text: trimmed,
        selection: TextSelection.collapsed(offset: trimmed.length),
      );
    }
    if (trimmed == stored) return;
    try {
      await ref.read(settingsServiceProvider).setHeroName(trimmed);
    } catch (e) {
      if (!mounted) return;
      _reportFailure(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l = AppLocalizations.of(context);

    // Follow outside changes (first emission, restore) unless the user is typing.
    ref.listen<String?>(settingsProvider.select((s) => s.value?.heroName), (
      _,
      next,
    ) {
      if (next != null && !_focus.hasFocus && _controller.text != next) {
        _controller.text = next;
        setState(() => _error = null);
      }
    });
    final totalXp = ref.watch(totalXpProvider).value ?? 0;
    final bool hasError = _error != null;
    final TextStyle small = context.bodyText.bodySmall!.copyWith(
      color: p.textDim,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListenableBuilder(
          listenable: _focus,
          builder: (BuildContext context, Widget? child) {
            final bool active = _focus.hasFocus;
            return Container(
              constraints: const BoxConstraints(
                minHeight: Metrics.touchTarget + Space.s4,
              ),
              padding: const EdgeInsets.symmetric(horizontal: Space.s16),
              decoration: BoxDecoration(
                color: active ? p.fieldActive : p.field,
                borderRadius: BorderRadius.circular(Radii.control),
                border: hasError
                    ? Border.all(color: p.destructive)
                    : active
                    ? Border.all(color: p.brass)
                    : null,
              ),
              alignment: Alignment.centerLeft,
              child: child,
            );
          },
          child: Semantics(
            label: l.settings_heroNameLabel,
            textField: true,
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
              cursorColor: p.brass,
              style: context.bodyText.bodyLarge!.copyWith(fontSize: 16),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                // The field itself is at least as tall as the 44 px hit area,
                // so a tap anywhere in the painted box focuses it.
                contentPadding: const EdgeInsets.symmetric(
                  vertical: Space.s12 + Space.s2,
                ),
                hintText: l.settings_heroNamePlaceholder,
                hintStyle: context.bodyText.bodyLarge!.copyWith(
                  fontSize: 16,
                  color: p.textFaint,
                ),
              ),
              onChanged: (String value) =>
                  setState(() => _error = validateHeroName(value)),
              onSubmitted: (_) => _commit(),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: Space.s6),
            child: Semantics(
              liveRegion: true,
              child: Text(
                fieldErrorText(l, _error!),
                style: small.copyWith(color: p.destructive),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: Space.s6),
          child: Row(
            children: <Widget>[
              Expanded(child: Text(l.settings_totalXp(totalXp), style: small)),
              ListenableBuilder(
                listenable: _controller,
                builder: (BuildContext context, Widget? child) => Text(
                  l.settings_heroNameCounter(
                    _controller.text.trim().runes.length,
                    maxHeroNameLength,
                  ),
                  style: small.copyWith(
                    color: hasError ? p.destructive : p.textFaint,
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
