import '../model/field_config.dart';
import '../model/form_theme.dart';

class CodeGenerator {
  static String generateFlutterCode(List<FieldConfig> fields, FormTheme theme) {
    final buffer = StringBuffer();

    buffer.writeln('import \'package:flutter/material.dart\';');
    buffer.writeln('');
    buffer.writeln('class GeneratedForm extends StatefulWidget {');
    buffer.writeln('  const GeneratedForm({Key? key}) : super(key: key);');
    buffer.writeln('');
    buffer.writeln('  @override');
    buffer.writeln(
      '  State<GeneratedForm> createState() => _GeneratedFormState();',
    );
    buffer.writeln('}');
    buffer.writeln('');
    buffer.writeln('class _GeneratedFormState extends State<GeneratedForm> {');
    buffer.writeln('  final _formKey = GlobalKey<FormState>();');

    // Controllers
    for (final field in fields) {
      if (!field.isContainer) {
        buffer.writeln(
          '  final _${field.name}Controller = TextEditingController();',
        );
      }
    }

    buffer.writeln('');
    buffer.writeln('  @override');
    buffer.writeln('  Widget build(BuildContext context) {');
    buffer.writeln('    return Form(');
    buffer.writeln('      key: _formKey,');
    buffer.writeln('      child: Column(');
    buffer.writeln('        children: [');

    for (final field in fields) {
      buffer.writeln('          ${_generateFieldWidget(field, theme)},');
    }

    buffer.writeln('          ElevatedButton(');
    buffer.writeln('            onPressed: () {');
    buffer.writeln('              if (_formKey.currentState!.validate()) {');
    buffer.writeln('                // Handle form submission');
    buffer.writeln('              }');
    buffer.writeln('            },');
    buffer.writeln('            child: const Text(\'Submit\'),');
    buffer.writeln('          ),');
    buffer.writeln('        ],');
    buffer.writeln('      ),');
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln('}');

    return buffer.toString();
  }

  static String _generateFieldWidget(FieldConfig field, FormTheme theme) {
    switch (field.type) {
      case 'text':
      case 'email':
      case 'password':
        return '''TextFormField(
            controller: _${field.name}Controller,
            decoration: InputDecoration(
              labelText: '${field.label}',
              hintText: '${field.hint ?? ''}',
            ),
            validator: (value) {
              if (${field.required} && (value == null || value.isEmpty)) {
                return 'This field is required';
              }
              return null;
            },
          )''';
      case 'number':
        return '''TextFormField(
            controller: _${field.name}Controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '${field.label}',
            ),
          )''';
      default:
        return 'Container()';
    }
  }

  static String generateReactCode(List<FieldConfig> fields) {
    final buffer = StringBuffer();

    buffer.writeln('import React, { useState } from \'react\';');
    buffer.writeln('');
    buffer.writeln('export default function GeneratedForm() {');
    buffer.writeln('  const [formData, setFormData] = useState({');

    for (final field in fields.where((f) => !f.isContainer)) {
      buffer.writeln('    ${field.name}: \'\',');
    }

    buffer.writeln('  });');
    buffer.writeln('');
    buffer.writeln('  const handleSubmit = (e) => {');
    buffer.writeln('    e.preventDefault();');
    buffer.writeln('    console.log(formData);');
    buffer.writeln('  };');
    buffer.writeln('');
    buffer.writeln('  return (');
    buffer.writeln('    <form onSubmit={handleSubmit}>');

    for (final field in fields) {
      buffer.writeln(_generateReactField(field));
    }

    buffer.writeln('      <button type="submit">Submit</button>');
    buffer.writeln('    </form>');
    buffer.writeln('  );');
    buffer.writeln('}');

    return buffer.toString();
  }

  static String _generateReactField(FieldConfig field) {
    return '''
      <div>
        <label>${field.label}</label>
        <input
          type="${field.type}"
          name="${field.name}"
          ${field.required ? 'required' : ''}
          onChange={(e) => setFormData({...formData, ${field.name}: e.target.value})}
        />
      </div>''';
  }

  static String generateHTML(List<FieldConfig> fields) {
    final buffer = StringBuffer();

    buffer.writeln('<!DOCTYPE html>');
    buffer.writeln('<html>');
    buffer.writeln('<head>');
    buffer.writeln('  <meta charset="UTF-8">');
    buffer.writeln('  <title>Generated Form</title>');
    buffer.writeln('</head>');
    buffer.writeln('<body>');
    buffer.writeln('  <form id="generatedForm">');

    for (final field in fields) {
      buffer.writeln(_generateHTMLField(field));
    }

    buffer.writeln('    <button type="submit">Submit</button>');
    buffer.writeln('  </form>');
    buffer.writeln('</body>');
    buffer.writeln('</html>');

    return buffer.toString();
  }

  static String _generateHTMLField(FieldConfig field) {
    return '''
    <div>
      <label for="${field.name}">${field.label}</label>
      <input 
        type="${field.type}" 
        id="${field.name}" 
        name="${field.name}"
        ${field.required ? 'required' : ''}
      />
    </div>''';
  }
}
