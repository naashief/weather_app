import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Result extends StatefulWidget {
  final String place;

  const Result({super.key, required this.place});

  @override
  State<Result> createState() => _ResultState();
}

class _ResultState extends State<Result> {
  Map<String, double>? _coordsToReturn;

  Future<Map<String, dynamic>> getDataFromAPI() async {
    final response = await http.get(
      Uri.parse(
          "http://api.openweathermap.org/data/2.5/weather?q=${widget.place}&APPID=d4737b2352783802fed06a5f3dfa870b&units=metric",
      ),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.containsKey('coord') &&
          data['coord'].containsKey('lat') &&
          data['coord'].containsKey('lon')) {
        _coordsToReturn = {
          'lat': (data['coord']['lat'] as num).toDouble(),
          'lon': (data['coord']['lon'] as num).toDouble(),
        };
      }
      return data;
    } else {
      throw Exception("Error API: ${response.statusCode}");
    }
  }

  IconData getWeatherIcon(String weatherMain) {
    switch (weatherMain.toLowerCase()) {
      case 'clouds': return Icons.cloud;
      case 'rain': return Icons.umbrella;
      case 'clear': return Icons.wb_sunny;
      case 'snow': return Icons.ac_unit;
      case 'thunderstorm': return Icons.flash_on;
      case 'drizzle': return Icons.grain;
      case 'mist': case 'smoke': case 'haze': case 'dust': case 'fog':
      case 'sand': case 'ash': case 'squall': case 'tornado':
      return Icons.cloud_outlined;
      default: return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Hasil Pencarian", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blueAccent,
          centerTitle: true,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context, _coordsToReturn);
            },
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        body: WillPopScope(
          onWillPop: () async {
            Navigator.pop(context, _coordsToReturn);
            return true;
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            alignment: Alignment.center,
            child: FutureBuilder(
              future: getDataFromAPI(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color.fromARGB(255, 128, 2, 255),
                      strokeAlign: 5,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Gagal memuat data: ${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, color: Colors.red),
                    ),
                  );
                }
                if (snapshot.hasData) {
                  final data = snapshot.data!;
                  final String weatherCondition = data["weather"][0]["main"];
                  final IconData weatherIcon = getWeatherIcon(weatherCondition);
                  final String cityName = data["name"] ?? "Tidak diketahui";
                  final double temp = (data["main"]["temp"] as num?)?.toDouble() ?? 0.0;
                  final int humidity = (data["main"]["humidity"] as num?)?.toInt() ?? 0;
                  final double windSpeed = (data["wind"]["speed"] as num?)?.toDouble() ?? 0.0;


                  return SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          cityName,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Icon(
                          weatherIcon,
                          size: 70.0,
                          color: Colors.orangeAccent,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${temp.toStringAsFixed(1)}°C",
                          style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          weatherCondition,
                          style: const TextStyle(fontSize: 22, fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Kelembaban: $humidity%",
                          style: const TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Kecepatan angin: ${windSpeed.toStringAsFixed(1)} m/s",
                          style: const TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                } else {
                  return const Center(
                    child: Text(
                      "Lokasi Tidak Ditemukan",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

