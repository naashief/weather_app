import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:weather_app/pages/result.dart';


class WeatherData {
  final String cityName;
  final double temperature;
  final String condition;
  final int humidity;
  final double windSpeed;
  final String iconCode;

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.iconCode,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      cityName: json['name'],
      temperature: (json['main']['temp'] as num).toDouble(),
      condition: json['weather'][0]['main'],
      humidity: json['main']['humidity'],
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      iconCode: json['weather'][0]['icon'],
    );
  }
}


class SearchField extends StatefulWidget {
  final String? initialPlace;
  final double? initialLat;
  final double? initialLon;

  const SearchField({
    super.key,
    this.initialPlace = "Jakarta",
    this.initialLat,
    this.initialLon,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  TextEditingController placeController = TextEditingController();
  WeatherData? _currentWeather;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLon != null) {
      _fetchWeatherDataByCoords(widget.initialLat!, widget.initialLon!);
    } else if (widget.initialPlace != null) {
      _fetchWeatherDataByPlace(widget.initialPlace!);
    }
  }
  IconData getWeatherIcon(String iconCode) {
    switch (iconCode) {
      case '01d': return Icons.wb_sunny;
      case '01n': return Icons.nightlight_round;
      case '02d': case '02n': return Icons.cloud;
      case '03d': case '03n': return Icons.cloud_queue;
      case '04d': case '04n': return Icons.cloud_done;
      case '09d': case '09n': return Icons.umbrella;
      case '10d': return Icons.beach_access;
      case '10n': return Icons.umbrella;
      case '11d': case '11n': return Icons.flash_on;
      case '13d': case '13n': return Icons.ac_unit;
      case '50d': case '50n': return Icons.cloud_outlined;
      default: return Icons.help_outline;
    }
  }

  Future<void> _fetchWeatherDataByPlace(String place) async {
    if (place.isEmpty) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentWeather = null;
    });
    try {
      final response = await http.get(
        Uri.parse(
          "http://api.openweathermap.org/data/2.5/weather?q=$place&APPID=d4737b2352783802fed06a5f3dfa870b&units=metric",
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _currentWeather = WeatherData.fromJson(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Lokasi tidak ditemukan atau error API (${response.statusCode})";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Gagal mengambil data: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchWeatherDataByCoords(double lat, double lon) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentWeather = null;
    });
    try {
      final response = await http.get(
        Uri.parse(
          "http://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&APPID=d4737b2352783802fed06a5f3dfa870b&units=metric",
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _currentWeather = WeatherData.fromJson(data);
          placeController.text = _currentWeather?.cityName ?? "";
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Data koordinat tidak valid atau error API (${response.statusCode})";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Gagal mengambil data: $e";
        _isLoading = false;
      });
    }
  }

  void _navigateToResultAndRefresh(String place) async {
    final Map<String, double>? newCoords = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => Result(place: place),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );

    if (newCoords != null && newCoords.containsKey('lat') && newCoords.containsKey('lon')) {
      _fetchWeatherDataByCoords(newCoords['lat']!, newCoords['lon']!);
    } else if (_currentWeather == null && widget.initialPlace != null && placeController.text.isEmpty) {
      _fetchWeatherDataByPlace(widget.initialPlace!);
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Cuaca", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blueAccent,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: "Cari lokasi...",
                        border: OutlineInputBorder(),
                      ),
                      controller: placeController,
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          _navigateToResultAndRefresh(value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      if (placeController.text.isNotEmpty) {
                        _navigateToResultAndRefresh(placeController.text);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Masukkan nama lokasi')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
                    ),
                    child: const Text("Cari"),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              if (_isLoading)
                const CircularProgressIndicator()
              else if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center,)
              else if (_currentWeather != null)
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Cuaca saat ini di:",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                          ),
                          Text(
                            _currentWeather!.cityName,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Icon(
                            getWeatherIcon(_currentWeather!.iconCode),
                            size: 64.0,
                            color: Colors.orangeAccent,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "${_currentWeather!.temperature.toStringAsFixed(1)}°C",
                            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _currentWeather!.condition,
                            style: const TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Icon(Icons.water_drop_outlined, color: Colors.blue),
                                  Text("Kelembaban"),
                                  Text("${_currentWeather!.humidity}%"),
                                ],
                              ),
                              Column(
                                children: [
                                  Icon(Icons.air, color: Colors.lightBlueAccent),
                                  Text("Angin"),
                                  Text("${_currentWeather!.windSpeed} m/s"),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  const Text("Masukkan lokasi untuk melihat cuaca.", textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
