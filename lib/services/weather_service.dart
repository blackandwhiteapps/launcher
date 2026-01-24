import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class WeatherData {
  final String? currentCondition;
  final double? currentTemp;
  final double? highTemp;
  final double? lowTemp;
  final String? locationName;
  final List<HourlyForecast> hourlyForecast;

  WeatherData({
    this.currentCondition,
    this.currentTemp,
    this.highTemp,
    this.lowTemp,
    this.locationName,
    this.hourlyForecast = const [],
  });
}

class HourlyForecast {
  final DateTime time;
  final double? temperature;
  final String? condition;
  final String? shortForecast;

  HourlyForecast({
    required this.time,
    this.temperature,
    this.condition,
    this.shortForecast,
  });
}

class WeatherService {
  static Future<Position?> _getCurrentPosition() async {
    // Check if location permission is granted
    final permission = await Permission.location.status;
    if (permission.isDenied) {
      final result = await Permission.location.request();
      if (!result.isGranted) {
        return null;
      }
    }

    if (permission.isPermanentlyDenied) {
      return null;
    }

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<WeatherData> getWeather() async {
    try {
      final position = await _getCurrentPosition();
      if (position == null) {
        return WeatherData();
      }

      // Round to 4 decimal places for weather.gov API
      final lat = position.latitude.toStringAsFixed(4);
      final lon = position.longitude.toStringAsFixed(4);

      // Step 1: Get grid point from coordinates
      final pointsResponse = await http.get(
        Uri.parse('https://api.weather.gov/points/$lat,$lon'),
        headers: {
          'User-Agent': 'LauncherApp/1.0 (noahtatko@gmail.com)',
        },
      );

      if (pointsResponse.statusCode != 200) {
        return WeatherData();
      }

      final pointsData = json.decode(pointsResponse.body);
      final properties = pointsData['properties'];
      final forecastUrl = properties['forecast'] as String?;
      final forecastHourlyUrl = properties['forecastHourly'] as String?;
      final locationName = properties['relativeLocation']?['properties']?['city'] as String? ??
          properties['relativeLocation']?['properties']?['areaDescription'] as String?;

      // Step 2: Get current conditions, daily forecast, and hourly forecast
      String? currentCondition;
      double? currentTemp;
      double? highTemp;
      double? lowTemp;
      List<HourlyForecast> hourlyForecast = [];

      // Get daily forecast first (for high/low temps)
      if (forecastUrl != null) {
        final forecastResponse = await http.get(
          Uri.parse(forecastUrl),
          headers: {
            'User-Agent': 'LauncherApp/1.0 (noahtatko@gmail.com)',
          },
        );

        if (forecastResponse.statusCode == 200) {
          final forecastData = json.decode(forecastResponse.body);
          final periods = forecastData['properties']?['periods'] as List?;

          if (periods != null && periods.isNotEmpty) {
            // Find today's high and low
            // Periods alternate between day and night
            // Today's day period should be first or second
            final now = DateTime.now();
            for (int i = 0; i < periods.length && i < 4; i++) {
              final period = periods[i];
              final startTime = period['startTime'] as String?;
              final isDaytime = period['isDaytime'] as bool? ?? true;
              final temp = (period['temperature'] as num?)?.toDouble();
              
              if (startTime != null) {
                final periodTime = DateTime.parse(startTime);
                // Check if this period is today
                if (periodTime.year == now.year &&
                    periodTime.month == now.month &&
                    periodTime.day == now.day) {
                  if (isDaytime && temp != null) {
                    // This is today's day period - use as high
                    highTemp = temp;
                    if (currentTemp == null) {
                      currentTemp = temp;
                    }
                    if (currentCondition == null) {
                      currentCondition = period['shortForecast'] as String?;
                    }
                  } else if (!isDaytime && temp != null) {
                    // This is today's night period - use as low
                    lowTemp = temp;
                  }
                }
              }
            }
            
            // If we didn't find today's temps, use first day period as high
            // and first night period as low (they might be for today)
            if (highTemp == null || lowTemp == null) {
              for (int i = 0; i < periods.length && i < 4; i++) {
                final period = periods[i];
                final isDaytime = period['isDaytime'] as bool? ?? true;
                final temp = (period['temperature'] as num?)?.toDouble();
                
                if (temp != null) {
                  if (isDaytime && highTemp == null) {
                    highTemp = temp;
                  } else if (!isDaytime && lowTemp == null) {
                    lowTemp = temp;
                  }
                }
              }
            }
            
            // If we still don't have current condition, use first period
            if (currentCondition == null && periods.isNotEmpty) {
              final first = periods[0];
              currentCondition = first['shortForecast'] as String?;
            }
          }
        }
      }

      // Get hourly forecast for current temp and hourly data
      if (forecastHourlyUrl != null) {
        final hourlyResponse = await http.get(
          Uri.parse(forecastHourlyUrl),
          headers: {
            'User-Agent': 'LauncherApp/1.0 (noahtatko@gmail.com)',
          },
        );

        if (hourlyResponse.statusCode == 200) {
          final hourlyData = json.decode(hourlyResponse.body);
          final periods = hourlyData['properties']?['periods'] as List?;

          if (periods != null && periods.isNotEmpty) {
            // Current condition and temp from first period
            final current = periods[0];
            if (currentCondition == null) {
              currentCondition = current['shortForecast'] as String?;
            }
            if (currentTemp == null) {
              currentTemp = (current['temperature'] as num?)?.toDouble();
            }

            // Get next 12 hours of forecast
            final forecastCount = periods.length > 12 ? 12 : periods.length;
            for (int i = 0; i < forecastCount; i++) {
              final period = periods[i];
              final startTime = period['startTime'] as String?;
              if (startTime != null) {
                hourlyForecast.add(HourlyForecast(
                  time: DateTime.parse(startTime),
                  temperature: (period['temperature'] as num?)?.toDouble(),
                  condition: period['shortForecast'] as String?,
                  shortForecast: period['shortForecast'] as String?,
                ));
              }
            }
          }
        }
      }

      return WeatherData(
        currentCondition: currentCondition,
        currentTemp: currentTemp,
        highTemp: highTemp,
        lowTemp: lowTemp,
        locationName: locationName,
        hourlyForecast: hourlyForecast,
      );
    } catch (e) {
      return WeatherData();
    }
  }
}


