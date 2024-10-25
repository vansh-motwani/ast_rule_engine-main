class RuleNode {
  String operation; // AND, OR, >, <, =, etc.
  String field; // age, department, salary, etc.
  dynamic value;
  RuleNode? left;
  RuleNode? right;

  RuleNode({
    required this.operation,
    this.field = '',
    this.value,
    this.left,
    this.right,
  });
}