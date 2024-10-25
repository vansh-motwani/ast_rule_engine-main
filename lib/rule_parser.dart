import 'package:ast_rule_engine/rule_node.dart';

class RuleParser {
  int position = 0;

  RuleNode parseRule(String rule) {
    position = 0;
    return parseExpression(rule);
  }

  RuleNode parseExpression(String rule) {
    skipWhitespace(rule);

    if (rule[position] == '(') {
      position++; // Skip opening parenthesis
      RuleNode left = parseExpression(rule);
      skipWhitespace(rule);

      String operation = parseOperation(rule);
      skipWhitespace(rule);

      RuleNode right = parseExpression(rule);
      skipWhitespace(rule);

      if (rule[position] == ')') {
        position++; // Skip closing parenthesis
      }

      return RuleNode(
        operation: operation,
        left: left,
        right: right,
      );
    } else {
      return parseCondition(rule);
    }
  }

  RuleNode parseCondition(String rule) {
    String field = '';
    while (position < rule.length && rule[position] != ' ') {
      field += rule[position];
      position++;
    }

    skipWhitespace(rule);
    String operation = parseOperation(rule);
    skipWhitespace(rule);

    String value = '';
    while (position < rule.length &&
        rule[position] != ')' &&
        rule[position] != ' ') {
      value += rule[position];
      position++;
    }

    return RuleNode(
      operation: operation,
      field: field,
      value: value
          .replaceAll('"', '')
          .replaceAll("'", ''), // Removing quotes for string values
    );
  }

  String parseOperation(String rule) {
    String operation = '';
    while (position < rule.length &&
        (rule[position] == '>' ||
            rule[position] == '<' ||
            rule[position] == '=' ||
            rule[position] == 'A' ||
            rule[position] == 'N' ||
            rule[position] == 'D' ||
            rule[position] == 'O' ||
            rule[position] == 'R')) {
      operation += rule[position];
      position++;
    }
    return operation;
  }

  void skipWhitespace(String rule) {
    while (position < rule.length && rule[position] == ' ') {
      position++;
    }
  }
}