import 'package:flutter/material.dart';

import '../model/field_config.dart';
import '../model/form_theme.dart';

class AdvancedLayoutRenderer {
  static Widget renderTabsLayout(
    BuildContext context,
    FieldConfig field,
    FormTheme theme,
  ) {
    final tabs = field.tabs ?? [];

    return DefaultTabController(
      length: tabs.length,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.colors.surface,
              border: Border(bottom: BorderSide(color: theme.colors.border)),
            ),
            child: TabBar(
              labelColor: theme.colors.primary,
              unselectedLabelColor: theme.colors.textSecondary,
              indicatorColor: theme.colors.primary,
              tabs: tabs.map((tab) {
                return Tab(
                  icon: tab.icon != null ? Icon(tab.icon, size: 20) : null,
                  text: tab.label,
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: tabs.map((tab) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: tab.fields.map((f) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: theme.colors.border),
                        ),
                        child: Text(
                          f.label ?? f.name ?? 'Field',
                          style: TextStyle(color: theme.colors.text),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  static Widget renderStepperLayout(
    BuildContext context,
    FieldConfig field,
    FormTheme theme,
  ) {
    final steps = field.steps ?? [];
    int currentStep = 0;

    return StatefulBuilder(
      builder: (context, setState) {
        return Stepper(
          currentStep: currentStep,
          onStepTapped: (step) => setState(() => currentStep = step),
          onStepContinue: currentStep < steps.length - 1
              ? () => setState(() => currentStep++)
              : null,
          onStepCancel: currentStep > 0
              ? () => setState(() => currentStep--)
              : null,
          steps: steps.map((step) {
            return Step(
              title: Text(
                step.title,
                style: TextStyle(color: theme.colors.text),
              ),
              subtitle: step.subtitle != null
                  ? Text(
                      step.subtitle!,
                      style: TextStyle(color: theme.colors.textSecondary),
                    )
                  : null,
              content: Column(
                children: step.fields.map((f) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.colors.border),
                    ),
                    child: Text(
                      f.label ?? f.name ?? 'Field',
                      style: TextStyle(color: theme.colors.text),
                    ),
                  );
                }).toList(),
              ),
              isActive: currentStep >= steps.indexOf(step),
            );
          }).toList(),
        );
      },
    );
  }

  static Widget renderAccordionLayout(
    BuildContext context,
    FieldConfig field,
    FormTheme theme,
  ) {
    final panels = field.panels ?? [];

    return StatefulBuilder(
      builder: (context, setState) {
        return SingleChildScrollView(
          child: ExpansionPanelList(
            expandedHeaderPadding: EdgeInsets.zero,
            elevation: 0,
            expansionCallback: (index, isExpanded) {
              if (panels[index].canToggle) {
                setState(() {
                  // Toggle panel
                });
              }
            },
            children: panels.map((panel) {
              return ExpansionPanel(
                headerBuilder: (context, isExpanded) {
                  return ListTile(
                    title: Text(
                      panel.header,
                      style: TextStyle(
                        color: theme.colors.text,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: panel.description != null
                        ? Text(
                            panel.description!,
                            style: TextStyle(color: theme.colors.textSecondary),
                          )
                        : null,
                  );
                },
                body: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: panel.fields.map((f) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colors.inputBackground,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: theme.colors.border),
                        ),
                        child: Text(
                          f.label ?? f.name ?? 'Field',
                          style: TextStyle(color: theme.colors.text),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                isExpanded: panel.expanded,
                canTapOnHeader: panel.canToggle,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
