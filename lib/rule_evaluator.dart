import 'package:ast_rule_engine/rule_node.dart';

class RuleEvaluator {
  bool evaluateRule(RuleNode node, Map<String, dynamic> userData) {
    if (node.left == null && node.right == null) {
      return evaluateCondition(node, userData);
    }

    bool leftResult = evaluateRule(node.left!, userData);
    bool rightResult = evaluateRule(node.right!, userData);

    switch (node.operation) {
      case 'AND':
        return leftResult && rightResult;
      case 'OR':
        return leftResult || rightResult;
      default:
        return false;
    }
  }

  bool evaluateCondition(RuleNode node, Map<String, dynamic> userData) {
    dynamic userValue = userData[node.field];
    dynamic ruleValue = node.value;

    // Convert string numbers to numeric if needed
    if (ruleValue is String) {
      var parsedValue = num.tryParse(ruleValue);
      if (parsedValue != null) {
        ruleValue = parsedValue;
      }
    }

    switch (node.operation) {
      case '>':
        return userValue > ruleValue;
      case '<':
        return userValue < ruleValue;
      case '=':
        return userValue.toString().toLowerCase() ==
            ruleValue.toString().toLowerCase(); // Case-insensitive comparison
      default:
        return false;
    }
  }
}