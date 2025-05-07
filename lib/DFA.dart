import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:minor_project/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main2() {
  runApp(DFAVisualizerApp());
}

class DFAVisualizerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DFA Visualizer',
      home: DFAHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DFAHomePage extends StatefulWidget {
  @override
  _DFAHomePageState createState() => _DFAHomePageState();
}

class _DFAHomePageState extends State<DFAHomePage> {
  final _startStateController = TextEditingController();
  final _acceptStatesController = TextEditingController();
  final _inputStringController = TextEditingController();
  final _importController = TextEditingController();

  List<Map<String, String>> _transitionRows = [];
  Map<String, Map<String, String>> _transitions = {};
  String _startState = '';
  Set<String> _acceptStates = {};
  String _result = '';

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  void _saveSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> saveData = {
      'startState': _startStateController.text,
      'acceptStates': _acceptStatesController.text,
      'transitions': _transitionRows,
    };
    prefs.setString('dfa_config', jsonEncode(saveData));
  }

  void _loadSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? config = prefs.getString('dfa_config');
    if (config != null) {
      Map<String, dynamic> data = jsonDecode(config);
      _startStateController.text = data['startState'] ?? '';
      _acceptStatesController.text = data['acceptStates'] ?? '';
      _transitionRows = List<Map<String, String>>.from(
          (data['transitions'] as List)
              .map((e) => Map<String, String>.from(e)));
      _updateDFA();
    }
  }

  void _addTransitionRow() {
    setState(() {
      _transitionRows.add({'current': '', 'symbol': '', 'next': ''});
    });
  }

  void _deleteTransitionRow(int index) {
    setState(() {
      _transitionRows.removeAt(index);
      _saveSession();
    });
  }

  void _updateDFA() {
    Map<String, Map<String, String>> newTransitions = {};

    for (var row in _transitionRows) {
      String from = row['current']!.trim();
      String symbol = row['symbol']!.trim();
      String to = row['next']!.trim();

      if (from.isNotEmpty && symbol.isNotEmpty && to.isNotEmpty) {
        newTransitions.putIfAbsent(from, () => {})[symbol] = to;
      }
    }

    setState(() {
      _transitions = newTransitions;
      _startState = _startStateController.text.trim();
      _acceptStates = _acceptStatesController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toSet();
      _result = '';
    });

    _saveSession();
  }

  void _checkString() {
    String currentState = _startState;
    String input = _inputStringController.text;

    for (int i = 0; i < input.length; i++) {
      String symbol = input[i];

      if (_transitions[currentState] != null &&
          _transitions[currentState]![symbol] != null) {
        currentState = _transitions[currentState]![symbol]!;
      } else {
        setState(() {
          _result =
              '❌ Rejected (No transition for "$symbol" from state "$currentState")';
        });
        return;
      }
    }

    setState(() {
      _result = _acceptStates.contains(currentState)
          ? '✅ Accepted'
          : '❌ Rejected (Ended in non-accepting state "$currentState")';
    });
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('How to Use'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('1. Enter a Start State.'),
              Text('2. Enter Accept States (comma separated).'),
              Text('3. Use the table to add transitions.'),
              Text('4. Tap "Update DFA" to save configuration.'),
              Text('5. Enter input string and click "Check String".'),
              Text('6. Use "Export/Import" to backup/load configs.'),
              SizedBox(height: 12),
              Text(
                'Note:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('- Undefined transitions lead to rejection.'),
              Text('- All entries are case-sensitive.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _exportConfig() {
    Map<String, dynamic> exportData = {
      'startState': _startStateController.text,
      'acceptStates': _acceptStatesController.text,
      'transitions': _transitionRows,
    };
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export DFA Config'),
        content: SingleChildScrollView(
          child: SelectableText(jsonEncode(exportData)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          )
        ],
      ),
    );
  }

  void _importConfig() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Import DFA Config'),
        content: TextField(
          controller: _importController,
          maxLines: 10,
          decoration: InputDecoration(
            hintText: 'Paste your JSON config here',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              try {
                Map<String, dynamic> data = jsonDecode(_importController.text);
                setState(() {
                  _startStateController.text = data['startState'] ?? '';
                  _acceptStatesController.text = data['acceptStates'] ?? '';
                  _transitionRows = List<Map<String, String>>.from(
                      (data['transitions'] as List)
                          .map((e) => Map<String, String>.from(e)));
                });
                _updateDFA();
                _importController.clear();
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Invalid JSON')),
                );
              }
            },
            child: Text('Import'),
          ),
          TextButton(
            onPressed: () {
              _importController.clear();
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransitionTable() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: Text('Current State',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            Expanded(
                child: Text('Symbol',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            Expanded(
                child: Text('Next State',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 4),
        ..._transitionRows.asMap().entries.map((entry) {
          int index = entry.key;
          var row = entry.value;

          return Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: row['current'],
                  onChanged: (value) =>
                      _transitionRows[index]['current'] = value,
                ),
              ),
              Expanded(
                child: TextFormField(
                  initialValue: row['symbol'],
                  onChanged: (value) =>
                      _transitionRows[index]['symbol'] = value,
                ),
              ),
              Expanded(
                child: TextFormField(
                  initialValue: row['next'],
                  onChanged: (value) => _transitionRows[index]['next'] = value,
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteTransitionRow(index),
              ),
            ],
          );
        }),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _addTransitionRow,
          icon: Icon(Icons.add),
          label: Text('Add Transition'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        runApp(const MainApp());
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 183, 186, 188),
        appBar: AppBar(
          title: Text('DFA Visualizer'),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.exit_to_app)),
            IconButton(
                icon: Icon(Icons.import_export), onPressed: _exportConfig),
            IconButton(icon: Icon(Icons.upload_file), onPressed: _importConfig),
            IconButton(
                icon: Icon(Icons.info_outline), onPressed: _showInstructions),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: ListView(
            children: [
              Text('Start State:'),
              TextField(controller: _startStateController),
              SizedBox(height: 8),
              Text('Accept States (comma separated):'),
              TextField(controller: _acceptStatesController),
              SizedBox(height: 16),
              Text('DFA Transitions:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              _buildTransitionTable(),
              SizedBox(height: 16),
              ElevatedButton(onPressed: _updateDFA, child: Text('Update DFA')),
              Divider(),
              Text('Input String:'),
              TextField(controller: _inputStringController),
              SizedBox(height: 8),
              ElevatedButton(
                  onPressed: _checkString, child: Text('Check String')),
              SizedBox(height: 12),
              Text('Result:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(_result,
                  style: TextStyle(
                      fontSize: 18,
                      color:
                          _result.startsWith('✅') ? Colors.green : Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}
