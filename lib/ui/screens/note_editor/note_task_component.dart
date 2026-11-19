import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';

import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common/app_icon.dart';

/// Builds the checklist rows of the Note_Editor: a round check in the Questlog
/// style with a 44 point hit area and a screen-reader label, in place of the
/// package's plain Material checkbox. The view model comes from the package.
class NoteTaskComponentBuilder implements ComponentBuilder {
  NoteTaskComponentBuilder(Editor editor, {required this.toggleLabel})
    : _package = TaskComponentBuilder(editor);

  /// Already localized semantic label of the check ("Toggle done").
  final String toggleLabel;
  final TaskComponentBuilder _package;

  @override
  SingleColumnLayoutComponentViewModel? createViewModel(Document document, DocumentNode node) =>
      _package.createViewModel(document, node);

  @override
  Widget? createComponent(
    SingleColumnDocumentComponentContext componentContext,
    SingleColumnLayoutComponentViewModel componentViewModel,
  ) {
    if (componentViewModel is! TaskComponentViewModel) return null;
    return NoteTaskComponent(
      key: componentContext.componentKey,
      viewModel: componentViewModel,
      toggleLabel: toggleLabel,
    );
  }
}

class NoteTaskComponent extends StatefulWidget {
  const NoteTaskComponent({super.key, required this.viewModel, required this.toggleLabel});

  final TaskComponentViewModel viewModel;
  final String toggleLabel;

  @override
  State<NoteTaskComponent> createState() => _NoteTaskComponentState();
}

class _NoteTaskComponentState extends State<NoteTaskComponent>
    with ProxyDocumentComponent<NoteTaskComponent>, ProxyTextComposable {
  final GlobalKey _textKey = GlobalKey();

  @override
  GlobalKey<State<StatefulWidget>> get childDocumentComponentKey => _textKey;

  @override
  TextComposable get childTextComposable => childDocumentComponentKey.currentState as TextComposable;

  /// A completed task is struck through.
  TextStyle _style(Set<Attribution> attributions) {
    final TextStyle style = widget.viewModel.textStyleBuilder(attributions);
    if (!widget.viewModel.isComplete) return style;
    return style.copyWith(
      color: context.palette.textFaint,
      decoration: style.decoration == null
          ? TextDecoration.lineThrough
          : TextDecoration.combine(<TextDecoration>[TextDecoration.lineThrough, style.decoration!]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    final TaskComponentViewModel model = widget.viewModel;
    final void Function(bool)? setComplete = model.setComplete;
    return Directionality(
      textDirection: model.textDirection,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(width: model.indentCalculator(model.textStyleBuilder(<Attribution>{}), model.indent)),
          Semantics(
            button: true,
            checked: model.isComplete,
            label: widget.toggleLabel,
            excludeSemantics: true,
            onTap: setComplete == null ? null : () => setComplete(!model.isComplete),
            child: InkWell(
              key: const ValueKey<String>('task-check'),
              onTap: setComplete == null ? null : () => setComplete(!model.isComplete),
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: Metrics.touchTarget,
                height: Metrics.touchTarget,
                child: Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: model.isComplete ? p.brass : p.field.withValues(alpha: 0),
                      border: Border.all(
                        color: model.isComplete ? p.brass : p.textFaint,
                        width: Space.s2,
                      ),
                    ),
                    child: SizedBox(
                      width: Metrics.iconSmall + Space.s4,
                      height: Metrics.iconSmall + Space.s4,
                      child: model.isComplete
                          ? Center(
                              child: AppIcon(IconAsset.tick, size: Metrics.iconSmall - Space.s4, color: p.inkOnBrass),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              // Centres the first line against the 44 point check.
              padding: const EdgeInsets.only(top: Space.s2),
              child: TextComponent(
                key: _textKey,
                text: model.text,
                textDirection: model.textDirection,
                textAlign: model.textAlignment,
                maxLines: model.maxLines,
                overflow: model.overflow,
                textStyleBuilder: _style,
                inlineWidgetBuilders: model.inlineWidgetBuilders,
                textSelection: model.selection,
                selectionColor: model.selectionColor,
                highlightWhenEmpty: model.highlightWhenEmpty,
                underlines: model.createUnderlines(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
