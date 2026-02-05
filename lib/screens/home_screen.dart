import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController _mapController;

  final LatLng _initialPosition = const LatLng(
    37.7749,
    -122.4194,
  ); // San Francisco

  final Set<Marker> _markers = {
    Marker(markerId: MarkerId("center"), position: LatLng(37.7749, -122.4194)),
    Marker(markerId: MarkerId("1"), position: LatLng(37.7799, -122.4294)),
    Marker(markerId: MarkerId("2"), position: LatLng(37.7699, -122.4094)),
  };

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
          ),

          /// Top Panel
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 12),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  /// Location Field
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.place, color: Colors.green),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "San Francisco",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  /// Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text("ADD HOME"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text("MY LOCATION"),
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
                _mapButton(
                  icon: Icons.add,
                  onTap: () {
                    _mapController.animateCamera(CameraUpdate.zoomIn());
                  },
                ),
                const SizedBox(height: 10),
                _mapButton(
                  icon: Icons.remove,
                  onTap: () {
                    _mapController.animateCamera(CameraUpdate.zoomOut());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Icon(icon, color: Colors.green),
      ),
    );
  }
}
