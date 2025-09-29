import 'package:intl/intl.dart';

class AirQuality {
  final int? aqi;
  final String city;
  final double? pm25;
  final double? temperature;
  final double? humidity;
  final double? windSpeed;
  final double? pressure;
  final List<DailyForecast> pm25Forecast; // เพิ่มข้อมูลพยากรณ์

  AirQuality({
    this.aqi,
    required this.city,
    this.pm25,
    this.temperature,
    this.humidity,
    this.windSpeed,
    this.pressure,
    required this.pm25Forecast, // เพิ่มข้อมูลพยากรณ์
  });

  factory AirQuality.fromJson(Map<String, dynamic> json) {
    // ฟังก์ชัน helper เพื่อดึงค่า value จาก object ที่ซ้อนกัน
    T? getValue<T>(Map<String, dynamic>? data, String key) {
      if (data != null && data.containsKey(key) && data[key] is Map) {
        final value = data[key]['v'];
        if (value is T) {
          return value;
        }
        // แปลง num (int/double) เป็น double
        if (value is num) {
          return value.toDouble() as T;
        }
      }
      return null;
    }

    // --- ส่วนของการดึงข้อมูลพยากรณ์ ---
    List<DailyForecast> parseForecast(Map<String, dynamic> json) {
      try {
        if (json['forecast'] != null &&
            json['forecast']['daily'] != null &&
            json['forecast']['daily']['pm25'] != null) {
          final List<dynamic> forecastData = json['forecast']['daily']['pm25'];
          // แปลง List<dynamic> เป็น List<DailyForecast> และเรียงตามวันที่
          return forecastData
              .map((item) => DailyForecast.fromJson(item))
              .toList()
              ..sort((a, b) => a.day.compareTo(b.day));
        }
      } catch (e) {
        // หากมี error ในการ parse ให้ return list ว่าง
        print('Error parsing forecast: $e');
      }
      return [];
    }

    return AirQuality(
      aqi: json['data']?['aqi'],
      city: json['data']?['city']?['name'] ?? 'Unknown City',
      pm25: getValue(json['data']?['iaqi'], 'pm25'),
      temperature: getValue(json['data']?['iaqi'], 't'),
      humidity: getValue(json['data']?['iaqi'], 'h'),
      windSpeed: getValue(json['data']?['iaqi'], 'w'),
      pressure: getValue(json['data']?['iaqi'], 'p'),
      pm25Forecast: parseForecast(json['data'] ?? {}), // เรียกใช้ฟังก์ชัน
    );
  }
}

// --- Model ใหม่สำหรับข้อมูลพยากรณ์แต่ละวัน ---
class DailyForecast {
  final DateTime day;
  final int avg;
  final int max;
  final int min;

  DailyForecast({
    required this.day,
    required this.avg,
    required this.max,
    required this.min,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      day: DateTime.tryParse(json['day'] ?? '') ?? DateTime.now(),
      avg: json['avg'] ?? 0,
      max: json['max'] ?? 0,
      min: json['min'] ?? 0,
    );
  }
}