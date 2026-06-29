import 'package:flutter/material.dart';

enum ExpressionLanguage {
  simple('Simple'),
  jsonpath('JSONPath'),
  xpath('XPath'),
  groovy('Groovy'),
  jq('jq'),
  constant('Constant');

  final String displayName;
  const ExpressionLanguage(this.displayName);
}

class QuickInsertItem {
  final String label;
  final String value;
  final IconData icon;

  QuickInsertItem(this.label, this.value, this.icon);
}

class ExpressionVariable {
  final String name;
  final String syntax;
  final String description;

  ExpressionVariable(this.name, this.syntax, this.description);
}

class ExpressionFunction {
  final String name;
  final String syntax;
  final String description;

  ExpressionFunction(this.name, this.syntax, this.description);
}

class ExpressionExample {
  final String title;
  final String expression;

  ExpressionExample(this.title, this.expression);
}
