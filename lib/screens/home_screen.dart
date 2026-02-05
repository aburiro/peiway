// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TabController _mapController;
  final TextEditingController _searchController = TextEditingController();

  // Geoapify API Key
  static const String GEOAPIFY_API_KEY = '452b27c765e840358ee7ad7ee57339e3';

  // Map style options
  static const String CARTO_STYLE = 'carto';
  static const String CARTO_DARK_STYLE = 'carto-dark';
  static const String POSITRON_STYLE = 'positron';
  static const String VOYAGER_STYLE = 'voyager';

  LatLng _currentPosition = const LatLng(37.7749, -122.4194);
  final LatLng _initialPosition = const LatLng(37.7749, -122.4194);
  String _currentStyle = CARTO_STYLE;

  final Set<Marker> _markers = {};
  final Set<Marker> _initialMarkers = {
    const Marker(
      point: LatLng(37.7749, -122.4194),
      builder: (ctx) => Tooltip(
        message: "San Francisco Center",
        child: Icon(Icons.location_on, color: Colors.red, size: 30),
      ),
    ),
    const Marker(
      point: LatLng(37.7799, -122.4294),
      builder: (ctx) => Tooltip(
        message: "Location 1",
        child: Icon(Icons.location_on, color: Colors.blue, size: 30),
      ),
    ),
    const Marker(
      point: LatLng(37.7699, -122.4094),
      builder: (ctx) => Tooltip(
        message: "Location 2",
        child: Icon(Icons.location_on, color: Colors.orange, size: 30),
      ),
    ),
    const Marker(
      point: LatLng(37.7850, -122.3950),
      builder: (ctx) => Tooltip(
        message: "Location 3",
        child: Icon(Icons.location_on, color: Colors.green, size: 30),
      ),
    ),
    const Marker(
      point: LatLng(37.7600, -122.4200),
      builder: (ctx) => Tooltip(
        message: "Location 4",
        child: Icon(Icons.location_on, color: Colors.purple, size: 30),
      ),
    ),
    const Marker(
      point: LatLng(37.7800, -122.3900),
      builder: (ctx) => Tooltip(
        message: "Location 5",
        child: Icon(Icons.location_on, color: Colors.yellow, size: 30),
      ),
    ),
  };

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _markers.addAll(_initialMarkers);
    _searchController.text = "San Francisco";
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Build Geoapify tile URL
  String _buildGeoapifyUrl() {
    return 'https://maps.geoapify.com/v1/tile/$_currentStyle/{z}/{x}/{y}.png?apiKey=$GEOAPIFY_API_KEY';
  }

  /// Get current location
  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar("Location permissions are denied forever");
        return;
      }

      if (permission == LocationPermission.denied) {
        _showSnackBar("Location permissions are denied");
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final newPosition = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentPosition = newPosition;
      });

      _mapController.move(newPosition, 15);

      _showSnackBar(
        "Location: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}",
      );
    } catch (e) {
      _showSnackBar("Error getting location: $e");
    }
  }

  /// Search location using Geoapify Geocoding API
  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.geoapify.com/v1/geocode/search?text=$query&apiKey=$GEOAPIFY_API_KEY',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['features'].isNotEmpty) {
          final feature = data['features'][0];
          final lat = feature['geometry']['coordinates'][1];
          final lng = feature['geometry']['coordinates'][0];

          final newPosition = LatLng(lat, lng);

          setState(() {
            _currentPosition = newPosition;
          });

          _mapController.move(newPosition, 13);
          _showSnackBar("Found: ${feature['properties']['formatted']}");
        } else {
          _showSnackBar("Location not found");
        }
      }
    } catch (e) {
      _showSnackBar("Error searching location: $e");
    }
  }

  /// Add marker at current position
  void _addMarker() {
    final newMarker = Marker(
      point: _currentPosition,
      builder: (ctx) => Tooltip(
        message: "New Location",
        child: Icon(Icons.location_on, color: Colors.pink, size: 30),
      ),
    );

    setState(() {
      _markers.add(newMarker);
    });

    _showSnackBar("Marker added!");
  }

  /// Change map style
  void _changeMapStyle(String style) {
    setState(() {
      _currentStyle = style;
    });
    _showSnackBar("Map style changed to: $style");
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geoapify Maps'),
        subtitle: const Text('Free Maps API - 3000 requests/day'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          /// Geoapify Map with flutter_map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _initialPosition,
              zoom: 13.0,
              minZoom: 1.0,
              maxZoom: 19.0,
            ),
            children: [
              /// Geoapify Tile Layer
              TileLayer(
                urlTemplate: _buildGeoapifyUrl(),
                userAgentPackageName: 'com.example.geoapify_maps',
                attributionBuilder: (_) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      '© Geoapify © OpenStreetMap contributors',
                      style: TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),

              /// Markers Layer
              MarkerLayer(markers: _markers.toList()),
            ],
          ),

          /// Top Control Panel
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    /// Search Bar
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search location (e.g., "New York")',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.blue,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                      onSubmitted: _searchLocation,
                    ),
                    const SizedBox(height: 12),

                    /// Search & Add Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _searchLocation(_searchController.text),
                            icon: const Icon(Icons.search),
                            label: const Text('Search'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _addMarker,
                            icon: const Icon(Icons.add_location),
                            label: const Text('Add'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    /// Map Style Dropdown
                    DropdownButtonFormField<String>(
                      value: _currentStyle,
                      items: [
                        const DropdownMenuItem(
                          value: CARTO_STYLE,
                          child: Text('Carto (Light)'),
                        ),
                        const DropdownMenuItem(
                          value: CARTO_DARK_STYLE,
                          child: Text('Carto Dark'),
                        ),
                        const DropdownMenuItem(
                          value: POSITRON_STYLE,
                          child: Text('Positron (Minimal)'),
                        ),
                        const DropdownMenuItem(
                          value: VOYAGER_STYLE,
                          child: Text('Voyager (Colorful)'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          _changeMapStyle(value);
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Map Style',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// Right Side Controls
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              children: [
                _buildControlButton(
                  icon: Icons.add,
                  onTap: () => _mapController.move(
                    _mapController.center,
                    _mapController.zoom + 1,
                  ),
                  label: 'Zoom In',
                ),
                const SizedBox(height: 8),
                _buildControlButton(
                  icon: Icons.remove,
                  onTap: () => _mapController.move(
                    _mapController.center,
                    _mapController.zoom - 1,
                  ),
                  label: 'Zoom Out',
                ),
              ],
            ),
          ),

          /// Location Button
          Positioned(
            right: 16,
            bottom: 30,
            child: _buildControlButton(
              icon: Icons.my_location,
              onTap: _getCurrentLocation,
              label: 'My Location',
              backgroundColor: Colors.blue,
              iconColor: Colors.white,
            ),
          ),

          /// Info Card
          Positioned(
            bottom: 20,
            left: 16,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Geoapify Free Map',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Markers: ${_markers.length}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const Text(
                      '3000 requests/day free',
                      style: TextStyle(fontSize: 11, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required String label,
    Color backgroundColor = Colors.white,
    Color iconColor = Colors.blue,
  }) {
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8),
            ],
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
      ),
    );
  }
}
