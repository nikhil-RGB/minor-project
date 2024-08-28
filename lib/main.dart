import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:minor_project/flutter_automata/main.dart';
import 'package:minor_project/turing_machines/main.dart';
import 'package:minor_project/turing_machines/models/Actions.dart';
import 'package:minor_project/turing_machines/models/Behaviour.dart';
import 'package:minor_project/turing_machines/models/Configuration.dart';
import 'package:minor_project/turing_machines/models/TuringMachineModel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(BehaviourAdapter());
  Hive.registerAdapter(ConfigurationAdapter());
  Hive.registerAdapter(ActionsAdapter());
  Hive.registerAdapter(ActionTypeAdapter());
  Hive.registerAdapter(TuringMachineModelAdapter());
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Column(
        children: [
          Gap(MediaQuery.of(context).size.height * 0.4),
          generateOkButton(0),
          const Gap(10),
          generateOkButton(1),
        ],
      ),
    ));
  }

  Container generateOkButton(int page_index) {
    String name = "";
    switch (page_index) {
      case 0:
        name = "Cellular Automata";
        break;
      case 1:
        name = "Turing Machine Simulator";
        break;
      default:
        throw "Invalid index";
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
      ),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              shape: RoundedRectangleBorder(
                  side: BorderSide.none,
                  // border radius
                  borderRadius: BorderRadius.circular(50))),
          onPressed: () {
            if (page_index == 0) {
              main0();
            } else {
              main1();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              name,
              style: GoogleFonts.sourceCodePro(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w600),
            ),
          )),
    );
  }
}
