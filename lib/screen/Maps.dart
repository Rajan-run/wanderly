import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ExploreNearbyScreen extends StatefulWidget {
  const ExploreNearbyScreen({super.key});

  @override
  State<ExploreNearbyScreen> createState() => _ExploreNearbyScreenState();
}

class _ExploreNearbyScreenState extends State<ExploreNearbyScreen> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(37.7749, -122.4194); // Example: San Francisco

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF18222D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: const Text(
          'Explore Nearby',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 13.0,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('hidden_beach'),
                position: const LatLng(37.7694, -122.4862),
                infoWindow: const InfoWindow(title: 'Hidden Beach'),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
              ),
              Marker(
                markerId: const MarkerId('secret_garden'),
                position: const LatLng(37.7700, -122.4500),
                infoWindow: const InfoWindow(title: 'Secret Garden'),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
              ),
              Marker(
                markerId: const MarkerId('local_museum'),
                position: const LatLng(37.8000, -122.4580),
                infoWindow: const InfoWindow(title: 'Local Museum'),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
              ),
            },
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
          ),

          // Custom overlay icons and labels
          Positioned(
            top: 120,
            left: 40,
            child: Column(
              children: [
                _mapIcon(Icons.place, 'Hidden Beach', Colors.cyan),
                const SizedBox(height: 40),
                Row(
                  children: [
                    _mapIcon(Icons.local_florist, 'Secret Garden', Colors.orange),
                    const SizedBox(width: 60),
                    _mapIcon(Icons.account_balance, 'Local Museum', Colors.purple),
                  ],
                ),
              ],
            ),
          ),

          // Map controls (right side)
          Positioned(
            right: 20,
            top: 220,
            child: Column(
              children: [
                _circleButton(Icons.my_location, () {
                  mapController.animateCamera(
                    CameraUpdate.newLatLng(_center),
                  );
                }),
                const SizedBox(height: 16),
                _circleButton(Icons.qr_code_scanner, () {}),
              ],
            ),
          ),

          // Bottom card
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF232F3E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/hidden_beach.jpg',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hidden Beach',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: const [
                            Icon(Icons.location_on, color: Colors.white70, size: 16),
                            SizedBox(width: 4),
                            Text(
                              '2,4 mi',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            SizedBox(width: 12),
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            Icon(Icons.star_border, color: Colors.amber, size: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      shape: StadiumBorder(),
                    ),
                    onPressed: () {
                      // Launch directions or maps
                    },
                    child: const Text(
                      'Get Directions',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 40),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.black.withOpacity(0.3),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}