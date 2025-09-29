import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'models/air_quality.dart';
import 'services/api_service.dart';

// --- ค่าสีสำหรับดีไซน์ Neumorphic ---
const kBackgroundColor = Color(0xFFE0E5EC);
const kDarkShadowColor = Color(0xFFA3B1C6);
const kLightShadowColor = Color(0xFFFFFFFF);

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AQI Checker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: kBackgroundColor,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ApiService api;
  Future<AirQuality>? _airQualityFuture;

  @override
  void initState() {
    super.initState();
    api = ApiService();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _airQualityFuture = api.fetchAirQuality("Bangkok");
    });
  }

  Color _getAqiColor(int? aqi) {
    if (aqi == null) return Colors.grey.shade700;
    if (aqi <= 50) return const Color(0xFF4CAF50);
    if (aqi <= 100) return const Color(0xFFFFC107);
    if (aqi <= 150) return const Color(0xFFFB8C00);
    if (aqi <= 200) return const Color(0xFFF44336);
    if (aqi <= 300) return const Color(0xFF8E24AA);
    return const Color(0xFF795548);
  }

  String _getAqiLabel(int? aqi) {
    if (aqi == null) return 'Unknown';
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive Groups';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _fetchData(),
          child: FutureBuilder<AirQuality>(
            future: _airQualityFuture,
            builder: (context, snapshot) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _buildContent(snapshot),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(AsyncSnapshot<AirQuality> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
          key: ValueKey('loading'), child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return _buildErrorState(snapshot.error);
    }
    if (!snapshot.hasData) {
      return const Center(
          key: ValueKey('no_data'), child: Text('No data available.'));
    }

    final data = snapshot.data!;
    final aqiColor = _getAqiColor(data.aqi);

    return SingleChildScrollView(
      key: const ValueKey('data'),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildHeader(data), // Header ที่มีปุ่ม Refresh
            ),
            const SizedBox(height: 40),
            _buildAqiGauge(data, aqiColor),
            const SizedBox(height: 40),
            if (data.pm25Forecast.isNotEmpty)
              _buildForecastSection(data.pm25Forecast),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildDetailsSection(data, aqiColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    return Container(
      key: const ValueKey('error'),
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, color: Colors.grey, size: 80),
            const SizedBox(height: 20),
            Text('Failed to load data',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800)),
            const SizedBox(height: 8),
            Text('$error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: _fetchData,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Text('Try Again',
                    style: TextStyle(color: Colors.white))),
          ],
        ),
      ),
    );
  }

  // --- Widget ส่วนหัวที่ได้รับการอัปเดต ---
  Widget _buildHeader(AirQuality data) {
    final now = DateFormat('EEEE, hh:mm a').format(DateTime.now());
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Column สำหรับชื่อเมืองและวันที่
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data.city,
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800)),
            const SizedBox(height: 4),
            Text('Updated on $now',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          ],
        ),
        // ปุ่ม Refresh ที่เพิ่มเข้ามาใหม่
        _buildNeumorphicIconButton(
          icon: Icons.refresh,
          onTap: _fetchData, // เมื่อกดให้เรียก _fetchData
        ),
      ],
    );
  }

  // --- Widget ใหม่สำหรับสร้างปุ่ม Refresh ---
  Widget _buildNeumorphicIconButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
            color: kBackgroundColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: kDarkShadowColor, offset: Offset(4, 4), blurRadius: 8),
              BoxShadow(
                  color: kLightShadowColor,
                  offset: Offset(-4, -4),
                  blurRadius: 8)
            ]),
        child: Icon(icon, color: Colors.grey.shade700),
      ),
    );
  }

  Widget _buildAqiGauge(AirQuality data, Color aqiColor) {
    return Container(
      width: 220,
      height: 220,
      decoration: const BoxDecoration(
          color: kBackgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: kDarkShadowColor, offset: Offset(8, 8), blurRadius: 15),
            BoxShadow(
                color: kLightShadowColor,
                offset: Offset(-8, -8),
                blurRadius: 15)
          ]),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${data.aqi ?? '-'}',
                style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: aqiColor)),
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: aqiColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12)),
                child: Text(_getAqiLabel(data.aqi),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: aqiColor)))
          ],
        ),
      ),
    );
  }

  Widget _buildForecastSection(List<DailyForecast> forecast) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text("Weekly Forecast",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800)),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: forecast.length > 7 ? 7 : forecast.length,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemBuilder: (context, index) {
              final dayForecast = forecast[index];
              return _buildForecastTile(dayForecast);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildForecastTile(DailyForecast dayForecast) {
    final dayOfWeek = DateFormat('E').format(dayForecast.day).toUpperCase();
    final aqiColor = _getAqiColor(dayForecast.avg);
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: kDarkShadowColor, offset: Offset(4, 4), blurRadius: 8),
          BoxShadow(
              color: kLightShadowColor, offset: Offset(-4, -4), blurRadius: 8)
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(dayOfWeek,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600)),
          const SizedBox(height: 12),
          Text('${dayForecast.avg}',
              style:
                  TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: aqiColor)),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(AirQuality data, Color aqiColor) {
    return Column(
      children: [
        _buildInfoTile(
            icon: Icons.grain,
            label: 'PM2.5',
            value: '${data.pm25?.toStringAsFixed(1) ?? '-'} µg/m³',
            iconColor: aqiColor),
        const SizedBox(height: 16),
        _buildInfoTile(
            icon: Icons.thermostat,
            label: 'Temperature',
            value: '${data.temperature?.toStringAsFixed(1) ?? '-'} °C',
            iconColor: Colors.redAccent),
        const SizedBox(height: 16),
        _buildInfoTile(
            icon: Icons.opacity,
            label: 'Humidity',
            value: '${data.humidity?.toStringAsFixed(1) ?? '-'} %',
            iconColor: Colors.blueAccent),
        const SizedBox(height: 16),
        _buildInfoTile(
            icon: Icons.air,
            label: 'Wind Speed',
            value: '${data.windSpeed?.toStringAsFixed(1) ?? '-'} m/s',
            iconColor: Colors.teal),
      ],
    );
  }

  Widget _buildInfoTile(
      {required IconData icon,
      required String label,
      required String value,
      required Color iconColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
          color: kBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                color: kDarkShadowColor, offset: Offset(5, 5), blurRadius: 10),
            BoxShadow(
                color: kLightShadowColor,
                offset: Offset(-5, -5),
                blurRadius: 10)
          ]),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              Text(value,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800))
            ],
          )
        ],
      ),
    );
  }
}

