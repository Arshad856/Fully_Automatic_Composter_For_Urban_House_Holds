import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/sensor_card.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/header_section.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            const HeaderSection(),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Text
                    Text(
                      'Welcome Back',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Monitor your garden sensors',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Sensor Cards Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                      children: const [
                        SensorCard(
                          title: 'Temperature',
                          value: '24°C',
                          subtitle: 'Current temp',
                          color: Color(0xFF98C13F),
                          icon: Icons.thermostat,
                        ),
                        SensorCard(
                          title: 'Humidity',
                          value: '65%',
                          subtitle: 'Air moisture',
                          color: Color(0xFF159148),
                          icon: Icons.water_drop,
                        ),
                        SensorCard(
                          title: 'Soil Moisture',
                          value: '45%',
                          subtitle: 'Soil hydration',
                          color: Color(0xFF0D986A),
                          icon: Icons.grass,
                        ),
                        SensorCard(
                          title: 'Light Level',
                          value: '850 lux',
                          subtitle: 'Brightness',
                          color: Color(0xFFFFB800),
                          icon: Icons.wb_sunny,
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Recent Activity Section
                    Text(
                      'Recent Activity',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Activity List
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildActivityItem(
                            'Watering completed',
                            '2 hours ago',
                            Icons.water,
                            const Color(0xFF159148),
                          ),
                          const Divider(height: 1),
                          _buildActivityItem(
                            'Temperature alert',
                            '4 hours ago',
                            Icons.warning,
                            Colors.orange,
                          ),
                          const Divider(height: 1),
                          _buildActivityItem(
                            'Sensor data updated',
                            '6 hours ago',
                            Icons.sensors,
                            const Color(0xFF98C13F),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildActivityItem(
      String title, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
