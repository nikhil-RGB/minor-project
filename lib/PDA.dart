import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:minor_project/main.dart';

void main3() {
  runApp(const PDAApp());
}

class PDAApp extends StatelessWidget {
  const PDAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDA Designer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PDACreatorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PDATransition {
  String currentState;
  String inputSymbol;
  String stackTop;
  String newState;
  String stackPush;

  PDATransition({
    required this.currentState,
    required this.inputSymbol,
    required this.stackTop,
    required this.newState,
    required this.stackPush,
  });

  Map<String, dynamic> toJson() => {
        'currentState': currentState,
        'inputSymbol': inputSymbol,
        'stackTop': stackTop,
        'newState': newState,
        'stackPush': stackPush,
      };

  factory PDATransition.fromJson(Map<String, dynamic> json) => PDATransition(
        currentState: json['currentState'],
        inputSymbol: json['inputSymbol'],
        stackTop: json['stackTop'],
        newState: json['newState'],
        stackPush: json['stackPush'],
      );
}

class PDACreatorScreen extends StatefulWidget {
  const PDACreatorScreen({super.key});

  @override
  _PDACreatorScreenState createState() => _PDACreatorScreenState();
}

class _PDACreatorScreenState extends State<PDACreatorScreen> {
  final List<PDATransition> _transitions = [];
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _currentStateController = TextEditingController();
  final TextEditingController _inputSymbolController = TextEditingController();
  final TextEditingController _stackTopController = TextEditingController();
  final TextEditingController _newStateController = TextEditingController();
  final TextEditingController _stackPushController = TextEditingController();

  String _initialState = 'q0';
  String _initialStackSymbol = 'Z';
  final TextEditingController _initialStateController =
      TextEditingController(text: 'q0');
  final TextEditingController _initialStackController =
      TextEditingController(text: 'Z');

  String _jsonString = '';

  @override
  void initState() {
    super.initState();
    // Add an initial transition for example
    _transitions.add(PDATransition(
      currentState: 'q0',
      inputSymbol: 'a',
      stackTop: 'Z',
      newState: 'q1',
      stackPush: 'aZ',
    ));
  }

  @override
  void dispose() {
    _currentStateController.dispose();
    _inputSymbolController.dispose();
    _stackTopController.dispose();
    _newStateController.dispose();
    _stackPushController.dispose();
    _initialStateController.dispose();
    _initialStackController.dispose();
    super.dispose();
  }

  void _addTransition() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _transitions.add(PDATransition(
          currentState: _currentStateController.text,
          inputSymbol: _inputSymbolController.text,
          stackTop: _stackTopController.text,
          newState: _newStateController.text,
          stackPush: _stackPushController.text,
        ));

        // Clear the form
        _currentStateController.clear();
        _inputSymbolController.clear();
        _stackTopController.clear();
        _newStateController.clear();
        _stackPushController.clear();
      });
    }
  }

  void _removeTransition(int index) {
    setState(() {
      _transitions.removeAt(index);
    });
  }

  void _updateInitialValues() {
    setState(() {
      _initialState = _initialStateController.text;
      _initialStackSymbol = _initialStackController.text;
    });
  }

  void _exportToJson() {
    final pdaData = {
      'initialState': _initialState,
      'initialStackSymbol': _initialStackSymbol,
      'transitions': _transitions.map((t) => t.toJson()).toList(),
    };
    setState(() {
      _jsonString = jsonEncode(pdaData);
    });
    Clipboard.setData(ClipboardData(text: _jsonString));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDA configuration copied to clipboard!')),
    );
  }

  void _importFromJson() async {
    final jsonText = await showDialog<String>(
      context: context,
      builder: (context) => JsonImportDialog(),
    );

    if (jsonText != null && jsonText.isNotEmpty) {
      try {
        final jsonData = jsonDecode(jsonText);
        setState(() {
          _initialState = jsonData['initialState'];
          _initialStackSymbol = jsonData['initialStackSymbol'];
          _transitions.clear();
          _transitions.addAll((jsonData['transitions'] as List)
              .map((t) => PDATransition.fromJson(t)));
          _initialStateController.text = _initialState;
          _initialStackController.text = _initialStackSymbol;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error parsing JSON: $e')),
        );
      }
    }
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
          title: const Text('PDA Creator'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.exit_to_app_outlined),
            ),
            const Gap(4),
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () {
                _updateInitialValues();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PDAExecutionScreen(
                      initialState: _initialState,
                      initialStackSymbol: _initialStackSymbol,
                      transitions: List.from(_transitions),
                    ),
                  ),
                );
              },
              tooltip: 'Run PDA',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
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
                        'Initial Configuration',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _initialStateController,
                              decoration: const InputDecoration(
                                labelText: 'Initial State',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter initial state';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _initialStackController,
                              decoration: const InputDecoration(
                                labelText: 'Initial Stack Symbol',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter stack symbol';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _updateInitialValues,
                            child: const Text('Update'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Transitions',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Form(
                          key: _formKey,
                          child: Table(
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(1),
                              2: FlexColumnWidth(1),
                              3: FlexColumnWidth(2),
                              4: FlexColumnWidth(2),
                              5: FlexColumnWidth(1),
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                ),
                                children: const [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Current State',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Input',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Stack Top',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('New State',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Stack Push',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Action',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: TextFormField(
                                      controller: _currentStateController,
                                      decoration: const InputDecoration(
                                        hintText: 'e.g., q0',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: TextFormField(
                                      controller: _inputSymbolController,
                                      decoration: const InputDecoration(
                                        hintText: 'e.g., a',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: TextFormField(
                                      controller: _stackTopController,
                                      decoration: const InputDecoration(
                                        hintText: 'e.g., Z',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: TextFormField(
                                      controller: _newStateController,
                                      decoration: const InputDecoration(
                                        hintText: 'e.g., q1',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: TextFormField(
                                      controller: _stackPushController,
                                      decoration: const InputDecoration(
                                        hintText: 'e.g., aZ',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: _addTransition,
                                    tooltip: 'Add Transition',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 300,
                          child: ListView.builder(
                            itemCount: _transitions.length,
                            itemBuilder: (context, index) {
                              final transition = _transitions[index];
                              return Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(2),
                                  1: FlexColumnWidth(1),
                                  2: FlexColumnWidth(1),
                                  3: FlexColumnWidth(2),
                                  4: FlexColumnWidth(2),
                                  5: FlexColumnWidth(1),
                                },
                                children: [
                                  TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(transition.currentState),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(transition.inputSymbol),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(transition.stackTop),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(transition.newState),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(transition.stackPush),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () =>
                                            _removeTransition(index),
                                        tooltip: 'Remove Transition',
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    )),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.import_export),
                    label: const Text('Import JSON'),
                    onPressed: _importFromJson,
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.copy),
                    label: const Text('Export JSON'),
                    onPressed: _exportToJson,
                  ),
                ],
              ),
              if (_jsonString.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text('Current JSON:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SelectableText(_jsonString),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class JsonImportDialog extends StatefulWidget {
  @override
  _JsonImportDialogState createState() => _JsonImportDialogState();
}

class _JsonImportDialogState extends State<JsonImportDialog> {
  final TextEditingController _jsonController = TextEditingController();

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import PDA from JSON'),
      content: SizedBox(
        width: double.maxFinite,
        child: TextField(
          controller: _jsonController,
          maxLines: 10,
          decoration: const InputDecoration(
            hintText: 'Paste JSON configuration here',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _jsonController.text),
          child: const Text('Import'),
        ),
      ],
    );
  }
}

class PDAExecutionScreen extends StatefulWidget {
  final String initialState;
  final String initialStackSymbol;
  final List<PDATransition> transitions;

  const PDAExecutionScreen({
    super.key,
    required this.initialState,
    required this.initialStackSymbol,
    required this.transitions,
  });

  @override
  _PDAExecutionScreenState createState() => _PDAExecutionScreenState();
}

class _PDAExecutionScreenState extends State<PDAExecutionScreen> {
  late String _currentState;
  late List<String> _stack;
  String _inputString = '';
  int _currentInputIndex = 0;
  final List<String> _log = [];
  bool _isProcessing = false;
  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _resetPDA();
    _log.add('PDA initialized');
    _log.add('Initial state: ${widget.initialState}');
    _log.add('Initial stack symbol: ${widget.initialStackSymbol}');
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _resetPDA() {
    setState(() {
      _currentState = widget.initialState;
      _stack = [widget.initialStackSymbol];
      _currentInputIndex = 0;
      _log.clear();
      _log.add('PDA reset to initial configuration');
    });
  }

  Future<void> _processInput() async {
    if (_inputString.isEmpty || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    _resetPDA();
    _log.add('Processing input: $_inputString');

    while (_currentInputIndex < _inputString.length) {
      final currentInputSymbol = _inputString[_currentInputIndex];
      final currentStackTop = _stack.isNotEmpty ? _stack.last : 'ε';

      final matchingTransitions = widget.transitions.where((t) {
        return t.currentState == _currentState &&
            (t.inputSymbol == currentInputSymbol || t.inputSymbol == 'ε') &&
            (t.stackTop == currentStackTop || t.stackTop == 'ε');
      }).toList();

      if (matchingTransitions.isEmpty) {
        _log.add(
            'No transition found for state=$_currentState, input=$currentInputSymbol, stack=$currentStackTop');
        break;
      }

      // For simplicity, take the first matching transition
      final transition = matchingTransitions.first;

      setState(() {
        // Process ε-input transitions
        if (transition.inputSymbol != 'ε') {
          _currentInputIndex++;
        }

        // Process stack
        if (transition.stackTop != 'ε') {
          _stack.removeLast();
        }
        if (transition.stackPush != 'ε') {
          // Push symbols in reverse order (since stack is LIFO)
          for (var i = transition.stackPush.length - 1; i >= 0; i--) {
            _stack.add(transition.stackPush[i]);
          }
        }

        _currentState = transition.newState;

        _log.add(
            'Transition: ${transition.currentState} -> ${transition.newState} on ${transition.inputSymbol} (stack: ${transition.stackTop}->${transition.stackPush})');
        _log.add('Current state: $_currentState');
        _log.add('Stack: [${_stack.join(', ')}]');
        _log.add(
            'Remaining input: ${_inputString.substring(_currentInputIndex)}');
      });

      await Future.delayed(const Duration(milliseconds: 500));
    }

    setState(() {
      _isProcessing = false;
      _log.add('Processing complete');
      if (_currentInputIndex == _inputString.length) {
        _log.add('Reached end of input');
      }
    });
  }

  void _step() {
    if (_currentInputIndex >= _inputString.length || _isProcessing) return;

    final currentInputSymbol = _inputString[_currentInputIndex];
    final currentStackTop = _stack.isNotEmpty ? _stack.last : 'ε';

    final matchingTransitions = widget.transitions.where((t) {
      return t.currentState == _currentState &&
          (t.inputSymbol == currentInputSymbol || t.inputSymbol == 'ε') &&
          (t.stackTop == currentStackTop || t.stackTop == 'ε');
    }).toList();

    if (matchingTransitions.isEmpty) {
      setState(() {
        _log.add(
            'No transition found for state=$_currentState, input=$currentInputSymbol, stack=$currentStackTop');
      });
      return;
    }

    // Take the first matching transition
    final transition = matchingTransitions.first;

    setState(() {
      // Process ε-input transitions
      if (transition.inputSymbol != 'ε') {
        _currentInputIndex++;
      }

      // Process stack
      if (transition.stackTop != 'ε') {
        _stack.removeLast();
      }
      if (transition.stackPush != 'ε') {
        // Push symbols in reverse order (since stack is LIFO)
        for (var i = transition.stackPush.length - 1; i >= 0; i--) {
          _stack.add(transition.stackPush[i]);
        }
      }

      _currentState = transition.newState;

      _log.add(
          'Transition: ${transition.currentState} -> ${transition.newState} on ${transition.inputSymbol} (stack: ${transition.stackTop}->${transition.stackPush})');
      _log.add('Current state: $_currentState');
      _log.add('Stack: [${_stack.join(', ')}]');
      _log.add(
          'Remaining input: ${_inputString.substring(_currentInputIndex)}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 183, 186, 188),
      appBar: AppBar(
        title: const Text('PDA Execution'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                        'PDA Configuration',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child:
                                Text('Initial State: ${widget.initialState}'),
                          ),
                          Expanded(
                            child: Text(
                                'Initial Stack: ${widget.initialStackSymbol}'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('Transitions: ${widget.transitions.length} defined'),
                    ],
                  )),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Input',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _inputController,
                            decoration: const InputDecoration(
                              labelText: 'Input String',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _inputString = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _inputString.isNotEmpty && !_isProcessing
                              ? _processInput
                              : null,
                          child: const Text('Run'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _inputString.isNotEmpty && !_isProcessing
                              ? _step
                              : null,
                          child: const Text('Step'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _resetPDA,
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current State',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'State: $_currentState',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Stack',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      if (_stack.isEmpty)
                        const Text('Stack is empty')
                      else
                        Wrap(
                          spacing: 5,
                          children: _stack.reversed.map((symbol) {
                            return Chip(
                              label: Text(symbol),
                              backgroundColor: Colors.blue[100],
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 10),
                      Text(
                        'Remaining Input: ${_inputString.substring(_currentInputIndex)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Execution Log',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _log.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 2.0),
                              child: Text(_log[index]),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
