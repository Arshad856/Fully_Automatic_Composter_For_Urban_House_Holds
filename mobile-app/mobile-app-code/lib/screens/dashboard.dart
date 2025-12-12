import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'threshold_screen.dart';
import 'ControlScreen.dart';

class _MachineStatusCard extends StatelessWidget {
  const _MachineStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF122516).withOpacity(0.9),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF1D3B24).withOpacity(0.7)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.55),
            offset: Offset(0, 26),
            blurRadius: 60,
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
                'Machine Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1CFF5A),
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1CFF5A).withOpacity(0.25),
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Running',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1CFF5A),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF1CFF5A).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.autorenew_rounded,
                  color: Color(0xFF1CFF5A),
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Overall Operation',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF7C8E81),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Mixing Cycle Active',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0B2211).withOpacity(0.85),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          height: 44,
          width: 44,
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color activeColor = const Color(0xFF1CFF5A);
    final Color inactiveColor = const Color(0xFF7C8E81);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color:
                isActive ? activeColor.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? activeColor : inactiveColor,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isActive ? activeColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref('Current_Sensor_Reading');

  Map<String, Map<String, String>> chamberData = {};
  String currentDateFormatted = '--';
  String currentTimeFormatted = '--';

  @override
  void initState() {
    super.initState();
    _listenToFirebase();
  }

  void _listenToFirebase() {
    _dbRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return;

      Map<String, Map<String, String>> parsedData = {};

      // Extract and format date and time
      final rawDate = data['Current_Date'] ?? '';
      final rawTime = data['Current_Time'] ?? '';

      if (rawDate.length == 6 || rawDate.length == 8) {
        // Example: "010825" or "01082025"
        final day = rawDate.substring(0, 2);
        final month = rawDate.substring(2, 4);
        final year = rawDate.length == 8
            ? rawDate.substring(4, 8)
            : '20${rawDate.substring(4)}';

        final months = {
          '01': 'Jan',
          '02': 'Feb',
          '03': 'Mar',
          '04': 'Apr',
          '05': 'May',
          '06': 'Jun',
          '07': 'Jul',
          '08': 'Aug',
          '09': 'Sep',
          '10': 'Oct',
          '11': 'Nov',
          '12': 'Dec'
        };
        final formattedDate = '$day ${months[month] ?? month} $year';
        currentDateFormatted = formattedDate;
      }

      if (rawTime.length == 6) {
        final hour = rawTime.substring(0, 2);
        final minute = rawTime.substring(2, 4);
        final second = rawTime.substring(4, 6);
        currentTimeFormatted = '$hour:$minute:$second';
      }

      for (int i = 1; i <= 4; i++) {
        final dht = data['dht$i'] ?? {};

        parsedData['$i'] = {
          'Temperature': '${dht['Temperature'] ?? '--'}°C',
          'Humidity': '${dht['Humidity'] ?? '--'}%',
          'Soil Moisture': '${data['Soil_Moisture$i'] ?? '--'}%',
          'Soil Temperature': '${data['temperature_ds$i'] ?? '--'}°C',
          'Level': '${data['Distance$i'] ?? '--'}',
        };
      }

      setState(() {
        chamberData = parsedData;
      });
    });
  }

  Widget _chamberCard(
    BuildContext context,
    String title,
    String status,
    Color statusColor,
    IconData statusIcon,
    List<Map<String, String>> readings,
  ) {
    const surfaceMuted = Color(0xFF122516);
    const borderDark = Color(0xFF1D3B24);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        splashColor: statusColor.withOpacity(0.1),
        highlightColor: statusColor.withOpacity(0.05),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ThresholdScreen(
              chamberName: title,
              metrics: readings,
            ),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: surfaceMuted.withOpacity(0.85),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderDark.withOpacity(0.7)),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.45),
                offset: Offset(0, 18),
                blurRadius: 45,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(5.5),
                    decoration: BoxDecoration(
                      color: statusColor
                          .withOpacity(status == 'Empty' ? 0.08 : 0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Icon(
                      statusIcon,
                      color: status == 'Empty' ? Colors.grey[400] : statusColor,
                      size: 17,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...readings.map((reading) {
                final label = reading['label'] ?? '';
                final value = reading['value'] ?? '--';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B2211),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _metricIcon(label),
                          size: 13,
                          color: Colors.grey[300],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          value,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  IconData _metricIcon(String label) {
    switch (label) {
      case 'Temperature':
        return Icons.device_thermostat;
      case 'Humidity':
        return Icons.water_drop;
      case 'Soil Moisture':
        return Icons.opacity;
      case 'Soil Temperature':
        return Icons.thermostat;
      case 'Level':
        return Icons.line_weight;
      default:
        return Icons.speed;
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1CFF5A);
    const accentBlue = Color(0xFF38BDF8);
    const emptyColor = Color(0xFF8D9B94);

    final chamberMeta = <Map<String, dynamic>>[
      {
        'status': 'Composting',
        'color': primaryColor,
        'icon': Icons.autorenew_rounded,
      },
      {
        'status': 'Curing',
        'color': primaryColor,
        'icon': Icons.hourglass_top_outlined,
      },
      {
        'status': 'Ready',
        'color': accentBlue,
        'icon': Icons.check_circle_rounded,
      },
      {
        'status': 'Empty',
        'color': emptyColor,
        'icon': Icons.radio_button_unchecked,
      },
    ];

    final chambers = List.generate(4, (index) {
      final i = index + 1;
      final data = chamberData['$i'] ??
          {
            'Temperature': '--',
            'Humidity': '--',
            'Soil Moisture': '--',
            'Soil Temperature': '--',
            'Level': '--',
          };

      final readings = <Map<String, String>>[
        {'label': 'Temperature', 'value': data['Temperature']!},
        {'label': 'Humidity', 'value': data['Humidity']!},
      ];

      if (i != 1) {
        readings
            .add({'label': 'Soil Moisture', 'value': data['Soil Moisture']!});
      }
      if (i == 2 || i == 3) {
        readings.add(
            {'label': 'Soil Temperature', 'value': data['Soil Temperature']!});
      }
      if (i == 1 || i == 4) {
        readings.add({'label': 'Level', 'value': data['Level']!});
      }

      return {
        'title': 'Cham  ${i.toString().padLeft(2, '0')}',
        'readings': readings,
      };
    });

    return Scaffold(
      backgroundColor: const Color(0xFF04150A),
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF05160C),
              Color(0xFF04150A),
              Color(0xFF020B05),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _CircleIconButton(
                          icon: Icons.menu_rounded,
                          onTap: () {},
                        ),
                        const Text(
                          'My EcoComposter',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        _CircleIconButton(
                          icon: Icons.notifications_none_rounded,
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: Color(0xFF7C8E81),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Updated: $currentDateFormatted · $currentTimeFormatted',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF7C8E81),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const _MachineStatusCard(),
                    const SizedBox(height: 28),
                    const Text(
                      'Chamber Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 18),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final maxWidth = constraints.maxWidth;
                        final crossAxisCount = maxWidth >= 330 ? 2 : 1;
                        final crossSpacing = crossAxisCount == 1 ? 0.0 : 10.0;
                        const mainSpacing = 12.0;
                        final itemWidth =
                            (maxWidth - (crossAxisCount - 1) * crossSpacing) /
                                crossAxisCount;
                        final heightMultiplier =
                            crossAxisCount == 1 ? 1.12 : 1.55;
                        final itemHeight = itemWidth * heightMultiplier +
                            (crossAxisCount == 1 ? 18 : 14);
                        final aspectRatio = itemWidth / itemHeight;

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: chambers.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: crossSpacing,
                            mainAxisSpacing: mainSpacing,
                            childAspectRatio: aspectRatio,
                          ),
                          itemBuilder: (context, index) {
                            final chamber = chambers[index];
                            final meta = chamberMeta[index];
                            return _chamberCard(
                              context,
                              chamber['title'] as String,
                              meta['status'] as String,
                              meta['color'] as Color,
                              meta['icon'] as IconData,
                              List<Map<String, String>>.from(
                                chamber['readings'] as List,
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: const Color(0xFF04150A),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 12,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              shadowColor:
                                  const Color.fromRGBO(28, 255, 90, 0.35),
                            ),
                            onPressed: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.add_circle_outline_rounded),
                                SizedBox(width: 8),
                                Text(
                                  'Add Scraps',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(
                                color: Color(0xFF1D3B24),
                                width: 1.1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              backgroundColor:
                                  const Color(0xFF122516).withOpacity(0.85),
                            ),
                            onPressed: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.outbox_outlined),
                                SizedBox(width: 8),
                                Text(
                                  'Empty Compost',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'View Cycle History',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                    const SizedBox(height: 96),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0B2211).withOpacity(0.92),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: const Color(0xFF1D3B24).withOpacity(0.7),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.6),
                offset: Offset(0, 18),
                blurRadius: 50,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BottomNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: true,
                onTap: () {},
              ),
              _BottomNavItem(
                icon: Icons.history_rounded,
                label: 'History',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ControlScreen()),
                  );
                },
              ),
              _BottomNavItem(
                icon: Icons.settings_rounded,
                label: 'Settings',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
