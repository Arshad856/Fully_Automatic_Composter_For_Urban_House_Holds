import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

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
              text: const TextSpan(children: [
                TextSpan(
                  text: 'Comp',
                  style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF98C13F)),
                ),
                TextSpan(
                  text: 'Genie',
                  style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF159148)),
                ),
              ]),
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

class ThresholdScreen extends StatefulWidget {
  const ThresholdScreen({
    super.key,
    required this.chamberName,
    required this.metrics,
  });

  final String chamberName;
  final List<Map<String, String>> metrics;

  @override
  State<ThresholdScreen> createState() => _ThresholdScreenState();
}

class _ThresholdScreenState extends State<ThresholdScreen> {
  final Color _green = const Color(0xFF018D54);

  static const Map<String, RangeValues> _rangeTable = {
    'Temperature': RangeValues(10, 80),
    'Humidity': RangeValues(0, 100),
    'Level': RangeValues(0, 100),
    'Soil Moisture': RangeValues(0, 100),
    'Soil Temperature': RangeValues(5, 80),
  };

  late List<_MetricConfig> _configs = [];
  late final String _chamberKey; // e.g., Chamber_1

  @override
  void initState() {
    super.initState();
    _chamberKey = 'Chamber_${widget.chamberName.split(' ').first}';
    _loadThresholdsFromFirebase();
  }

  Future<void> _loadThresholdsFromFirebase() async {
    final dbRef =
        FirebaseDatabase.instance.ref('Sensor_Threshold/$_chamberKey');
    final snapshot = await dbRef.get();

    _configs = widget.metrics.map((m) {
      final label = m['label']!;
      final unit = m['value']!.contains('°') ? '°C' : '%';
      final range = _rangeTable[label] ?? const RangeValues(0, 100);

      // If exists in Firebase
      final firebaseVal = snapshot.child(label).value;
      double value = double.tryParse(firebaseVal?.toString() ?? '') ??
          double.tryParse(m['value']!.replaceAll(RegExp(r'[^0-9.]'), '')) ??
          range.start;

      return _MetricConfig(
        label: label,
        unit: unit,
        min: range.start,
        max: range.end,
        value: value.clamp(range.start, range.end),
      );
    }).toList();

    setState(() {});
  }

  Future<void> _saveToFirebase() async {
    final dbRef =
        FirebaseDatabase.instance.ref('Sensor_Threshold/$_chamberKey');

    for (var metric in _configs) {
      await dbRef.child(metric.label).set(metric.value.toStringAsFixed(1));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thresholds saved to Firebase')),
    );
  }

  Widget _tile(_MetricConfig c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: _green,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.thermostat, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  c.label,
                  maxLines: 2,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                '${c.value.toStringAsFixed(0)} ${c.unit}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _green,
            inactiveTrackColor: const Color(0xFFEAEAEA),
            thumbColor: _green,
            overlayColor: _green.withOpacity(.2),
            valueIndicatorColor: _green,
          ),
          child: Slider(
            min: c.min,
            max: c.max,
            divisions: (c.max - c.min).round(),
            value: c.value,
            label: c.value.toStringAsFixed(1),
            onChanged: (v) => setState(() => c.value = v),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: const _CompGenieLogo(),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              widget.chamberName,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: _configs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ..._configs.map(_tile).toList(),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _saveToFirebase,
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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

class _MetricConfig {
  _MetricConfig({
    required this.label,
    required this.unit,
    required this.min,
    required this.max,
    required this.value,
  });

  final String label, unit;
  final double min, max;
  double value;
}
