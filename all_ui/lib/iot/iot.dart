// pubspec.yaml dependencies:
// flutter_riverpod: ^2.4.9
// go_router: ^12.1.3
// fl_chart: ^0.65.0
// google_fonts: ^6.1.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

// Models
class SmartDevice {
  final String id;
  final String name;
  final String type;
  final bool isOnline;
  final bool isActive;
  final String room;
  final String icon;
  final double? value;
  final String? unit;

  SmartDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.isOnline,
    required this.isActive,
    required this.room,
    required this.icon,
    this.value,
    this.unit,
  });

  SmartDevice copyWith({
    String? id,
    String? name,
    String? type,
    bool? isOnline,
    bool? isActive,
    String? room,
    String? icon,
    double? value,
    String? unit,
  }) {
    return SmartDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isOnline: isOnline ?? this.isOnline,
      isActive: isActive ?? this.isActive,
      room: room ?? this.room,
      icon: icon ?? this.icon,
      value: value ?? this.value,
      unit: unit ?? this.unit,
    );
  }
}

class EnergyData {
  final DateTime date;
  final double consumption;

  EnergyData({required this.date, required this.consumption});
}

// Providers
final devicesProvider = StateProvider<List<SmartDevice>>(
  (ref) => [
    SmartDevice(
      id: '1',
      name: 'Living Room Lights',
      type: 'light',
      isOnline: true,
      isActive: true,
      room: 'Living Room',
      icon: '💡',
      value: 75,
      unit: '%',
    ),
    SmartDevice(
      id: '2',
      name: 'Smart Thermostat',
      type: 'thermostat',
      isOnline: true,
      isActive: true,
      room: 'Living Room',
      icon: '🌡️',
      value: 22,
      unit: '°C',
    ),
    SmartDevice(
      id: '3',
      name: 'Security Camera',
      type: 'camera',
      isOnline: true,
      isActive: true,
      room: 'Front Door',
      icon: '📹',
    ),
    SmartDevice(
      id: '4',
      name: 'Smart Lock',
      type: 'lock',
      isOnline: true,
      isActive: false,
      room: 'Front Door',
      icon: '🔒',
    ),
    SmartDevice(
      id: '5',
      name: 'Air Purifier',
      type: 'air_purifier',
      isOnline: true,
      isActive: true,
      room: 'Bedroom',
      icon: '🌪️',
      value: 85,
      unit: '%',
    ),
    SmartDevice(
      id: '6',
      name: 'Smart Speaker',
      type: 'speaker',
      isOnline: false,
      isActive: false,
      room: 'Kitchen',
      icon: '🔊',
    ),
  ],
);

final energyDataProvider = Provider<List<EnergyData>>(
  (ref) => [
    EnergyData(
      date: DateTime.now().subtract(Duration(days: 6)),
      consumption: 45,
    ),
    EnergyData(
      date: DateTime.now().subtract(Duration(days: 5)),
      consumption: 52,
    ),
    EnergyData(
      date: DateTime.now().subtract(Duration(days: 4)),
      consumption: 38,
    ),
    EnergyData(
      date: DateTime.now().subtract(Duration(days: 3)),
      consumption: 67,
    ),
    EnergyData(
      date: DateTime.now().subtract(Duration(days: 2)),
      consumption: 43,
    ),
    EnergyData(
      date: DateTime.now().subtract(Duration(days: 1)),
      consumption: 59,
    ),
    EnergyData(date: DateTime.now(), consumption: 41),
  ],
);

final selectedTabProvider = StateProvider<int>((ref) => 0);

// Custom Colors
class AppColors {
  static const primary = Color(0xFF6366F1);
  static const secondary = Color(0xFF8B5CF6);
  static const accent = Color(0xFF06B6D4);
  static const background = Color(0xFF0F172A);
  static const surface = Color(0xFF1E293B);
  static const surfaceLight = Color(0xFF334155);
  static const textPrimary = Color(0xFFF1F5F9);
  static const textSecondary = Color(0xFF94A3B8);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
}

// Main App
void main() {
  runApp(ProviderScope(child: SmartHomeApp()));
}

class SmartHomeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Home',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          background: AppColors.background,
        ),
      ),
      home: MainScreen(),
    );
  }
}

// Main Screen with Bottom Navigation
class MainScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);

    final screens = [
      HomeScreen(),
      DevicesScreen(),
      MonitoringScreen(),
      SettingsScreen(),
    ];

    return Scaffold(
      body: screens[selectedTab],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(Icons.home_rounded, 'Home', 0, ref),
                _buildNavItem(Icons.device_hub_rounded, 'Devices', 1, ref),
                _buildNavItem(Icons.analytics_rounded, 'Monitor', 2, ref),
                _buildNavItem(Icons.settings_rounded, 'Settings', 3, ref),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);
    final isSelected = selectedTab == index;

    return GestureDetector(
      onTap: () => ref.read(selectedTabProvider.notifier).state = index,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primary.withOpacity(0.2)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Home Screen
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(devicesProvider);
    final activeDevices = devices.where((d) => d.isActive).length;
    final onlineDevices = devices.where((d) => d.isOnline).length;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good Morning',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Sarah Johnson',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.notifications_rounded,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),

              // Quick Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Active Devices',
                      activeDevices.toString(),
                      AppColors.success,
                      Icons.power_rounded,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Online',
                      onlineDevices.toString(),
                      AppColors.accent,
                      Icons.wifi_rounded,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Quick Actions
              Text(
                'Quick Actions',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      'All Lights Off',
                      Icons.lightbulb_outline_rounded,
                      AppColors.warning,
                      () {},
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildActionCard(
                      'Secure Home',
                      Icons.security_rounded,
                      AppColors.error,
                      () {},
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Favorite Devices
              Text(
                'Favorite Devices',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              ...devices.take(3).map((device) => _buildDeviceCard(device, ref)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard(SmartDevice device, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              device.isActive
                  ? AppColors.primary.withOpacity(0.3)
                  : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  device.isActive
                      ? AppColors.primary.withOpacity(0.2)
                      : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(device.icon, style: TextStyle(fontSize: 24)),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  device.room,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (device.value != null) ...[
            Text(
              '${device.value}${device.unit}',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 12),
          ],
          Switch(
            value: device.isActive,
            onChanged:
                device.isOnline
                    ? (value) {
                      final devices = ref.read(devicesProvider);
                      final index = devices.indexWhere(
                        (d) => d.id == device.id,
                      );
                      if (index != -1) {
                        final updatedDevices = [...devices];
                        updatedDevices[index] = device.copyWith(
                          isActive: value,
                        );
                        ref.read(devicesProvider.notifier).state =
                            updatedDevices;
                      }
                    }
                    : null,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

// Devices Screen
class DevicesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(devicesProvider);
    final rooms = devices.map((d) => d.room).toSet().toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    'All Devices',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Devices List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20),
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  final roomDevices =
                      devices.where((d) => d.room == room).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          room,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...roomDevices.map(
                        (device) => _buildDeviceCard(device, ref),
                      ),
                      SizedBox(height: 20),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard(SmartDevice device, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              device.isActive
                  ? AppColors.primary.withOpacity(0.3)
                  : Colors.transparent,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      device.isActive
                          ? AppColors.primary.withOpacity(0.2)
                          : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(device.icon, style: TextStyle(fontSize: 24)),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color:
                                device.isOnline
                                    ? AppColors.success
                                    : AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          device.isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Switch(
                value: device.isActive,
                onChanged:
                    device.isOnline
                        ? (value) {
                          final devices = ref.read(devicesProvider);
                          final index = devices.indexWhere(
                            (d) => d.id == device.id,
                          );
                          if (index != -1) {
                            final updatedDevices = [...devices];
                            updatedDevices[index] = device.copyWith(
                              isActive: value,
                            );
                            ref.read(devicesProvider.notifier).state =
                                updatedDevices;
                          }
                        }
                        : null,
                activeColor: AppColors.primary,
              ),
            ],
          ),
          if (device.value != null) ...[
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Current: ${device.value}${device.unit}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    device.type.toUpperCase(),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// Monitoring Screen
class MonitoringScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final energyData = ref.watch(energyDataProvider);
    final devices = ref.watch(devicesProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Energy Monitoring',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),

              // Energy Chart
              Container(
                height: 300,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Energy Usage',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots:
                                  energyData.asMap().entries.map((e) {
                                    return FlSpot(
                                      e.key.toDouble(),
                                      e.value.consumption,
                                    );
                                  }).toList(),
                              isCurved: true,
                              color: AppColors.primary,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppColors.primary.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Today',
                      '${energyData.last.consumption.toInt()} kWh',
                      AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'This Week',
                      '${energyData.map((e) => e.consumption).reduce((a, b) => a + b).toInt()} kWh',
                      AppColors.accent,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Device Usage
              Text(
                'Device Usage',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              ...devices
                  .where((d) => d.value != null)
                  .map((device) => _buildUsageCard(device)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageCard(SmartDevice device) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(device.icon, style: TextStyle(fontSize: 24)),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  device.room,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${device.value}${device.unit}',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Settings Screen
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Settings',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),

              // Profile Section
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        'SJ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sarah Johnson',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'sarah.johnson@email.com',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.edit_rounded, color: AppColors.textSecondary),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Settings Options
              _buildSettingsTile(
                'Notifications',
                'Push notifications and alerts',
                Icons.notifications_rounded,
                () {},
              ),
              _buildSettingsTile(
                'Security',
                'Biometric login and privacy',
                Icons.security_rounded,
                () {},
              ),
              _buildSettingsTile(
                'Energy Settings',
                'Usage tracking and optimization',
                Icons.eco_rounded,
                () {},
              ),
              _buildSettingsTile(
                'Connected Devices',
                'Manage paired devices',
                Icons.devices_rounded,
                () {},
              ),
              _buildSettingsTile(
                'Automation',
                'Smart home routines and schedules',
                Icons.schedule_rounded,
                () {},
              ),
              _buildSettingsTile(
                'Data & Privacy',
                'Usage data and privacy controls',
                Icons.privacy_tip_rounded,
                () {},
              ),
              _buildSettingsTile(
                'Help & Support',
                'FAQs and contact support',
                Icons.help_rounded,
                () {},
              ),
              SizedBox(height: 30),

              // App Info
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      'Smart Home App',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Version 2.1.0',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: EdgeInsets.all(20),
        tileColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: AppColors.textSecondary,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}
