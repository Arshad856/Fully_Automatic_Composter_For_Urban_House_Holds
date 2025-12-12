import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

// ====== LOGO COMPONENT ======
class _CompGenieLogo extends StatelessWidget {
  const _CompGenieLogo({super.key, this.width = 140, this.height = 53});
  final double width, height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned(
            top: 22,
            left: 0,
            child: RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Comp',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF98C13F),
                    ),
                  ),
                  TextSpan(
                    text: 'Genie',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF159148),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 51,
            child: Image.asset(
              'assets/images/greengenielogocropped_1.png',
              width: 33,
              height: 28,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.error, size: 40, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// ====== TOGGLE BUTTON COMPONENT ======
class ToggleButton extends StatefulWidget {
  final List<String> states;
  final List<Color> colors;
  final String chamber;
  final String actuator;

  const ToggleButton({
    super.key,
    required this.states,
    required this.colors,
    required this.chamber,
    required this.actuator,
  });

  @override
  _ToggleButtonState createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  int currentIndex = 0;

  void _nextState() {
    setState(() {
      currentIndex = (currentIndex + 1) % widget.states.length;
    });
  }

  void resetToIdle() {
    setState(() {
      currentIndex = 0;
    });
  }

  Future<void> pushToFirebase() async {
    final ref = FirebaseDatabase.instance.ref();
    int valueToSend;
    switch (widget.states[currentIndex]) {
      case "ON":
      case "OPEN":
      case "IN":
      case "FW":
        valueToSend = 2;
        break;
      case "OFF":
      case "CLOSE":
        valueToSend = 1;
        break;
      case "OUT":
      case "BW":
        valueToSend = 3;
        break;
      default:
        valueToSend = 0;
    }

    await ref
        .child("Actuator_Control")
        .child(widget.chamber)
        .child(widget.actuator)
        .set(valueToSend);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _nextState,
      child: Container(
        width: 80,
        height: 36,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: widget.colors[currentIndex],
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          widget.states[currentIndex],
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ====== MAIN CONTROL SCREEN ======
class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  final List<GlobalKey<_ToggleButtonState>> toggleKeys = [];

  ToggleButton makeButton(String chamber, String actuator, List<String> states,
      List<Color> colors) {
    final key = GlobalKey<_ToggleButtonState>();
    toggleKeys.add(key);
    return ToggleButton(
      key: key,
      chamber: chamber,
      actuator: actuator,
      states: states,
      colors: colors,
    );
  }

  Widget horizontalLabelAndButton(String label, ToggleButton button) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        button,
      ],
    );
  }

  Future<void> saveAll() async {
    final ref = FirebaseDatabase.instance.ref();

    // Save actuator states
    for (final key in toggleKeys) {
      await key.currentState?.pushToFirebase();
    }

    // Set "Update" to 1
    await ref.child("Update").set(1);

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All values saved and Update set to 1.")));
  }

  void resetAll() {
    for (final key in toggleKeys) {
      key.currentState?.resetToIdle();
    }
    setState(() {});
  }

  Widget valveControl(String chamber) => horizontalLabelAndButton(
      "Valve     ",
      makeButton(chamber, "Valve", ["IDLE", "OPEN", "CLOSE"],
          [Colors.amber, Colors.green, Colors.red]));

  Widget heaterControl(String chamber) => horizontalLabelAndButton(
      "Heater   ",
      makeButton(chamber, "Heater", ["IDLE", "ON", "OFF"],
          [Colors.amber, Colors.green, Colors.red]));

  Widget exhaustFanControl(String chamber) => horizontalLabelAndButton(
      "Exhaust",
      makeButton(chamber, "Exhaust", ["IDLE", "OFF", "ON"],
          [Colors.amber, Colors.red, Colors.green]));

  Widget doorControl(String chamber) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Door", style: TextStyle(fontWeight: FontWeight.bold)),
        makeButton(chamber, "Door", ["IDLE", "OPEN", "CLOSE"],
            [Colors.amber, Colors.green, Colors.red]),
      ],
    );
  }

  Widget turningControl() => horizontalLabelAndButton(
      "Turning  ",
      makeButton("Chamber_4th", "Turning", ["IDLE", "FW", "BW", "OFF"],
          [Colors.amber, Colors.blue, Colors.green, Colors.red]));

  Widget chamberRow({
    required String title,
    required String chamberId,
    bool showValve = false,
    bool showHeater = false,
    bool showExhaust = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: doorControl(chamberId)),
          SizedBox(
            width: 140,
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  border: Border.all(color: Colors.black),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (showValve) valveControl(chamberId),
                if (showHeater) heaterControl(chamberId),
                if (showExhaust) exhaustFanControl(chamberId),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const _CompGenieLogo(),
        centerTitle: true,
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Icon(Icons.menu, color: Colors.black),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Icon(Icons.notifications_none, color: Colors.black),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: SingleChildScrollView(
          child: Column(
            children: [
              chamberRow(title: "1st chamber", chamberId: "Chamber_1st"),
              chamberRow(
                  title: "2nd chamber",
                  chamberId: "Chamber_2nd",
                  showExhaust: true),
              chamberRow(
                  title: "3rd chamber",
                  chamberId: "Chamber_3rd",
                  showValve: true,
                  showHeater: true,
                  showExhaust: true),
              chamberRow(
                  title: "4th chamber",
                  chamberId: "Chamber_4th",
                  showExhaust: true),
              turningControl(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: saveAll,
                      child: const Text("Save",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: resetAll,
                      child: const Text("Reset",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: const Color(0xFF159148),
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) Navigator.pop(context);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.monitor_heart), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_florist_outlined), label: ''),
        ],
      ),
    );
  }
}
