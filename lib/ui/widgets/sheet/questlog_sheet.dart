import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../common/app_icon.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import 'confirm_destructive.dart';

/// Opens a bottom sheet and resolves to the value the sheet closed with (or
/// `null` when it was dismissed).
///
/// ## How the sheet pieces fit together
///
/// [showQuestlogSheet] only provides the route: modal scrim, the slide from
/// the bottom (a plain fade of at most [Motion.reducedFade] when the device
/// asks for reduced motion), keyboard-inset handling and the maximum height.
/// What the user sees is a [QuestlogSheet], which [builder] returns. Form
/// sheets are therefore small widgets that own their form state and build the
/// scaffold themselves, so they can feed it the current dirtiness and
/// validity:
///
/// ```dart
/// final Quest? saved = await showQuestlogSheet<Quest>(
///   context,
///   builder: (BuildContext context) => const QuestSheet(),
/// );
///
/// class _QuestSheetState extends ConsumerState<QuestSheet> {
///   @override
///   Widget build(BuildContext context) {
///     final AppLocalizations l10n = AppLocalizations.of(context);
///     return QuestlogSheet(
///       title: l10n.quest_createTitle,
///       primaryLabel: l10n.quest_createAction,
///       isDirty: _nameController.text.isNotEmpty,
///       onPrimary: () async {
///         if (!_validate()) return; // stays open, input is kept
///         final Quest quest = await ref.read(questServiceProvider).create(...);
///         if (context.mounted) QuestlogSheet.close(context, quest);
///       },
///       child: Column(children: <Widget>[/* fields */]),
///     );
///   }
/// }
/// ```
///
/// Dismissal rules (requirements 5.8, 9.8, 18.5): when [QuestlogSheet.isDirty]
/// is true, every dismissal path (Cancel, drag down, tapping the scrim, the
/// system back gesture) asks the "discard changes?" question first; a clean
/// sheet closes straight away. [QuestlogSheet.close] (used after a successful
/// save) never asks.
Future<T?> showQuestlogSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool useRootNavigator = true,
}) {
  final NavigatorState navigator = Navigator.of(
    context,
    rootNavigator: useRootNavigator,
  );
  return navigator.push<T>(
    _SheetRoute<T>(
      builder: builder,
      barrierColor: context.palette.scrim,
      barrierLabel: AppLocalizations.of(context).common_close,
      reducedMotion: MediaQuery.disableAnimationsOf(context),
      capturedThemes: InheritedTheme.capture(
        from: context,
        to: navigator.context,
      ),
    ),
  );
}

/// The visual sheet: grabber, header ("Zrušit" at the left, the centred
/// display title), a scrollable body and one brass primary button pinned at
/// the bottom (so it stays visible above the keyboard).
///
/// Put it at the root of the widget returned from the [showQuestlogSheet]
/// builder. It is rebuilt by its owner, so the owner must call `setState`
/// whenever [isDirty], [primaryEnabled] or [onPrimary] change meaning (form
/// sheets do that anyway to show validation).
class QuestlogSheet extends StatefulWidget {
  const QuestlogSheet({
    super.key,
    required this.title,
    this.primaryLabel,
    required this.child,
    this.primaryIcon,
    this.onPrimary,
    this.primaryEnabled = true,
    this.isDirty = false,
  });

  /// Already localized, shown centred in the display face.
  final String title;

  /// Already localized label of the brass button ("Vyvěsit quest", "Uložit").
  /// Null for a sheet that has no primary button (a sheet of choices).
  final String? primaryLabel;

  /// Optional [IconAsset] shown before the label of the brass button (the
  /// artboards give the create sheets one).
  final String? primaryIcon;

  /// Scrollable body. Keep it free of its own vertical scrollables.
  final Widget child;

  /// Runs when the primary button is pressed. While the returned future runs
  /// the button is disabled, so a slow save cannot be submitted twice. The
  /// callback decides whether the sheet closes by calling
  /// [QuestlogSheet.close] on success; on a validation or service error it
  /// simply returns and the sheet stays open with the input intact.
  final Future<void> Function()? onPrimary;

  /// Greys out the primary button when false (or when [onPrimary] is null).
  final bool primaryEnabled;

  /// True when the sheet holds input that would be lost; every dismissal then
  /// asks for confirmation first.
  final bool isDirty;

  /// Closes the sheet that contains [context] with [result], without asking
  /// for confirmation. Call it after the save succeeded.
  static void close<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop<T>(result);
  }

  /// Dismisses the sheet as if the user had pressed "Zrušit": asks for
  /// confirmation when the sheet is dirty, closes straight away otherwise.
  static Future<bool> requestClose(BuildContext context) {
    return Navigator.of(context).maybePop();
  }

  @override
  State<QuestlogSheet> createState() => _QuestlogSheetState();
}

class _QuestlogSheetState extends State<QuestlogSheet> {
  /// Fraction of the sheet height after which a drag releases into dismissal.
  static const double _dismissFraction = 0.3;

  /// Fling speed in logical pixels per second that dismisses regardless of
  /// distance.
  static const double _dismissVelocity = 700;

  bool _busy = false;
  bool _confirming = false;
  bool _dragging = false;
  double _dragOffset = 0;

  Future<void> _submit() async {
    final Future<void> Function()? action = widget.onPrimary;
    if (action == null || _busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmDiscard() async {
    if (_confirming) return;
    _confirming = true;
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool discard = await confirmDestructive(
      context,
      title: l10n.sheet_discardTitle,
      body: l10n.sheet_discardBody,
      confirmLabel: l10n.common_discard,
      cancelLabel: l10n.sheet_keepEditing,
    );
    _confirming = false;
    if (discard && mounted) Navigator.of(context).pop();
  }

  void _dragStart(DragStartDetails details) {
    setState(() => _dragging = true);
  }

  void _dragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset = math.max(0, _dragOffset + details.delta.dy);
    });
  }

  void _dragEnd(DragEndDetails details) {
    final double height = context.size?.height ?? 0;
    final bool release =
        _dragOffset > height * _dismissFraction ||
        (details.primaryVelocity ?? 0) > _dismissVelocity;
    setState(() {
      _dragging = false;
      // A dirty sheet stays put while the confirmation is shown.
      if (!release || widget.isDirty) _dragOffset = 0;
    });
    if (release) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette palette = context.palette;
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MediaQueryData media = MediaQuery.of(context);
    final bool reduced = media.disableAnimations;
    final bool canSubmit =
        widget.onPrimary != null && widget.primaryEnabled && !_busy;

    final Widget sheet = Material(
      color: palette.sheet,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.sheet)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragStart: _dragStart,
            onVerticalDragUpdate: _dragUpdate,
            onVerticalDragEnd: _dragEnd,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const _Grabber(),
                _Header(
                  title: widget.title,
                  cancelLabel: l10n.common_cancel,
                  onCancel: () => QuestlogSheet.requestClose(context),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(
                Space.s20,
                Space.s8,
                Space.s20,
                Space.s16,
              ),
              child: widget.child,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              Space.s20,
              Space.s4,
              Space.s20,
              Space.s12 + media.padding.bottom,
            ),
            child: widget.primaryLabel == null
                ? null
                : _PrimaryButton(
                    label: widget.primaryLabel!,
                    icon: widget.primaryIcon,
                    onPressed: canSubmit ? _submit : null,
                  ),
          ),
        ],
      ),
    );

    return PopScope<Object?>(
      canPop: !widget.isDirty,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) _confirmDiscard();
      },
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(end: _dragOffset),
          duration: _dragging || reduced ? Motion.none : Motion.panel,
          curve: Motion.curve,
          builder: (BuildContext context, double offset, Widget? child) =>
              Transform.translate(offset: Offset(0, offset), child: child),
          child: sheet,
        ),
      ),
    );
  }
}

class _Grabber extends StatelessWidget {
  const _Grabber();

  @override
  Widget build(BuildContext context) {
    // A pure drag handle: dismissing through assistive technology is covered
    // by the "Zrušit" button, so the grabber stays out of the semantics tree.
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.only(top: Space.s8, bottom: Space.s12),
        child: Center(
          child: Container(
            width: Metrics.grabberWidth,
            height: Metrics.grabberHeight,
            decoration: BoxDecoration(
              color: context.palette.textFaint,
              borderRadius: BorderRadius.circular(Radii.pill),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.cancelLabel,
    required this.onCancel,
  });

  final String title;
  final String cancelLabel;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette palette = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.s12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            // Reserves the width of the cancel button on both sides, so the
            // title is centred on the sheet rather than in the leftover space.
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Metrics.touchTarget + Space.s32,
              ),
              child: Semantics(
                header: true,
                namesRoute: true,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.displayText.headlineMedium,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size(
                    Metrics.touchTarget,
                    Metrics.touchTarget,
                  ),
                  foregroundColor: palette.text,
                  padding: const EdgeInsets.symmetric(horizontal: Space.s8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Radii.control),
                  ),
                ),
                onPressed: onCancel,
                child: Text(cancelLabel, style: context.bodyText.titleMedium),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final String? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette palette = context.palette;
    return FilledButton(
      onPressed: onPressed,
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll<Size>(
          Size(double.infinity, Metrics.touchTarget + Space.s8),
        ),
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.control),
          ),
        ),
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) => states.contains(WidgetState.disabled)
              ? palette.brass.withValues(alpha: 0.35)
              : palette.brass,
        ),
        foregroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) => states.contains(WidgetState.disabled)
              ? palette.inkOnBrass.withValues(alpha: 0.6)
              : palette.inkOnBrass,
        ),
        textStyle: WidgetStatePropertyAll<TextStyle?>(
          context.bodyText.titleMedium,
        ),
      ),
      child: icon == null
          ? Text(label, textAlign: TextAlign.center)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AppIcon(icon!, size: 18),
                const SizedBox(width: Space.s8),
                Flexible(child: Text(label, textAlign: TextAlign.center)),
              ],
            ),
    );
  }
}

/// Route behind [showQuestlogSheet]: scrim, slide-up (fade under reduced
/// motion), keyboard inset and a height cap that keeps the status bar clear.
class _SheetRoute<T> extends PopupRoute<T> {
  _SheetRoute({
    required this.builder,
    required this.barrierColor,
    required this.barrierLabel,
    required this.reducedMotion,
    required this.capturedThemes,
  });

  final WidgetBuilder builder;
  final bool reducedMotion;
  final CapturedThemes capturedThemes;

  @override
  final Color barrierColor;

  @override
  final String barrierLabel;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration =>
      reducedMotion ? Motion.reducedFade : Motion.panel;

  @override
  Duration get reverseTransitionDuration => transitionDuration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final MediaQueryData media = MediaQuery.of(context);
    return capturedThemes.wrap(
      Padding(
        padding: EdgeInsets.only(
          top: media.padding.top + Space.s24,
          bottom: media.viewInsets.bottom,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: MediaQuery.removeViewInsets(
            context: context,
            removeBottom: true,
            child: Builder(builder: builder),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (reducedMotion) {
      return FadeTransition(opacity: animation, child: child);
    }
    return SlideTransition(
      position: animation
          .drive(CurveTween(curve: Motion.curve))
          .drive(Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)),
      child: child,
    );
  }
}
