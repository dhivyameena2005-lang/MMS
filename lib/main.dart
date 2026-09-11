import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MMSApp());
}

class MMSApp extends StatelessWidget {
  const MMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MMS - Mushroom Monitoring System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Unga Blynk Token direct-ah configure panniyachu
  final String blynkAuthToken = "i6GwbB4bd7XVAGqktY38JVGRle6jaF8i";

  final String tempPin = "V0";
  final String humPin = "V1";
  final String relayPin = "V2";

  double temperature = 0.0;
  double humidity = 0.0;
  bool isHumidifierOn = false;
  bool isOnline = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchBlynkData();
    // Ovvoru 2 seconds-kum Blynk data live sync
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _fetchBlynkData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Live sensor data fetch function
  Future<void> _fetchBlynkData() async {
    try {
      final tempUrl = Uri.parse(
        'https://blynk.cloud/external/api/get?token=$blynkAuthToken&$tempPin',
      );
      final humUrl = Uri.parse(
        'https://blynk.cloud/external/api/get?token=$blynkAuthToken&$humPin',
      );
      final relayUrl = Uri.parse(
        'https://blynk.cloud/external/api/get?token=$blynkAuthToken&$relayPin',
      );

      final tempRes = await http.get(tempUrl);
      final humRes = await http.get(humUrl);
      final relayRes = await http.get(relayUrl);

      if (tempRes.statusCode == 200 && humRes.statusCode == 200) {
        setState(() {
          temperature = double.tryParse(tempRes.body) ?? 0.0;
          humidity = double.tryParse(humRes.body) ?? 0.0;
          isHumidifierOn = (relayRes.body.trim() == "1");
          isOnline = true;
        });
      }
    } catch (e) {
      debugPrint("Error connecting to Blynk: $e");
    }
  }

  // Switch toggle panna Relay control
  Future<void> _toggleHumidifier(bool value) async {
    setState(() {
      isHumidifierOn = value;
    });

    final val = value ? "1" : "0";
    final updateUrl = Uri.parse(
      'https://blynk.cloud/external/api/update?token=$blynkAuthToken&$relayPin=$val',
    );

    try {
      await http.get(updateUrl);
    } catch (e) {
      debugPrint("Error updating relay: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: const Text(
          'MMS Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mushroom Chamber Live Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      color: isOnline ? Colors.green : Colors.red,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        color: isOnline ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Temperature Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.thermostat,
                        color: Colors.deepOrange,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Temperature',
                          style: TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                        Text(
                          '$temperature °C',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Humidity Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.water_drop,
                        color: Colors.blueAccent,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Humidity',
                          style: TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                        Text(
                          '$humidity %',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Humidifier Switch Card
            Card(
              elevation: 3,
              color: isHumidifierOn ? const Color(0xFFE0F2F1) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 12.0,
                ),
                child: SwitchListTile(
                  secondary: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                          isHumidifierOn ? Colors.teal : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.air,
                      color:
                          isHumidifierOn ? Colors.white : Colors.grey.shade700,
                      size: 28,
                    ),
                  ),
                  title: const Text(
                    'Humidifier Control',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    isHumidifierOn ? 'Humidifier: ON' : 'Humidifier: OFF',
                    style: TextStyle(
                      color:
                          isHumidifierOn ? Colors.teal.shade800 : Colors.grey,
                    ),
                  ),
                  value: isHumidifierOn,
                  onChanged: _toggleHumidifier,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
