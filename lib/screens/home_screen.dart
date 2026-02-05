// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late MapController _mapController;
  final TextEditingController _searchController = TextEditingController();

  /// Geoapify API Key
  static const String GEOAPIFY_API_KEY = '452b27c765e840358ee7ad7ee57339e3';

  /// Map Styles
  static const String CARTO = 'carto';
  static const String CARTO_DARK = 'carto-dark';
  static const String POSITRON = 'positron';
  static const String VOYAGER = 'voyager';

  LatLng _currentPosition = const LatLng(37.7749, -122.4194);
  final LatLng _initialPosition = const LatLng(37.7749, -122.4194);

  String _currentStyle = CARTO;

  final List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _searchController.text = "San Francisco";

    _markers.addAll([
      _buildMarker(const LatLng(37.7749, -122.4194), Colors.red),
      _buildMarker(const LatLng(37.7799, -122.4294), Colors.blue),
      _buildMarker(const LatLng(37.7699, -122.4094), Colors.orange),
    ]);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Tile URL
  String _tileUrl() {
    return 'https://maps.geoapify.com/v1/tile/$_currentStyle/{z}/{x}/{y}.png?apiKey=$GEOAPIFY_API_KEY';
  }

  /// Marker Builder
  Marker _buildMarker(LatLng point, Color color) {
    return Marker(
      point: point,
      width: 40,
      height: 40,
      child: Icon(Icons.location_on, color: color, size: 36),
    );
  }

  /// Current Location
  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _showSnackBar("Location permission denied");
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final latLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _currentPosition = latLng;
      _markers.add(_buildMarker(latLng, Colors.pink));
    });

    _mapController.move(latLng, 15);
  }

  /// Search Location
  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    final response = await http.get(
      Uri.parse(
        'https://api.geoapify.com/v1/geocode/search?text=$query&apiKey=$GEOAPIFY_API_KEY',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['features'].isNotEmpty) {
        final coords = data['features'][0]['geometry']['coordinates'];
        final latLng = LatLng(coords[1], coords[0]);

        setState(() {
          _currentPosition = latLng;
          _markers.add(_buildMarker(latLng, Colors.green));
        });

        _mapController.move(latLng, 13);
      }
    }
  }

  void _changeMapStyle(String style) {
    setState(() => _currentStyle = style);
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Peiway Map")),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialPosition,
              initialZoom: 13,
              minZoom: 3,
              maxZoom: 19,
            ),
            children: [
              TileLayer(
                urlTemplate: _tileUrl(),
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(markers: _markers),
            ],
          ),

          /// Search Bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: "Search city or place",
                        prefixIcon: Icon(Icons.search),
                      ),
                      onSubmitted: _searchLocation,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _currentStyle,
                      items: const [
                        DropdownMenuItem(value: CARTO, child: Text("Carto")),
                        DropdownMenuItem(
                          value: CARTO_DARK,
                          child: Text("Carto Dark"),
                        ),
                        DropdownMenuItem(
                          value: POSITRON,
                          child: Text("Positron"),
                        ),
                        DropdownMenuItem(
                          value: VOYAGER,
                          child: Text("Voyager"),
                        ),
                      ],
                      onChanged: (v) => _changeMapStyle(v!),
                      decoration: const InputDecoration(labelText: "Map Style"),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// Location Button
          Positioned(
            bottom: 24,
            right: 16,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
