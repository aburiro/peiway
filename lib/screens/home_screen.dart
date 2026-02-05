import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController _mapController;
  final TextEditingController _searchController = TextEditingController();

  LatLng _currentPosition = const LatLng(37.7749, -122.4194); // San Francisco
  final LatLng _initialPosition = const LatLng(37.7749, -122.4194);

  final Set<Marker> _markers = {};
  final Set<Marker> _initialMarkers = {
    const Marker(
      markerId: MarkerId("center"),
      position: LatLng(37.7749, -122.4194),
      infoWindow: InfoWindow(title: "San Francisco Center"),
    ),
    const Marker(
      markerId: MarkerId("1"),
      position: LatLng(37.7799, -122.4294),
      infoWindow: InfoWindow(title: "Location 1"),
    ),
    const Marker(
      markerId: MarkerId("2"),
      position: LatLng(37.7699, -122.4094),
      infoWindow: InfoWindow(title: "Location 2"),
    ),
    const Marker(
      markerId: MarkerId("3"),
      position: LatLng(37.7850, -122.3950),
      infoWindow: InfoWindow(title: "Location 3"),
    ),
    const Marker(
      markerId: MarkerId("4"),
      position: LatLng(37.7600, -122.4200),
      infoWindow: InfoWindow(title: "Location 4"),
    ),
    const Marker(
      markerId: MarkerId("5"),
      position: LatLng(37.7800, -122.3900),
      infoWindow: InfoWindow(title: "Location 5"),
    ),
    const Marker(
      markerId: MarkerId("6"),
      position: LatLng(37.7550, -122.4350),
      infoWindow: InfoWindow(title: "Location 6"),
    ),
  };

  @override
  void initState() {
    super.initState();
    _markers.addAll(_initialMarkers);
    _searchController.text = "San Francisco";
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: newPosition, zoom: 15),
        ),
      );
    } catch (e) {
      _showSnackBar("Error getting location: $e");
    }
  }

  void _addHomeLocation() {
    final homeMarker = Marker(
      markerId: const MarkerId("home"),
      position: _currentPosition,
      infoWindow: const InfoWindow(title: "Home"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    );

    setState(() {
      _markers.add(homeMarker);
    });

    _showSnackBar("Home location added!");
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 13,
            ),
            markers: _markers,
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: (argument) {
              FocusScope.of(context).unfocus();
            },
          ),

          /// Top Panel with Search and Buttons
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.of(context).padding.top + 16,
                16,
                16,
              ),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Location Search Field
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: "Search location...",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                            style: const TextStyle(fontSize: 14),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  /// Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _addHomeLocation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.green,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            "ADD HOME",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _getCurrentLocation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            "MY LOCATION",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          /// Zoom Buttons
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              children: [
                _buildMapButton(
                  icon: Icons.add,
                  onTap: () {
                    _mapController.animateCamera(CameraUpdate.zoomIn());
                  },
                ),
                const SizedBox(height: 10),
                _buildMapButton(
                  icon: Icons.remove,
                  onTap: () {
                    _mapController.animateCamera(CameraUpdate.zoomOut());
                  },
                ),
              ],
            ),
          ),

          /// Current Location Button (Bottom Right)
          Positioned(
            right: 16,
            bottom: 30,
            child: _buildMapButton(
              icon: Icons.my_location,
              onTap: _getCurrentLocation,
              backgroundColor: Colors.green,
              iconColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapButton({
    required IconData icon,
    required VoidCallback onTap,
    Color backgroundColor = Colors.white,
    Color iconColor = Colors.green,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }
}
