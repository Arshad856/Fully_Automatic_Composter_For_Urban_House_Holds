import 'package:flutter/material.dart';
import '../widgets/sensor_card_1.dart';
import '../widgets/status_indicator.dart';

class SensorValuesScreen extends StatefulWidget {
  const SensorValuesScreen({super.key});

  @override
  State<SensorValuesScreen> createState() => _SensorValuesScreenState();
}

class _SensorValuesScreenState extends State<SensorValuesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sensor Values',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF0D986A)),
            onPressed: () {
              // Handle refresh
              print('Refresh sensor data');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Overview Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D986A), Color(0xFF159148)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0D986A).withOpacity(0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'System Status',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        StatusIndicator(
                          status: 'Online',
                          color: Colors.green[300]!,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'All sensors are functioning normally',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Last updated: ${DateTime.now().toString().substring(0, 16)}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Environmental Sensors Section
              const Text(
                'Environmental Sensors',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 16),

              // Temperature and Humidity Row
              Row(
                children: [
                  Expanded(
                    child: SensorCard(
                      title: 'Temperature',
                      value: '24.5',
                      unit: '°C',
                      icon: Icons.thermostat,
                      color: const Color(0xFFFF6B6B),
                      trend: 'up',
                      trendValue: '+0.3',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SensorCard(
                      title: 'Humidity',
                      value: '68',
                      unit: '%',
                      icon: Icons.water_drop,
                      color: const Color(0xFF4ECDC4),
                      trend: 'down',
                      trendValue: '-2.1',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Pressure and Light Row
              Row(
                children: [
                  Expanded(
                    child: SensorCard(
                      title: 'Pressure',
                      value: '1013',
                      unit: 'hPa',
                      icon: Icons.compress,
                      color: const Color(0xFF45B7D1),
                      trend: 'stable',
                      trendValue: '0.0',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SensorCard(
                      title: 'Light',
                      value: '850',
                      unit: 'lux',
                      icon: Icons.wb_sunny,
                      color: const Color(0xFFFFA726),
                      trend: 'up',
                      trendValue: '+45',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Air Quality Section
              const Text(
                'Air Quality',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 16),

              // CO2 and PM2.5 Row
              Row(
                children: [
                  Expanded(
                    child: SensorCard(
                      title: 'CO₂',
                      value: '420',
                      unit: 'ppm',
                      icon: Icons.air,
                      color: const Color(0xFF66BB6A),
                      trend: 'down',
                      trendValue: '-15',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SensorCard(
                      title: 'PM2.5',
                      value: '12',
                      unit: 'μg/m³',
                      icon: Icons.grain,
                      color: const Color(0xFFAB47BC),
                      trend: 'up',
                      trendValue: '+3',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // VOC and Ozone Row
              Row(
                children: [
                  Expanded(
                    child: SensorCard(
                      title: 'VOC',
                      value: '0.8',
                      unit: 'ppb',
                      icon: Icons.cloud,
                      color: const Color(0xFF26A69A),
                      trend: 'stable',
                      trendValue: '0.0',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SensorCard(
                      title: 'Ozone',
                      value: '35',
                      unit: 'ppb',
                      icon: Icons.shield,
                      color: const Color(0xFF5C6BC0),
                      trend: 'down',
                      trendValue: '-2',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Motion & Sound Section
              const Text(
                'Motion & Sound',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 16),

              // Motion and Sound Row
              Row(
                children: [
                  Expanded(
                    child: SensorCard(
                      title: 'Motion',
                      value: 'No',
                      unit: 'Activity',
                      icon: Icons.directions_run,
                      color: const Color(0xFF78909C),
                      trend: 'stable',
                      trendValue: '0',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SensorCard(
                      title: 'Sound',
                      value: '42',
                      unit: 'dB',
                      icon: Icons.volume_up,
                      color: const Color(0xFFFF7043),
                      trend: 'up',
                      trendValue: '+5',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Handle export data
                        print('Export data');
                      },
                      icon: const Icon(Icons.download, color: Colors.white),
                      label: const Text(
                        'Export Data',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D986A),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Handle view history
                        print('View history');
                      },
                      icon: const Icon(Icons.history, color: Color(0xFF0D986A)),
                      label: const Text(
                        'View History',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0D986A),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF0D986A)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
