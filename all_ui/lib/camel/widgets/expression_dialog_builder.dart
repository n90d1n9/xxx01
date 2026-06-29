import 'package:flutter/material.dart';

import '../schema/expression.dart';

class ExpressionBuilderDialog extends StatefulWidget {
  final String? initialExpression;
  final ExpressionLanguage? initialLanguage;

  const ExpressionBuilderDialog({
    super.key,
    this.initialExpression,
    this.initialLanguage,
  });

  @override
  State<ExpressionBuilderDialog> createState() =>
      _ExpressionBuilderDialogState();
}

class _ExpressionBuilderDialogState extends State<ExpressionBuilderDialog> {
  late TextEditingController _expressionController;
  late ExpressionLanguage _selectedLanguage;
  String? _validationError;
  dynamic _testResult;

  @override
  void initState() {
    super.initState();
    _expressionController = TextEditingController(
      text: widget.initialExpression ?? '',
    );
    _selectedLanguage = widget.initialLanguage ?? ExpressionLanguage.simple;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Row(
              children: [
                Expanded(flex: 2, child: _buildExpressionEditor()),
                Container(
                  width: 300,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                  child: _buildHelpPanel(),
                ),
              ],
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.code),
          const SizedBox(width: 12),
          const Text(
            'Expression Builder',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildExpressionEditor() {
    return Column(
      children: [
        _buildToolbar(),
        Expanded(child: _buildEditor()),
        _buildTestPanel(),
      ],
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          const Text('Language:'),
          const SizedBox(width: 12),
          DropdownButton<ExpressionLanguage>(
            value: _selectedLanguage,
            items:
                ExpressionLanguage.values.map((lang) {
                  return DropdownMenuItem(
                    value: lang,
                    child: Row(
                      children: [
                        Icon(_getLanguageIcon(lang), size: 16),
                        const SizedBox(width: 8),
                        Text(lang.displayName),
                      ],
                    ),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() => _selectedLanguage = value!);
            },
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.format_align_left),
            onPressed: _formatExpression,
            tooltip: 'Format',
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showLanguageHelp,
            tooltip: 'Language Help',
          ),
        ],
      ),
    );
  }

  Widget _buildEditor() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Expression',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              if (_validationError != null)
                Chip(
                  avatar: const Icon(Icons.error, size: 16),
                  label: const Text('Invalid'),
                  backgroundColor: Colors.red.withOpacity(0.2),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TextField(
              controller: _expressionController,
              maxLines: null,
              expands: true,
              style: const TextStyle(fontFamily: 'monospace'),
              decoration: InputDecoration(
                hintText: _getPlaceholder(),
                border: const OutlineInputBorder(),
                filled: true,
                errorText: _validationError,
              ),
              onChanged: (_) => _validateExpression(),
            ),
          ),
          const SizedBox(height: 8),
          _buildQuickInsertBar(),
        ],
      ),
    );
  }

  Widget _buildQuickInsertBar() {
    final items = _getQuickInsertItems();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          items.map((item) {
            return ActionChip(
              avatar: Icon(item.icon, size: 16),
              label: Text(item.label),
              onPressed: () => _insertText(item.value),
            );
          }).toList(),
    );
  }

  Widget _buildTestPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Test Expression',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _testExpression,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Test'),
              ),
            ],
          ),
          if (_testResult != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Result:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _testResult.toString(),
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHelpPanel() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Variables', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ..._buildVariablesList(),
        const SizedBox(height: 24),
        Text('Functions', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ..._buildFunctionsList(),
        const SizedBox(height: 24),
        Text('Examples', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ..._buildExamplesList(),
      ],
    );
  }

  List<Widget> _buildVariablesList() {
    final variables = _getAvailableVariables();

    return variables.map((variable) {
      return Card(
        child: ListTile(
          dense: true,
          leading: const Icon(Icons.label, size: 16),
          title: Text(variable.name),
          subtitle: Text(
            variable.description,
            style: const TextStyle(fontSize: 11),
          ),
          onTap: () => _insertText(variable.syntax),
        ),
      );
    }).toList();
  }

  List<Widget> _buildFunctionsList() {
    final functions = _getAvailableFunctions();

    return functions.map((function) {
      return Card(
        child: ListTile(
          dense: true,
          leading: const Icon(Icons.functions, size: 16),
          title: Text(function.name),
          subtitle: Text(
            function.description,
            style: const TextStyle(fontSize: 11),
          ),
          onTap: () => _insertText(function.syntax),
        ),
      );
    }).toList();
  }

  List<Widget> _buildExamplesList() {
    final examples = _getExamples();

    return examples.map((example) {
      return Card(
        child: ListTile(
          dense: true,
          title: Text(example.title),
          subtitle: Text(
            example.expression,
            style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
          ),
          onTap: () {
            _expressionController.text = example.expression;
            _validateExpression();
          },
        ),
      );
    }).toList();
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _validationError == null ? _saveExpression : null,
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  String _getPlaceholder() {
    switch (_selectedLanguage) {
      case ExpressionLanguage.simple:
        return r'${body.userId} == 123';
      case ExpressionLanguage.jsonpath:
        return r'$.user.id';
      case ExpressionLanguage.xpath:
        return r'/order/customer/@id';
      case ExpressionLanguage.groovy:
        return 'request.body.user.id == 123';
      case ExpressionLanguage.jq:
        return '.user.id';
      case ExpressionLanguage.constant:
        return 'Fixed value';
    }
  }

  IconData _getLanguageIcon(ExpressionLanguage language) {
    switch (language) {
      case ExpressionLanguage.simple:
        return Icons.text_fields;
      case ExpressionLanguage.jsonpath:
        return Icons.data_object;
      case ExpressionLanguage.xpath:
        return Icons.code;
      case ExpressionLanguage.groovy:
        return Icons.javascript;
      case ExpressionLanguage.jq:
        return Icons.filter_list;
      case ExpressionLanguage.constant:
        return Icons.pin;
    }
  }

  List<QuickInsertItem> _getQuickInsertItems() {
    switch (_selectedLanguage) {
      case ExpressionLanguage.simple:
        return [
          QuickInsertItem('Body', r'${body}', Icons.inventory),
          QuickInsertItem('Header', r'${header.name}', Icons.title),
          QuickInsertItem('Property', r'${property.name}', Icons.label),
          QuickInsertItem('Exchange ID', r'${exchangeId}', Icons.fingerprint),
        ];
      case ExpressionLanguage.jsonpath:
        return [
          QuickInsertItem('Root', r'$', Icons.home),
          QuickInsertItem('Current', '@', Icons.place),
          QuickInsertItem('Array', '[*]', Icons.list),
          QuickInsertItem('Filter', '[?(@.id)]', Icons.filter_alt),
        ];
      case ExpressionLanguage.xpath:
        return [
          QuickInsertItem('Root', '/', Icons.home),
          QuickInsertItem('Descendant', '//', Icons.arrow_downward),
          QuickInsertItem('Attribute', '@attr', Icons.label),
          QuickInsertItem('Text', 'text()', Icons.text_fields),
        ];
      default:
        return [];
    }
  }

  List<ExpressionVariable> _getAvailableVariables() {
    return [
      ExpressionVariable('body', r'${body}', 'The message body'),
      ExpressionVariable('headers', r'${headers}', 'All message headers'),
      ExpressionVariable(
        'header.name',
        r'${header.name}',
        'Specific header value',
      ),
      ExpressionVariable(
        'property.name',
        r'${property.name}',
        'Exchange property',
      ),
      ExpressionVariable('exchangeId', r'${exchangeId}', 'Unique exchange ID'),
      ExpressionVariable('routeId', r'${routeId}', 'Current route ID'),
    ];
  }

  List<ExpressionFunction> _getAvailableFunctions() {
    return [
      ExpressionFunction(
        'contains',
        r'${body} contains "text"',
        'Check if text contains substring',
      ),
      ExpressionFunction(
        'in',
        r'${header.type} in "A,B,C"',
        'Check if value is in list',
      ),
      ExpressionFunction(
        'regex',
        r'${body} regex "pattern"',
        'Match regular expression',
      ),
      ExpressionFunction(
        'range',
        r'${header.age} range "18..65"',
        'Check if value in range',
      ),
    ];
  }

  List<ExpressionExample> _getExamples() {
    switch (_selectedLanguage) {
      case ExpressionLanguage.simple:
        return [
          ExpressionExample('Check user ID', r'${body.userId} == 123'),
          ExpressionExample(
            'Header contains',
            r'${header.ContentType} contains "json"',
          ),
          ExpressionExample(
            'Multiple conditions',
            r'${body.status} == "active" && ${body.amount} > 100',
          ),
        ];
      case ExpressionLanguage.jsonpath:
        return [
          ExpressionExample('Get user name', r'$.user.name'),
          ExpressionExample(
            'Filter array',
            r'$.orders[?(@.status == "pending")]',
          ),
          ExpressionExample('All items', r'$.items[*].price'),
        ];
      case ExpressionLanguage.xpath:
        return [
          ExpressionExample('Get element', r'/order/customer/name'),
          ExpressionExample('Get attribute', r'/order/@id'),
          ExpressionExample('Filter nodes', r'//item[price > 100]'),
        ];
      default:
        return [];
    }
  }

  void _insertText(String text) {
    final currentText = _expressionController.text;
    final selection = _expressionController.selection;
    final newText = currentText.replaceRange(
      selection.start,
      selection.end,
      text,
    );
    _expressionController.text = newText;
    _expressionController.selection = TextSelection.collapsed(
      offset: selection.start + text.length,
    );
    _validateExpression();
  }

  void _validateExpression() {
    setState(() {
      _validationError = null;
      // TODO: Implement proper validation based on language
      if (_expressionController.text.isEmpty) {
        _validationError = 'Expression cannot be empty';
      }
    });
  }

  void _testExpression() {
    // TODO: Implement expression testing with sample data
    setState(() {
      _testResult = 'Result: true (sample)';
    });
  }

  void _formatExpression() {
    // TODO: Implement expression formatting
  }

  void _showLanguageHelp() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('${_selectedLanguage.displayName} Help'),
            content: SingleChildScrollView(child: Text(_getLanguageHelp())),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  String _getLanguageHelp() {
    switch (_selectedLanguage) {
      case ExpressionLanguage.simple:
        return '''
Simple Expression Language is the default language in Apache Camel.

Syntax:
- \${body} - access message body
- \${header.name} - access header
- \${property.name} - access property
- == != < > <= >= - comparisons
- && || ! - logical operators
- contains in regex - string operations
''';
      case ExpressionLanguage.jsonpath:
        return '''
JSONPath is used to query JSON documents.

Syntax:
- \$ - root element
- @ - current element
- . - child operator
- [] - array operator
- [?(@.key)] - filter expression
''';
      case ExpressionLanguage.xpath:
        return '''
XPath is used to query XML documents.

Syntax:
- / - select from root
- // - select descendants
- @ - select attribute
- text() - select text content
- [predicate] - filter nodes
''';
      default:
        return 'Documentation not available';
    }
  }

  void _saveExpression() {
    Navigator.pop(context, {
      'expression': _expressionController.text,
      'language': _selectedLanguage,
    });
  }

  @override
  void dispose() {
    _expressionController.dispose();
    super.dispose();
  }
}
