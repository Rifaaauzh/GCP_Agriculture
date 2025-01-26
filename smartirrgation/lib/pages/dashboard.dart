import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool isPumpOn = false;

  // Real-time sensor data variables
  double waterLevel = 0.0;
  double soilMoisture = 0.0;
  double temperature = 0.0;
  double humidity = 0.0;
  bool isRaining = false;

  // Fetch sensor data from the backend
  Future<void> fetchSensorData() async {
    try {
      final response = await http.get(Uri.parse('http://35.239.22.140:5000/agriculture/sensors'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          waterLevel = data['water_level'];
          soilMoisture = data['soil_moisture'];
          temperature = data['temperature'];
          humidity = data['humidity'];
          isRaining = data['rain_status'] == 'Raining';
        });
      } else {
        print('Failed to fetch sensor data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching sensor data: $e');
    }
  }

  // Toggle the water pump
  Future<void> togglePump(bool value) async {
    try {
      final response = await http.post(
        Uri.parse('http://35.239.22.140:5000/agriculture/relay'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'device': 'water_pump', 'command': value ? 'ON' : 'OFF'}),
      );

      if (response.statusCode == 200) {
        setState(() {
          isPumpOn = value;
        });
        print('Pump state updated successfully.');
      } else {
        print('Failed to update pump state. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating pump state: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSensorData(); // Fetch sensor data when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Agriculture Dashboard'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7B1FA2), Color(0xFF512DA8)], // Purple gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: fetchSensorData, // Pull-to-refresh for real-time updates
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Water Pump Control
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
                child: ListTile(
                  leading: const Icon(Icons.power, color: Color(0xFF7B1FA2), size: 30),
                  title: const Text(
                    'Water Pump',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    isPumpOn ? 'Status: ON' : 'Status: OFF',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: Switch(
                    value: isPumpOn,
                    onChanged: (value) {
                      togglePump(value); // Backend logic for pump control
                    },
                    activeColor: const Color(0xFF7B1FA2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Sensor Cards
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildSensorCard('Water Level', '$waterLevel%', Icons.water_drop),
                    _buildSensorCard('Soil Moisture', '$soilMoisture%', Icons.grass),
                    _buildSensorCard('Temperature', '$temperature°C', Icons.thermostat),
                    _buildSensorCard('Humidity', '$humidity%', Icons.cloud),
                    _buildSensorCard(
                      'Rain Sensor',
                      isRaining ? 'Raining' : 'No Rain',
                      Icons.beach_access,
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

  Widget _buildSensorCard(String title, String value, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF7B1FA2), size: 40), // Modern purple color
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}