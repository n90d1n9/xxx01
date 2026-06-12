import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ky_builder_shared/ky_builder_shared.dart';

import '../models/component.dart';
import '../models/component_preset.dart';
import '../models/grid_setting.dart';
import '../models/layout_health_summary.dart';
import '../models/layout_config.dart';
import '../models/layout_rule_preset.dart';
import '../models/layout_rules_conversion_preview.dart';
import '../models/layout_state.dart';
import '../models/template.dart';
import '../provider/canvas_viewport_provider.dart';
import '../provider/component_preset_provider.dart';
import '../provider/layout_state_provider.dart';
import '../provider/template_provider.dart';
import '../services/layout_canvas_view_action_service.dart';
import '../services/layout_selection_geometry_action_service.dart';
import 'layout_rules_editor.dart';

Future<void> showSaveTemplateDialog(BuildContext context, WidgetRef ref) async {
  final currentLayout = ref.read(layoutStateProvider);
  final defaultName =
      currentLayout.name == 'New Layout' ? '' : currentLayout.name;
  final nameController = TextEditingController(text: defaultName);
  final descriptionController = TextEditingController(
    text: '${currentLayout.components.length} components',
  );
  String? nameError;

  await showDialog<void>(
    context: context,
    builder:
        (dialogContext) => StatefulBuilder(
          builder: (builderContext, setState) {
            Future<void> submit() async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                setState(() => nameError = 'Template name is required');
                return;
              }

              await _saveTemplate(
                dialogContext,
                context,
                ref,
                name,
                descriptionController.text,
              );
            }

            return AlertDialog(
              title: const Text('Save Template'),
              content: SizedBox(
                width: 380,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _TemplateSaveSummary(
                      componentCount: currentLayout.components.length,
                      gridSize: currentLayout.gridSettings.gridSize,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Template name',
                        errorText: nameError,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (_) {
                        if (nameError != null) {
                          setState(() => nameError = null);
                        }
                      },
                      onSubmitted: (_) => submit(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => submit(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(onPressed: submit, child: const Text('Save')),
              ],
            );
          },
        ),
  );

  nameController.dispose();
  descriptionController.dispose();
}

Future<void> showLoadTemplateDialog(BuildContext context, WidgetRef ref) async {
  final repository = ref.read(templateRepositoryProvider);
  final loadedTemplates = await ref.read(templateProvider.future);

  if (!context.mounted) return;

  final searchController = TextEditingController();
  var templates = loadedTemplates;
  var query = '';

  await showDialog<void>(
    context: context,
    builder:
        (dialogContext) => StatefulBuilder(
          builder: (context, setState) {
            final filteredTemplates = templates
                .where((template) => _matchesTemplate(template, query))
                .toList(growable: false);

            Future<void> deleteTemplate(Template template) async {
              final shouldDelete = await _confirmDeleteTemplate(
                dialogContext,
                template,
              );

              if (shouldDelete != true) return;

              await repository.deleteTemplate(template.id);
              ref.invalidate(templateProvider);

              if (!dialogContext.mounted) return;
              setState(() {
                templates =
                    templates.where((item) => item.id != template.id).toList();
              });
            }

            return AlertDialog(
              title: const Text('Load Template'),
              content: SizedBox(
                width: 420,
                height: 420,
                child: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      enabled: templates.isNotEmpty,
                      decoration: InputDecoration(
                        hintText: 'Search templates',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon:
                            query.isEmpty
                                ? null
                                : IconButton(
                                  icon: const Icon(Icons.close),
                                  tooltip: 'Clear search',
                                  onPressed: () {
                                    searchController.clear();
                                    setState(() => query = '');
                                  },
                                ),
                        isDense: true,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() => query = value.trim());
                      },
                    ),
                    if (templates.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _TemplateListSummary(
                        visibleCount: filteredTemplates.length,
                        totalCount: templates.length,
                      ),
                    ],
                    const SizedBox(height: 12),
                    Expanded(
                      child:
                          templates.isEmpty
                              ? const Center(
                                child: Text('No saved templates yet'),
                              )
                              : filteredTemplates.isEmpty
                              ? const _EmptyTemplateSearch()
                              : ListView.separated(
                                itemCount: filteredTemplates.length,
                                separatorBuilder:
                                    (context, index) =>
                                        const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final template = filteredTemplates[index];
                                  return ListTile(
                                    leading: const Icon(
                                      Icons.dashboard_customize,
                                    ),
                                    title: Text(template.name),
                                    subtitle: Text(_templateSubtitle(template)),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      tooltip: 'Delete template',
                                      onPressed: () => deleteTemplate(template),
                                    ),
                                    onTap: () {
                                      ref
                                          .read(layoutStateProvider.notifier)
                                          .loadTemplate(template);
                                      Navigator.pop(dialogContext);
                                    },
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        ),
  );

  searchController.dispose();
}

Future<void> showCanvasZoomDialog(BuildContext context, WidgetRef ref) async {
  final currentZoom = ref.read(canvasViewportProvider).zoom;
  final controller = TextEditingController(
    text: (currentZoom * 100).round().toString(),
  );
  final minZoomPercent = (CanvasViewportNotifier.minZoom * 100).round();
  final maxZoomPercent = (CanvasViewportNotifier.maxZoom * 100).round();
  String? zoomError;

  await showDialog<void>(
    context: context,
    builder:
        (dialogContext) => StatefulBuilder(
          builder: (context, setState) {
            void submit() {
              final zoomPercent = int.tryParse(controller.text.trim());
              if (zoomPercent == null) {
                setState(() => zoomError = 'Enter a zoom percentage');
                return;
              }

              if (zoomPercent < minZoomPercent ||
                  zoomPercent > maxZoomPercent) {
                setState(
                  () => zoomError = 'Use $minZoomPercent% to $maxZoomPercent%',
                );
                return;
              }

              final nextZoom = zoomPercent / 100;
              Navigator.pop(dialogContext);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!context.mounted) return;
                layoutCanvasViewActionService.setZoom(
                  context,
                  ref,
                  nextZoom,
                  rememberRecent: true,
                );
              });
            }

            return AlertDialog(
              title: const Text('Custom Zoom'),
              content: SizedBox(
                width: 280,
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Zoom',
                    suffixText: '%',
                    helperText: '$minZoomPercent% - $maxZoomPercent%',
                    errorText: zoomError,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) {
                    if (zoomError != null) {
                      setState(() => zoomError = null);
                    }
                  },
                  onSubmitted: (_) => submit(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(onPressed: submit, child: const Text('Apply')),
              ],
            );
          },
        ),
  );

  controller.dispose();
}

Future<void> showCanvasSizeDialog(BuildContext context, WidgetRef ref) async {
  final currentSize = ref.read(layoutStateProvider).config.canvasSize;
  final widthController = TextEditingController(
    text: currentSize.width.round().toString(),
  );
  final heightController = TextEditingController(
    text: currentSize.height.round().toString(),
  );
  final minWidth = LayoutConfig.minCanvasWidth.round();
  final minHeight = LayoutConfig.minCanvasHeight.round();
  String? widthError;
  String? heightError;

  await showDialog<void>(
    context: context,
    builder:
        (dialogContext) => StatefulBuilder(
          builder: (context, setState) {
            void submit() {
              final width = int.tryParse(widthController.text.trim());
              final height = int.tryParse(heightController.text.trim());
              var hasError = false;

              if (width == null) {
                widthError = 'Enter width';
                hasError = true;
              } else if (width < minWidth) {
                widthError = 'Minimum $minWidth px';
                hasError = true;
              } else {
                widthError = null;
              }

              if (height == null) {
                heightError = 'Enter height';
                hasError = true;
              } else if (height < minHeight) {
                heightError = 'Minimum $minHeight px';
                hasError = true;
              } else {
                heightError = null;
              }

              if (hasError) {
                setState(() {});
                return;
              }

              ref
                  .read(layoutStateProvider.notifier)
                  .updateCanvasSize(
                    Size(width!.toDouble(), height!.toDouble()),
                  );
              Navigator.pop(dialogContext);
            }

            void clearErrors() {
              if (widthError != null || heightError != null) {
                setState(() {
                  widthError = null;
                  heightError = null;
                });
              }
            }

            return AlertDialog(
              title: const Text('Custom Canvas Size'),
              content: SizedBox(
                width: 360,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widthController,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: 'Width',
                          suffixText: 'px',
                          helperText: 'Min $minWidth',
                          errorText: widthError,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (_) => clearErrors(),
                        onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: heightController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: 'Height',
                          suffixText: 'px',
                          helperText: 'Min $minHeight',
                          errorText: heightError,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (_) => clearErrors(),
                        onSubmitted: (_) => submit(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(onPressed: submit, child: const Text('Apply')),
              ],
            );
          },
        ),
  );

  widthController.dispose();
  heightController.dispose();
}

Future<void> showSelectionSpacingDialog(
  BuildContext context,
  WidgetRef ref,
  ComponentDistribution direction,
) async {
  final selectedComponents = ref.read(layoutStateProvider).selectedComponents;
  final currentGap = _selectionGap(selectedComponents, direction);
  final controller = TextEditingController(text: currentGap.round().toString());
  final directionLabel = _spacingDirectionLabel(direction);
  String? gapError;

  await showDialog<void>(
    context: context,
    builder:
        (dialogContext) => StatefulBuilder(
          builder: (context, setState) {
            void submit() {
              final gap = double.tryParse(controller.text.trim());
              if (gap == null) {
                setState(() => gapError = 'Enter a spacing value');
                return;
              }

              if (gap < 0) {
                setState(() => gapError = 'Spacing cannot be negative');
                return;
              }

              layoutSelectionGeometryActionService.spaceSelection(
                dialogContext,
                ref,
                direction,
                gap,
              );
              Navigator.pop(dialogContext);
            }

            return AlertDialog(
              title: Text('$directionLabel Spacing'),
              content: SizedBox(
                width: 280,
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Gap',
                    suffixText: 'px',
                    helperText: '${selectedComponents.length} selected',
                    errorText: gapError,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) {
                    if (gapError != null) {
                      setState(() => gapError = null);
                    }
                  },
                  onSubmitted: (_) => submit(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(onPressed: submit, child: const Text('Apply')),
              ],
            );
          },
        ),
  );

  controller.dispose();
}

Future<void> showSaveComponentPresetDialog(
  BuildContext context,
  WidgetRef ref,
  ComponentData component,
) async {
  await _showSaveComponentPresetDialog(context, ref, [component]);
}

Future<void> showSaveSelectionPresetDialog(
  BuildContext context,
  WidgetRef ref,
  List<ComponentData> components,
) async {
  if (components.isEmpty) return;
  await _showSaveComponentPresetDialog(context, ref, components);
}

Future<void> _showSaveComponentPresetDialog(
  BuildContext context,
  WidgetRef ref,
  List<ComponentData> components,
) async {
  final defaultName = _componentPresetNameFor(components);
  final nameController = TextEditingController(text: defaultName);
  final descriptionController = TextEditingController(
    text: _componentPresetDescriptionFor(components),
  );
  String? nameError;

  await showDialog<void>(
    context: context,
    builder:
        (dialogContext) => StatefulBuilder(
          builder: (builderContext, setState) {
            Future<void> submit() async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                setState(() => nameError = 'Preset name is required');
                return;
              }

              await _saveComponentPreset(
                dialogContext,
                context,
                ref,
                components,
                name,
                descriptionController.text,
              );
            }

            return AlertDialog(
              title: const Text('Save Component Preset'),
              content: SizedBox(
                width: 380,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ComponentPresetSaveSummary(components: components),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Preset name',
                        errorText: nameError,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (_) {
                        if (nameError != null) {
                          setState(() => nameError = null);
                        }
                      },
                      onSubmitted: (_) => submit(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => submit(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(onPressed: submit, child: const Text('Save')),
              ],
            );
          },
        ),
  );

  nameController.dispose();
  descriptionController.dispose();
}

Future<void> showGridSettingsDialog(BuildContext context, WidgetRef ref) async {
  final scaffoldContext = context;
  final initialLayout = ref.read(layoutStateProvider);
  final initialSettings = initialLayout.gridSettings;
  final initialConfig = initialLayout.config;
  final lockedVisibleComponentCount =
      initialLayout.components
          .where((component) => component.isVisible && component.isLocked)
          .length;
  final hiddenComponentCount =
      initialLayout.components
          .where((component) => !component.isVisible)
          .length;
  final visibleMovableComponentCount =
      initialLayout.components
          .where((component) => component.isVisible && !component.isLocked)
          .length;
  final componentScope = LayoutRulesComponentScope(
    editableCount: visibleMovableComponentCount,
    lockedCount: lockedVisibleComponentCount,
    hiddenCount: hiddenComponentCount,
  );
  var draftSettings = initialSettings;
  var draftConfig = initialConfig;
  var applyStrategy = LayoutRulesApplyStrategy.preserve;

  await showDialog<void>(
    context: context,
    builder:
        (dialogContext) => StatefulBuilder(
          builder: (context, setState) {
            void updateDraft(GridSettings settings) {
              setState(() => draftSettings = settings);
            }

            void updateConfig(LayoutConfig config) {
              setState(() => draftConfig = config);
            }

            void applyPreset(LayoutRulePreset preset) {
              setState(() {
                draftSettings = preset.applyToGridSettings(draftSettings);
                draftConfig = preset.applyToConfig(draftConfig);
              });
            }

            void repositionComponentsInsideCanvas() {
              final notifier = ref.read(layoutStateProvider.notifier);
              final beforeApplyIndex =
                  ref.read(layoutStateProvider).currentVersionIndex;
              notifier.moveVisibleComponentsInsideCanvas();
              Navigator.pop(dialogContext);
              final didCommit =
                  ref.read(layoutStateProvider).currentVersionIndex >
                  beforeApplyIndex;
              _showLayoutHealthRepairSnackBar(
                scaffoldContext,
                notifier,
                didCommit: didCommit,
              );
            }

            void selectLayoutHealthComponents({
              required Iterable<String> ids,
              required String singularLabel,
              required String pluralLabel,
            }) {
              final selectedIds = ids.toSet();
              if (selectedIds.isEmpty) return;

              ref
                  .read(layoutStateProvider.notifier)
                  .selectComponents(selectedIds);
              Navigator.pop(dialogContext);
              _showLayoutHealthSelectionSnackBar(
                scaffoldContext,
                selectedCount: selectedIds.length,
                singularLabel: singularLabel,
                pluralLabel: pluralLabel,
              );
            }

            final effectiveApplyStrategy = layoutRulesEffectiveApplyStrategy(
              strategy: applyStrategy,
              componentScope: componentScope,
            );
            final hadRuleChanges = layoutRulesDraftHasChanges(
              initialSettings: initialSettings,
              draftSettings: draftSettings,
              initialConfig: initialConfig,
              draftConfig: draftConfig,
            );
            final canApply = layoutRulesDraftCanApply(
              initialSettings: initialSettings,
              draftSettings: draftSettings,
              initialConfig: initialConfig,
              draftConfig: draftConfig,
              applyStrategy: effectiveApplyStrategy,
            );
            final syncedDraftConfig = draftConfig.copyWith(
              gridSize: draftSettings.gridSize,
              snapToGrid: draftSettings.snapToGrid,
              showGrid: draftSettings.enabled,
            );
            final strategyOptions = _layoutRulesStrategyOptions(
              effectiveApplyStrategy,
              syncedDraftConfig.layoutMechanism,
            );
            final conversionPreview = _layoutRulesConversionPreviewForStrategy(
              components: initialLayout.components,
              gridSettings: draftSettings,
              config: syncedDraftConfig,
              options: strategyOptions,
            );
            final healthSummary = layoutHealthSummaryFor(
              components: initialLayout.components,
              gridSettings: draftSettings,
              config: syncedDraftConfig,
            );
            final applyButtonLabel = _layoutRulesApplyButtonLabel(
              canApply: canApply,
              hasRuleChanges: hadRuleChanges,
              strategy: effectiveApplyStrategy,
            );

            return AlertDialog(
              title: const Text('Layout Rules'),
              content: SizedBox(
                width: 420,
                child: LayoutRulesDraftEditor(
                  settings: draftSettings,
                  config: draftConfig,
                  baselineSettings: initialSettings,
                  baselineConfig: initialConfig,
                  visibleComponentCount: visibleMovableComponentCount,
                  componentScope: componentScope,
                  conversionPreview: conversionPreview,
                  healthSummary: healthSummary,
                  applyStrategy: effectiveApplyStrategy,
                  onSettingsChanged: updateDraft,
                  onConfigChanged: updateConfig,
                  onPresetSelected: applyPreset,
                  onApplyStrategyChanged:
                      (strategy) => setState(() => applyStrategy = strategy),
                  onRepositionInsideCanvas: repositionComponentsInsideCanvas,
                  onSelectOffCanvas:
                      () => selectLayoutHealthComponents(
                        ids: healthSummary.offCanvasComponentIds,
                        singularLabel: 'off-canvas component',
                        pluralLabel: 'off-canvas components',
                      ),
                  onSelectExpandableOffCanvas:
                      () => selectLayoutHealthComponents(
                        ids: healthSummary.expandableOffCanvasComponentIds,
                        singularLabel: 'right/bottom overflow component',
                        pluralLabel: 'right/bottom overflow components',
                      ),
                  onSelectRepositionOffCanvas:
                      () => selectLayoutHealthComponents(
                        ids: healthSummary.repositionOffCanvasComponentIds,
                        singularLabel: 'left/top outside component',
                        pluralLabel: 'left/top outside components',
                      ),
                  onSelectOffRulePositions:
                      () => selectLayoutHealthComponents(
                        ids: healthSummary.offRulePositionComponentIds,
                        singularLabel: 'component with off-rule position',
                        pluralLabel: 'components with off-rule positions',
                      ),
                  onSelectOffRuleSizes:
                      () => selectLayoutHealthComponents(
                        ids: healthSummary.offRuleSizeComponentIds,
                        singularLabel: 'component with off-rule size',
                        pluralLabel: 'components with off-rule sizes',
                      ),
                  onSelectAutoGridConflicts:
                      () => selectLayoutHealthComponents(
                        ids: healthSummary.autoGridConflictComponentIds,
                        singularLabel: 'Auto Grid conflict component',
                        pluralLabel: 'Auto Grid conflict components',
                      ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      () => setState(() {
                        draftSettings = const GridSettings();
                        draftConfig = const LayoutConfig();
                        applyStrategy = LayoutRulesApplyStrategy.preserve;
                      }),
                  child: const Text('Defaults'),
                ),
                TextButton(
                  onPressed:
                      canApply
                          ? () => setState(() {
                            draftSettings = initialSettings;
                            draftConfig = initialConfig;
                            applyStrategy = LayoutRulesApplyStrategy.preserve;
                          })
                          : null,
                  child: const Text('Revert'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  key: const ValueKey('layout-rules-apply-button'),
                  icon: Icon(
                    _layoutRulesApplyButtonIcon(effectiveApplyStrategy),
                    size: 18,
                  ),
                  onPressed:
                      canApply
                          ? () {
                            final notifier = ref.read(
                              layoutStateProvider.notifier,
                            );
                            final beforeApplyIndex =
                                ref
                                    .read(layoutStateProvider)
                                    .currentVersionIndex;
                            final config = draftConfig.copyWith(
                              gridSize: draftSettings.gridSize,
                              snapToGrid: draftSettings.snapToGrid,
                              showGrid: draftSettings.enabled,
                            );
                            notifier.applyLayoutRules(
                              gridSettings: draftSettings,
                              config: config,
                              snapVisiblePositions:
                                  strategyOptions.snapVisiblePositions,
                              snapVisibleSizes:
                                  strategyOptions.snapVisibleSizes,
                              resolveAutoGridConflicts:
                                  strategyOptions.resolveAutoGridConflicts,
                            );
                            Navigator.pop(dialogContext);
                            final didCommit =
                                ref
                                    .read(layoutStateProvider)
                                    .currentVersionIndex >
                                beforeApplyIndex;
                            _showLayoutRulesAppliedSnackBar(
                              scaffoldContext,
                              notifier,
                              strategy: effectiveApplyStrategy,
                              preview: conversionPreview,
                              hadRuleChanges: hadRuleChanges,
                              didCommit: didCommit,
                            );
                          }
                          : null,
                  label: Text(applyButtonLabel),
                ),
              ],
            );
          },
        ),
  );
}

void _showLayoutHealthSelectionSnackBar(
  BuildContext context, {
  required int selectedCount,
  required String singularLabel,
  required String pluralLabel,
}) {
  if (!context.mounted) return;

  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  final label =
      selectedCount == 1
          ? 'Selected 1 $singularLabel'
          : 'Selected $selectedCount $pluralLabel';
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(label)));
}

void _showLayoutHealthRepairSnackBar(
  BuildContext context,
  LayoutStateNotifier notifier, {
  required bool didCommit,
}) {
  if (!context.mounted) return;

  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          didCommit
              ? 'Moved editable components inside the canvas'
              : 'No editable off-canvas components to move',
        ),
        action:
            didCommit
                ? SnackBarAction(label: 'Undo', onPressed: notifier.undo)
                : null,
      ),
    );
}

void _showLayoutRulesAppliedSnackBar(
  BuildContext context,
  LayoutStateNotifier notifier, {
  required LayoutRulesApplyStrategy strategy,
  required LayoutRulesConversionPreview? preview,
  required bool hadRuleChanges,
  required bool didCommit,
}) {
  if (!context.mounted) return;

  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          _layoutRulesAppliedSnackBarMessage(
            strategy: strategy,
            preview: preview,
            hadRuleChanges: hadRuleChanges,
            didCommit: didCommit,
          ),
        ),
        action:
            didCommit
                ? SnackBarAction(label: 'Undo', onPressed: notifier.undo)
                : null,
      ),
    );
}

String _layoutRulesApplyButtonLabel({
  required bool canApply,
  required bool hasRuleChanges,
  required LayoutRulesApplyStrategy strategy,
}) {
  if (!canApply) return 'Apply';

  return switch (strategy) {
    LayoutRulesApplyStrategy.preserve => 'Update Rules',
    LayoutRulesApplyStrategy.snapVisible =>
      hasRuleChanges ? 'Update + Snap' : 'Snap Visible',
    LayoutRulesApplyStrategy.convertVisible =>
      hasRuleChanges ? 'Update + Convert' : 'Convert Visible',
  };
}

IconData _layoutRulesApplyButtonIcon(LayoutRulesApplyStrategy strategy) {
  return switch (strategy) {
    LayoutRulesApplyStrategy.preserve => Icons.rule_folder_outlined,
    LayoutRulesApplyStrategy.snapVisible => Icons.grid_goldenratio,
    LayoutRulesApplyStrategy.convertVisible => Icons.auto_fix_high_outlined,
  };
}

String _layoutRulesAppliedSnackBarMessage({
  required LayoutRulesApplyStrategy strategy,
  required LayoutRulesConversionPreview? preview,
  required bool hadRuleChanges,
  required bool didCommit,
}) {
  if (!didCommit) return 'Layout rules already matched';

  final details = <String>[
    if (hadRuleChanges) 'rules updated',
    ..._layoutRulesGeometrySummary(strategy, preview),
  ];

  if (details.isEmpty) return 'Layout rules applied';
  return 'Layout rules applied - ${details.join(', ')}';
}

List<String> _layoutRulesGeometrySummary(
  LayoutRulesApplyStrategy strategy,
  LayoutRulesConversionPreview? preview,
) {
  if (strategy == LayoutRulesApplyStrategy.preserve || preview == null) {
    return const <String>[];
  }

  return [
    if (preview.moveCount > 0) _countLabel(preview.moveCount, 'moved'),
    if (preview.resizeCount > 0) _countLabel(preview.resizeCount, 'resized'),
    if (preview.autoGridConflictCount > 0)
      _countLabel(
        preview.autoGridConflictCount,
        'conflict resolved',
        'conflicts resolved',
      ),
    if (!preview.hasGeometryChanges) 'geometry already aligned',
  ];
}

String _countLabel(int count, String singular, [String? plural]) {
  return '$count ${count == 1 ? singular : plural ?? singular}';
}

class _LayoutRulesStrategyOptions {
  final bool snapVisiblePositions;
  final bool snapVisibleSizes;
  final bool resolveAutoGridConflicts;

  const _LayoutRulesStrategyOptions({
    this.snapVisiblePositions = false,
    this.snapVisibleSizes = false,
    this.resolveAutoGridConflicts = false,
  });

  bool get affectsComponents =>
      snapVisiblePositions || snapVisibleSizes || resolveAutoGridConflicts;
}

_LayoutRulesStrategyOptions _layoutRulesStrategyOptions(
  LayoutRulesApplyStrategy strategy,
  LayoutMechanism mechanism,
) {
  switch (strategy) {
    case LayoutRulesApplyStrategy.preserve:
      return const _LayoutRulesStrategyOptions();
    case LayoutRulesApplyStrategy.snapVisible:
      return const _LayoutRulesStrategyOptions(snapVisiblePositions: true);
    case LayoutRulesApplyStrategy.convertVisible:
      return _LayoutRulesStrategyOptions(
        snapVisiblePositions: true,
        snapVisibleSizes: mechanism != LayoutMechanism.freeform,
        resolveAutoGridConflicts: mechanism == LayoutMechanism.autoGrid,
      );
  }
}

LayoutRulesConversionPreview? _layoutRulesConversionPreviewForStrategy({
  required List<ComponentData> components,
  required GridSettings gridSettings,
  required LayoutConfig config,
  required _LayoutRulesStrategyOptions options,
}) {
  if (!options.affectsComponents) return null;

  return layoutRulesConversionPreviewFor(
    components: components,
    gridSettings: gridSettings,
    config: config,
    snapPositions: options.snapVisiblePositions,
    snapSizes: options.snapVisibleSizes,
    resolveAutoGridConflicts: options.resolveAutoGridConflicts,
  );
}

Future<void> showExportLayoutDialog(BuildContext context, WidgetRef ref) async {
  final layoutState = ref.read(layoutStateProvider);
  final encoder = const JsonEncoder.withIndent('  ');
  final packageJson = encoder.convert(layoutState.toExportPackage());
  final rawJson = encoder.convert(layoutState.toJson());
  var exportPackage = true;

  await showDialog<void>(
    context: context,
    builder:
        (dialogContext) => StatefulBuilder(
          builder: (context, setState) {
            final json = exportPackage ? packageJson : rawJson;
            final title =
                exportPackage
                    ? 'Export package JSON'
                    : 'Export raw layout JSON';

            return AlertDialog(
              title: const Text('Export Layout JSON'),
              content: SizedBox(
                width: 600,
                height: 460,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KyBuilderSegmentedSelector<bool>(
                      options: const [
                        KyBuilderSegmentOption(
                          value: true,
                          icon: Icons.inventory_2_outlined,
                          label: 'Package',
                        ),
                        KyBuilderSegmentOption(
                          value: false,
                          icon: Icons.data_object_outlined,
                          label: 'Raw layout',
                        ),
                      ],
                      selectedValue: exportPackage,
                      onChanged:
                          (value) => setState(() => exportPackage = value),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ExportSummaryChip(
                          icon: _layoutMechanismIcon(
                            layoutState.config.layoutMechanism,
                          ),
                          label: layoutState.config.layoutMechanism.label,
                        ),
                        _ExportSummaryChip(
                          icon: Icons.layers_outlined,
                          label: '${layoutState.components.length} components',
                        ),
                        _ExportSummaryChip(
                          icon: Icons.devices_outlined,
                          label:
                              '${_responsiveOverrideCount(layoutState)} overrides',
                        ),
                        _ExportSummaryChip(
                          icon: Icons.anchor_outlined,
                          label:
                              '${_constrainedComponentCount(layoutState)} constrained',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(title, style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 6),
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color:
                              Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(12),
                          child: SelectableText(
                            json,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontFamily: 'monospace'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Close'),
                ),
                FilledButton.icon(
                  icon: const Icon(Icons.content_copy),
                  label: const Text('Copy JSON'),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: json));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('$title copied')));
                  },
                ),
              ],
            );
          },
        ),
  );
}

class _ExportSummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ExportSummaryChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

int _responsiveOverrideCount(LayoutState layoutState) {
  return layoutState.components.fold<int>(
    0,
    (count, component) => count + component.responsiveProperties.length,
  );
}

int _constrainedComponentCount(LayoutState layoutState) {
  return layoutState.components
      .where((component) => component.constraints.hasCustomRules)
      .length;
}

IconData _layoutMechanismIcon(LayoutMechanism mechanism) {
  switch (mechanism) {
    case LayoutMechanism.freeform:
      return Icons.open_with;
    case LayoutMechanism.grid:
      return Icons.grid_4x4;
    case LayoutMechanism.tabularColumns:
      return Icons.view_column_outlined;
    case LayoutMechanism.autoGrid:
      return Icons.dashboard_customize_outlined;
  }
}

Future<void> showImportLayoutDialog(BuildContext context, WidgetRef ref) async {
  final controller = TextEditingController();
  String? errorText;
  Map<String, dynamic>? importPayload;
  LayoutImportPreview? importPreview;

  await showDialog<void>(
    context: context,
    builder:
        (dialogContext) => StatefulBuilder(
          builder: (context, setState) {
            void updatePreview(String value) {
              final raw = value.trim();
              if (raw.isEmpty) {
                setState(() {
                  errorText = null;
                  importPayload = null;
                  importPreview = null;
                });
                return;
              }

              try {
                final decoded = jsonDecode(raw);
                if (decoded is! Map) {
                  throw const FormatException('JSON root must be an object.');
                }

                final payload = Map<String, dynamic>.from(decoded);
                final preview = LayoutImportPreview.fromJson(payload);
                setState(() {
                  errorText = null;
                  importPayload = payload;
                  importPreview = preview;
                });
              } catch (error) {
                setState(() {
                  errorText = 'Invalid layout JSON: $error';
                  importPayload = null;
                  importPreview = null;
                });
              }
            }

            Future<void> pasteFromClipboard() async {
              final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
              controller.text = clipboard?.text ?? '';
              updatePreview(controller.text);
            }

            void importLayout() {
              final payload = importPayload;
              if (payload == null) {
                updatePreview(controller.text);
                return;
              }

              ref.read(layoutStateProvider.notifier).importLayout(payload);
              Navigator.pop(dialogContext);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Layout JSON imported')),
              );
            }

            return AlertDialog(
              title: const Text('Import Layout JSON'),
              content: SizedBox(
                width: 600,
                height: 480,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        expands: true,
                        maxLines: null,
                        minLines: null,
                        onChanged: updatePreview,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: const InputDecoration(
                          alignLabelWithHint: true,
                          labelText: 'Paste layout JSON',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ImportPreviewCard(
                      preview: importPreview,
                      errorText: errorText,
                      isEmpty: controller.text.trim().isEmpty,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.content_paste),
                  label: const Text('Paste'),
                  onPressed: pasteFromClipboard,
                ),
                FilledButton.icon(
                  icon: const Icon(Icons.file_upload_outlined),
                  label: const Text('Import'),
                  onPressed: importPayload == null ? null : importLayout,
                ),
              ],
            );
          },
        ),
  );

  controller.dispose();
}

class _ImportPreviewCard extends StatelessWidget {
  final LayoutImportPreview? preview;
  final String? errorText;
  final bool isEmpty;

  const _ImportPreviewCard({
    required this.preview,
    required this.errorText,
    required this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final preview = this.preview;

    if (isEmpty) {
      return _ImportStatusCard(
        icon: Icons.info_outline,
        title: 'Waiting for JSON',
        message: 'Paste a raw layout or export package.',
        color: colorScheme.primary,
      );
    }

    final errorText = this.errorText;
    if (errorText != null) {
      return _ImportStatusCard(
        icon: Icons.error_outline,
        title: 'Invalid import',
        message: errorText,
        color: colorScheme.error,
      );
    }

    if (preview == null) return const SizedBox.shrink();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _layoutMechanismIcon(preview.layoutMechanism),
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    preview.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ExportSummaryChip(
                  icon:
                      preview.isPackage
                          ? Icons.inventory_2_outlined
                          : Icons.data_object_outlined,
                  label: preview.formatLabel,
                ),
                _ExportSummaryChip(
                  icon: _layoutMechanismIcon(preview.layoutMechanism),
                  label: preview.layoutMechanism.label,
                ),
                _ExportSummaryChip(
                  icon: Icons.aspect_ratio,
                  label: preview.canvasLabel,
                ),
                _ExportSummaryChip(
                  icon: Icons.layers_outlined,
                  label: preview.componentLabel,
                ),
                if (preview.lockedCount > 0)
                  _ExportSummaryChip(
                    icon: Icons.lock,
                    label: '${preview.lockedCount} locked',
                  ),
                if (preview.responsiveOverrideCount > 0)
                  _ExportSummaryChip(
                    icon: Icons.devices_outlined,
                    label: '${preview.responsiveOverrideCount} overrides',
                  ),
                if (preview.constrainedCount > 0)
                  _ExportSummaryChip(
                    icon: Icons.anchor_outlined,
                    label: '${preview.constrainedCount} constrained',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportStatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;

  const _ImportStatusCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _saveTemplate(
  BuildContext dialogContext,
  BuildContext scaffoldContext,
  WidgetRef ref,
  String rawName,
  String rawDescription,
) async {
  final name = rawName.trim();
  if (name.isEmpty) return;

  final currentLayout = ref.read(layoutStateProvider);
  final description = rawDescription.trim();
  final template = Template(
    id: DateTime.now().microsecondsSinceEpoch.toString(),
    name: name,
    description:
        description.isEmpty
            ? '${currentLayout.components.length} components'
            : description,
    layout: currentLayout.toJson(),
  );

  await ref.read(templateRepositoryProvider).saveTemplate(template);
  ref.invalidate(templateProvider);
  ref.read(layoutStateProvider.notifier).saveVersion(name);

  if (!dialogContext.mounted) return;
  Navigator.pop(dialogContext);

  if (!scaffoldContext.mounted) return;
  ScaffoldMessenger.of(
    scaffoldContext,
  ).showSnackBar(SnackBar(content: Text('Template "$name" saved')));
}

Future<void> _saveComponentPreset(
  BuildContext dialogContext,
  BuildContext scaffoldContext,
  WidgetRef ref,
  List<ComponentData> components,
  String rawName,
  String rawDescription,
) async {
  final name = rawName.trim();
  if (name.isEmpty) return;

  final description = rawDescription.trim();
  final presetComponents = _componentPresetComponents(components);
  final preset = ComponentPreset(
    id: DateTime.now().microsecondsSinceEpoch.toString(),
    name: name,
    description:
        description.isEmpty
            ? _componentPresetDescriptionFor(components)
            : description,
    components: presetComponents,
  );

  await ref.read(componentPresetRepositoryProvider).savePreset(preset);
  ref.invalidate(componentPresetProvider);

  if (!dialogContext.mounted) return;
  Navigator.pop(dialogContext);

  if (!scaffoldContext.mounted) return;
  ScaffoldMessenger.of(
    scaffoldContext,
  ).showSnackBar(SnackBar(content: Text('Preset "$name" saved')));
}

class _TemplateSaveSummary extends StatelessWidget {
  final int componentCount;
  final double gridSize;

  const _TemplateSaveSummary({
    required this.componentCount,
    required this.gridSize,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.dashboard_customize_outlined,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$componentCount components - ${gridSize.round()}px grid',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComponentPresetSaveSummary extends StatelessWidget {
  final List<ComponentData> components;

  const _ComponentPresetSaveSummary({required this.components});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isBlock = components.length > 1;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              isBlock ? Icons.view_quilt_outlined : components.first.type.icon,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _componentPresetDescriptionFor(components),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateListSummary extends StatelessWidget {
  final int visibleCount;
  final int totalCount;

  const _TemplateListSummary({
    required this.visibleCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          Icons.dashboard_customize_outlined,
          size: 16,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '$visibleCount of $totalCount templates',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyTemplateSearch extends StatelessWidget {
  const _EmptyTemplateSearch();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_outlined, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            'No templates found',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool?> _confirmDeleteTemplate(
  BuildContext context,
  Template template,
) async {
  return showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Delete Template'),
          content: Text('Delete "${template.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        ),
  );
}

String _templateSubtitle(Template template) {
  final description = template.description;
  final updated = template.updatedAt;
  final date =
      '${updated.year}-${updated.month.toString().padLeft(2, '0')}-${updated.day.toString().padLeft(2, '0')}';

  if (description == null || description.isEmpty) return 'Updated $date';
  return '$description - Updated $date';
}

bool _matchesTemplate(Template template, String query) {
  final normalizedQuery = query.toLowerCase();
  if (normalizedQuery.isEmpty) return true;

  final componentCount =
      template.layout['components'] is List
          ? (template.layout['components'] as List).length
          : 0;
  final searchableValues = [
    template.name,
    template.description ?? '',
    _templateSubtitle(template),
    '$componentCount components',
  ];

  return searchableValues.any(
    (value) => value.toLowerCase().contains(normalizedQuery),
  );
}

String _componentPresetName(ComponentData component) {
  final attributes = component.properties.attributes;
  final customName =
      attributes['name'] ?? attributes['label'] ?? attributes['text'];

  if (customName is String && customName.trim().isNotEmpty) {
    return customName.trim();
  }

  return component.type.label;
}

String _componentPresetNameFor(List<ComponentData> components) {
  if (components.length == 1) return _componentPresetName(components.first);
  return '${components.length} Component Block';
}

String _componentPresetDescription(ComponentData component) {
  final size =
      '${component.size.width.round()}x${component.size.height.round()}';
  final overrideCount = component.responsiveProperties.length;
  final overrideLabel =
      overrideCount == 0
          ? ''
          : ' - $overrideCount responsive override${overrideCount == 1 ? '' : 's'}';

  return '${component.type.label} - $size$overrideLabel';
}

String _componentPresetDescriptionFor(List<ComponentData> components) {
  if (components.length == 1) {
    return _componentPresetDescription(components.first);
  }

  final bounds = _componentPresetBounds(components);
  final typeCount =
      components.map((component) => component.type).toSet().length;
  final typeLabel = typeCount == 1 ? components.first.type.label : 'Mixed';

  return '${components.length} components - $typeLabel - ${bounds.width.round()}x${bounds.height.round()}';
}

List<ComponentData> _componentPresetComponents(List<ComponentData> components) {
  final bounds = _componentPresetBounds(components);

  return [
    for (final component in components)
      component.copyWith(
        position: component.position - bounds.topLeft,
        responsiveProperties: component.responsiveProperties.map((key, value) {
          final position = value.position;

          return MapEntry(
            key,
            value.copyWith(
              position: position == null ? null : position - bounds.topLeft,
            ),
          );
        }),
        isLocked: false,
        isVisible: true,
      ),
  ];
}

Rect _componentPresetBounds(List<ComponentData> components) {
  final first = components.first;
  var left = first.position.dx;
  var top = first.position.dy;
  var right = first.position.dx + first.size.width;
  var bottom = first.position.dy + first.size.height;

  for (final component in components.skip(1)) {
    left = left < component.position.dx ? left : component.position.dx;
    top = top < component.position.dy ? top : component.position.dy;
    right =
        right > component.position.dx + component.size.width
            ? right
            : component.position.dx + component.size.width;
    bottom =
        bottom > component.position.dy + component.size.height
            ? bottom
            : component.position.dy + component.size.height;
  }

  return Rect.fromLTRB(left, top, right, bottom);
}

double _selectionGap(
  List<ComponentData> components,
  ComponentDistribution direction,
) {
  if (components.length < 2) return 0;

  final sortedComponents = [...components]..sort((a, b) {
    final aValue =
        direction == ComponentDistribution.horizontal
            ? a.position.dx
            : a.position.dy;
    final bValue =
        direction == ComponentDistribution.horizontal
            ? b.position.dx
            : b.position.dy;
    return aValue.compareTo(bValue);
  });
  var totalGap = 0.0;

  for (var index = 0; index < sortedComponents.length - 1; index++) {
    final current = sortedComponents[index];
    final next = sortedComponents[index + 1];
    final currentEnd =
        direction == ComponentDistribution.horizontal
            ? current.position.dx + current.size.width
            : current.position.dy + current.size.height;
    final nextStart =
        direction == ComponentDistribution.horizontal
            ? next.position.dx
            : next.position.dy;
    totalGap += nextStart - currentEnd;
  }

  return (totalGap / (sortedComponents.length - 1))
      .clamp(0.0, double.infinity)
      .toDouble();
}

String _spacingDirectionLabel(ComponentDistribution direction) {
  switch (direction) {
    case ComponentDistribution.horizontal:
      return 'Horizontal';
    case ComponentDistribution.vertical:
      return 'Vertical';
  }
}
