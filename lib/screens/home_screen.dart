// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; // FIXED: Correct import filename
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'secrets.dart'; // Importing the API key

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final MapController _mapController;
  final TextEditingController _searchController = TextEditingController();

  /// Geoapify Configuration
  static const String _apiKey = GEOAPIFY_API_KEY;

  // Map Styles available in Geoapify
  static const Map<String, String> _mapStyles = {
    'Carto': 'carto',

    'Positron': 'positron',
  };

  String _currentStyle = 'carto';
  final List<Marker> _markers = [];
  LatLng _currentCenter = const LatLng(
    37.7749,
    -122.4194,
  ); // Default: San Francisco

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // Add initial markers
    _markers.add(_buildMarker(_currentCenter, Colors.red, "Initial Location"));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Helper to build a Marker widget
  Marker _buildMarker(LatLng point, Color color, String label) {
    return Marker(
      point: point,
      width: 45,
      height: 45,
      child: Tooltip(
        message: label,
        child: Icon(Icons.location_on, color: color, size: 40),
      ),
    );
  }

  /// Get User's Current GPS Location
  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar("Location permissions are permanently denied.");
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final latLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _markers.add(_buildMarker(latLng, Colors.pink, "You are here"));
      });

      _mapController.move(latLng, 15);
    } catch (e) {
      _showSnackBar("Error getting location: $e");
    }
  }

  /// Search for a location using Geoapify API
  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    final url = Uri.parse(
      'https://api.geoapify.com/v1/geocode/search?text=$query&apiKey=$_apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['features'].isNotEmpty) {
          final coords = data['features'][0]['geometry']['coordinates'];
          final latLng = LatLng(coords[1], coords[0]);
          final String displayName =
              data['features'][0]['properties']['formatted'];

          setState(() {
            _markers.add(_buildMarker(latLng, Colors.green, displayName));
          });

          _mapController.move(latLng, 13);
        } else {
          _showSnackBar("Location not found");
        }
      }
    } catch (e) {
      _showSnackBar("Search failed: $e");
    }
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. SIDEBAR (DRAWER)
      drawer: Drawer(
        child: Column(
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text("Peiway Map User"),
              accountEmail: Text("Map Settings & Styles"),
              currentAccountPicture: CircleAvatar(child: Icon(Icons.person)),
              decoration: BoxDecoration(color: Colors.green),
            ),
            const ListTile(
              title: Text(
                "Select Map Style",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            // Style Selection List
            ..._mapStyles.entries.map((entry) {
              return ListTile(
                leading: Icon(
                  Icons.layers,
                  color: _currentStyle == entry.value
                      ? Colors.green
                      : Colors.grey,
                ),
                title: Text(entry.key),
                selected: _currentStyle == entry.value,
                onTap: () {
                  setState(() => _currentStyle = entry.value);
                  Navigator.pop(context); // Close drawer
                },
              );
            }).toList(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("LogOut"),
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/login_screen',
                (route) => false,
              ),
            ),
          ],
        ),
      ),

      appBar: AppBar(title: const Text("Peiway Map"), elevation: 2),

      body: Stack(
        children: [
          // 2. THE MAP LAYER
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 13,
              minZoom: 3,
              maxZoom: 19,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://maps.geoapify.com/v1/tile/$_currentStyle/{z}/{x}/{y}.png?apiKey=$_apiKey',
                userAgentPackageName: 'com.example.peiway',
              ),
              MarkerLayer(markers: _markers),
            ],
          ),

          // 3. FLOATING SEARCH BAR
          Positioned(
            top: 20,
            left: 15,
            right: 15,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search city or place...",
                    border: InputBorder.none,
                    icon: const Icon(Icons.search, color: Color(0xFF4DAF50)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _searchController.clear(),
                    ),
                  ),
                  onSubmitted: _searchLocation,
                ),
              ),
            ),
          ),
        ],
      ),

      // 4. GPS BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        backgroundColor: const Color(0xFF4DAF50),
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}
