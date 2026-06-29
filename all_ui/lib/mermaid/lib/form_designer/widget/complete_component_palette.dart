import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/field_config.dart';
import '../model/form_theme.dart';
import '../states/form_field_provider.dart';
import '../utils/template_library.dart';

class CompleteComponentPalette extends ConsumerWidget {
  final FormTheme theme;
  final int phase;

  const CompleteComponentPalette({
    Key? key,
    required this.theme,
    required this.phase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 280,
      color: theme.colors.surface,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'COMPONENTS - PHASE ${phase + 1}',
            style: TextStyle(
              color: theme.colors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          if (phase == 0) ..._buildPhase1Components(ref),
          if (phase == 1) ..._buildPhase2Components(ref),
          if (phase == 2) ..._buildPhase3Components(ref),
          if (phase == 3) ..._buildPhase4Components(ref),
        ],
      ),
    );
  }

  List<Widget> _buildPhase1Components(WidgetRef ref) {
    return [
      _ComponentCategory(theme: theme, title: 'Basic Inputs'),
      _ComponentButton(
        theme: theme,
        label: 'Text Input',
        icon: Icons.text_fields,
        onTap: () => _addField(ref, 'text', 'Text Input'),
      ),
      _ComponentButton(
        theme: theme,
        label: 'Email',
        icon: Icons.email,
        onTap: () => _addField(ref, 'email', 'Email'),
      ),
      _ComponentButton(
        theme: theme,
        label: 'Number',
        icon: Icons.numbers,
        onTap: () => _addField(ref, 'number', 'Number'),
      ),
      _ComponentButton(
        theme: theme,
        label: 'Password',
        icon: Icons.lock,
        onTap: () => _addField(ref, 'password', 'Password'),
      ),
      _ComponentButton(
        theme: theme,
        label: 'Textarea',
        icon: Icons.notes,
        onTap: () => _addField(ref, 'textarea', 'Message'),
      ),
      const SizedBox(height: 16),
      _ComponentCategory(theme: theme, title: 'Selection'),
      _ComponentButton(
        theme: theme,
        label: 'Dropdown',
        icon: Icons.arrow_drop_down_circle,
        onTap: () => _addField(ref, 'select', 'Select Option'),
      ),
      _ComponentButton(
        theme: theme,
        label: 'Checkbox',
        icon: Icons.check_box,
        onTap: () => _addField(ref, 'checkbox', 'Agree to terms'),
      ),
      _ComponentButton(
        theme: theme,
        label: 'Radio Group',
        icon: Icons.radio_button_checked,
        onTap: () => _addField(ref, 'radio', 'Choose one'),
      ),
      _ComponentButton(
        theme: theme,
        label: 'Switch',
        icon: Icons.toggle_on,
        onTap: () => _addField(ref, 'switch', 'Enable feature'),
      ),
    ];
  }

  List<Widget> _buildPhase2Components(WidgetRef ref) {
    return [
      _ComponentCategory(theme: theme, title: 'Layout Components'),
      _ComponentButton(
        theme: theme,
        label: 'Container',
        icon: Icons.crop_square,
        onTap: () => _addField(ref, 'container', null, isContainer: true),
      ),
      _ComponentButton(
        theme: theme,
        label: 'Row',
        icon: Icons.view_week,
        onTap: () => _addField(ref, 'row', null, isContainer: true),
      ),
      _ComponentButton(
        theme: theme,
        label: 'Column',
        icon: Icons.view_agenda,
        onTap: () => _addField(ref, 'column', null, isContainer: true),
      ),
      _ComponentButton(
        theme: theme,
        label: 'Grid',
        icon: Icons.grid_on,
        onTap: () => _addField(ref, 'grid', null, isContainer: true),
      ),
      _ComponentButton(
        theme: theme,
        label: 'Card',
        icon: Icons.credit_card,
        onTap: () => _addField(ref, 'card', null, isContainer: true),
      ),
      const SizedBox(height: 16),
      _ComponentCategory(theme: theme, title: 'Advanced Layouts'),
      _ComponentButton(
        theme: theme,
        label: 'Tabs',
        icon: Icons.tab,
        onTap: () => _addField(ref, 'tabs', null, isContainer: true),
      ),
      _ComponentButton(
        theme: theme,
        label: 'Stepper',
        icon: Icons.stairs,
        onTap: () => _addField(ref, 'stepper', null, isContainer: true),
      ),
      _ComponentButton(
        theme: theme,
        label: 'Accordion',
        icon: Icons.expand_more,
        onTap: () => _addField(ref, 'accordion', null, isContainer: true),
      ),
    ];
  }

  List<Widget> _buildPhase3Components(WidgetRef ref) {
    return [
      _ComponentCategory(theme: theme, title: 'Advanced Fields'),
      _ComponentButton(
        theme: theme,
        label: 'Date Picker',
        icon: Icons.calendar_today,
        onTap: () => _addField(ref, 'date', 'Select Date'),
      ),
      _ComponentButton(
        theme: theme,
        label: 'Time Picker',
        icon: Icons.access_time,
        onTap: () => _addField(ref, 'time', 'Select Time'),
      ),
      _ComponentButton(
        theme: theme,
        label: 'Date Range',
        icon: Icons.date_range,
        onTap: () => _addField(ref, 'daterange', 'Select Range'),
      ),
      _ComponentButton(
        theme: theme,
        label: 'File Upload',
        icon: Icons.upload_file,
        onTap: () => _addField(ref, 'file', 'Upload File'),
      ),
      _ComponentButton(
        theme: theme,
        label: 'Image Upload',
        icon: Icons.image,
        onTap: () => _addField(ref, 'image', 'Upload Image'),
      ),
      _ComponentButton(
        theme: theme,
        label: 'Signature',
        icon: Icons.gesture,
        onTap: () => _addField(ref, 'signature', 'Sign Here'),
      ),
      _ComponentButton(
        theme: theme,
        label: 'Rating',
        icon: Icons.star,
        onTap: () => _addField(ref, 'rating', 'Rate this'),
      ),
      _ComponentButton(
        theme: theme,
        label: 'Slider',
        icon: Icons.tune,
        onTap: () => _addField(ref, 'slider', 'Adjust value'),
      ),
      _ComponentButton(
        theme: theme,
        label: 'Color Picker',
        icon: Icons.color_lens,
        onTap: () => _addField(ref, 'color', 'Pick Color'),
      ),
      const SizedBox(height: 16),
      _ComponentCategory(theme: theme, title: 'Special Fields'),
      _ComponentButton(
        theme: theme,
        label: 'Rich Text Editor',
        icon: Icons.text_format,
        onTap: () => _addField(ref, 'richtext', 'Content'),
      ),
      _ComponentButton(
        theme: theme,
        label: 'Location',
        icon: Icons.location_on,
        onTap: () => _addField(ref, 'location', 'Enter Location'),
      ),
      _ComponentButton(
        theme: theme,
        label: 'QR Code',
        icon: Icons.qr_code,
        onTap: () => _addField(ref, 'qrcode', 'Scan QR'),
      ),
    ];
  }

  List<Widget> _buildPhase4Components(WidgetRef ref) {
    return [
      _ComponentCategory(theme: theme, title: 'Integration Components'),
      _ComponentButton(
        theme: theme,
        label: 'API Field',
        icon: Icons.api,
        onTap: () {},
      ),
      _ComponentButton(
        theme: theme,
        label: 'Webhook Trigger',
        icon: Icons.webhook,
        onTap: () {},
      ),
      _ComponentButton(
        theme: theme,
        label: 'Payment Gateway',
        icon: Icons.payment,
        onTap: () {},
      ),
      _ComponentButton(
        theme: theme,
        label: 'reCAPTCHA',
        icon: Icons.verified_user,
        onTap: () {},
      ),
      const SizedBox(height: 16),
      _ComponentCategory(theme: theme, title: 'Templates'),
      _ComponentButton(
        theme: theme,
        label: 'Contact Form',
        icon: Icons.contact_mail,
        onTap: () => _loadTemplate(ref, 'contact_form'),
      ),
      _ComponentButton(
        theme: theme,
        label: 'Registration',
        icon: Icons.person_add,
        onTap: () => _loadTemplate(ref, 'registration'),
      ),
      _ComponentButton(
        theme: theme,
        label: 'Survey',
        icon: Icons.poll,
        onTap: () {},
      ),
      _ComponentButton(
        theme: theme,
        label: 'Feedback',
        icon: Icons.feedback,
        onTap: () {},
      ),
    ];
  }

  void _addField(
    WidgetRef ref,
    String type,
    String? label, {
    bool isContainer = false,
  }) {
    final field = FieldConfig(
      id: 'field_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      name: isContainer
          ? null
          : '${type}_${DateTime.now().millisecondsSinceEpoch}',
      label: label,
      hint: label != null ? 'Enter $label' : null,
      children: isContainer ? [] : null,
    );
    ref.read(formFieldsProvider.notifier).addField(field);
  }

  void _loadTemplate(WidgetRef ref, String templateId) {
    final template = TemplateLibrary.predefined.firstWhere(
      (t) => t.id == templateId,
    );
    ref.read(formFieldsProvider.notifier).clear();
    for (final field in template.fields) {
      ref.read(formFieldsProvider.notifier).addField(field);
    }
  }
}

class _ComponentCategory extends StatelessWidget {
  final FormTheme theme;
  final String title;

  const _ComponentCategory({required this.theme, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: theme.colors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _ComponentButton extends StatelessWidget {
  final FormTheme theme;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ComponentButton({
    required this.theme,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: theme.colors.inputBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: theme.colors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: theme.colors.text, fontSize: 13),
              ),
            ),
            Icon(Icons.add, size: 16, color: theme.colors.textSecondary),
          ],
        ),
      ),
    );
  }
}
