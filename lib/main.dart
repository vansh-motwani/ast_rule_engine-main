import 'package:ast_rule_engine/rule_evaluator.dart';
import 'package:ast_rule_engine/rule_node.dart';
import 'package:ast_rule_engine/rule_parser.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const RuleEngineApp());
}

class RuleEngineApp extends StatelessWidget {
  const RuleEngineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AST Rule Engine',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const RuleEnginePage(),
    );
  }
}

class RuleEnginePage extends StatefulWidget {
  const RuleEnginePage({super.key});

  @override
  State<RuleEnginePage> createState() => _RuleEnginePageState();
}

class _RuleEnginePageState extends State<RuleEnginePage> {
  final List<String> rules = [];
  final TextEditingController _ruleController = TextEditingController();
  final TextEditingController _testDataController = TextEditingController();
  final RuleParser _parser = RuleParser();
  final RuleEvaluator _evaluator = RuleEvaluator();
  String _testResult = '';
  bool _showTestInput = false;

  void _addRule() {
    if (_ruleController.text.isNotEmpty) {
      setState(() {
        rules.add(_ruleController.text);
        _ruleController.clear();
      });
    }
  }

  void _deleteRule(int index) {
    setState(() {
      rules.removeAt(index);
    });
  }

  void _testRules() {
    setState(() {
      _showTestInput = true;
    });
  }

  void _evaluateTestData() {
    try {
      // Parse test data string to Map
      final testDataString = _testDataController.text;
      final testData = _parseTestData(testDataString);

      // Evaluate all rules - At least one rule should pass
      bool finalResult = false;
      for (String rule in rules) {
        RuleNode ast = _parser.parseRule(rule);
        bool ruleResult = _evaluator.evaluateRule(ast, testData);
        finalResult = finalResult ||
            ruleResult; // OR logic: any passing rule passes the test
        if (finalResult) break; // If any rule passes, we can stop checking
      }

      setState(() {
        _testResult = 'Test Result: ${finalResult ? "PASS" : "FAIL"}';
      });
    } catch (e) {
      setState(() {
        _testResult = 'Error: Invalid test data format - ${e.toString()}';
      });
    }
  }

  Map<String, dynamic> _parseTestData(String data) {
    // Enhanced parser for the test data string
    data = data.replaceAll('{', '').replaceAll('}', '');
    Map<String, dynamic> result = {};

    for (String pair in data.split(',')) {
      pair = pair.trim();
      List<String> keyValue = pair.split(':');
      if (keyValue.length == 2) {
        String key = keyValue[0].trim().replaceAll('"', '').replaceAll("'", '');
        String value =
            keyValue[1].trim().replaceAll('"', '').replaceAll("'", '');

        // Try to convert to number if possible
        if (num.tryParse(value) != null) {
          result[key] = num.parse(value);
        } else {
          result[key] = value;
        }
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AST Rule Engine'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add New Rule',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _ruleController,
                        decoration: const InputDecoration(
                          hintText: 'Enter rule condition',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _addRule,
                        child: const Text('Add Rule'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Rules',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: rules.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(rules[index]),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteRule(index),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (rules.isNotEmpty) ...[
                ElevatedButton(
                  onPressed: _testRules,
                  child: const Text('Test Rules'),
                ),
              ],
              const SizedBox(height: 16),
              if (_showTestInput)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Test Data',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _testDataController,
                          decoration: const InputDecoration(
                            hintText:
                                'Enter test data in JSON format: {"age": 25, "department": "Sales"}',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _evaluateTestData,
                          child: const Text('Evaluate Test Data'),
                        ),
                        const SizedBox(height: 16),
                        if (_testResult.isNotEmpty)
                          Text(
                            _testResult,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
