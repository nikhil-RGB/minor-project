import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:minor_project/main.dart';
import 'package:minor_project/turing_machines/main.dart';
import 'package:minor_project/turing_machines/models/Targets.dart';
import 'package:minor_project/turing_machines/models/TuringMachines.dart';
import 'package:minor_project/turing_machines/screens/LoadMachineScreen.dart';
import 'package:minor_project/turing_machines/screens/TableScreen.dart';
import 'package:minor_project/turing_machines/testing.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    Targets platform = target;
    Size size = MediaQuery.of(context).size;
    if (size.width <= 480 && (platform == Targets.WEB)) {
      platform = Targets.ANDROID;
    }
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        runApp(const MainApp());
      },
      child: SafeArea(
          child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.exit_to_app_outlined,
              color: Colors.cyan,
            ),
          ),
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(child: Image.asset("assets/images/TMG.png")),
              const Gap(25),
              Image.asset("assets/images/machine.png"),
              const Gap(25),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
                  onPressed: () {
                    TuringMachine machine = StandardMachines.emptyMachine();
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return TableScreen(machine: machine);
                    }));
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(17.0),
                    child: Text(
                      "Create Machine",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  )),
              Gap((platform == Targets.ANDROID) ? 20 : 35),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
                  onPressed: () {
                    TuringMachine machine = StandardMachines.defaultMachine();
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return TableScreen(machine: machine);
                    }));
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(17.0),
                    child: Text(
                      "Default Machine",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  )),
              Gap((platform == Targets.ANDROID) ? 20 : 35),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return LoadMachineScreen();
                    }));
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(17.0),
                    child: Text(
                      "Load Machine",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  )),
              Gap((platform == Targets.ANDROID) ? 20 : 35),
            ],
          ),
        ),
      )),
    );
  }
}
