import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wanderly_android/services/location_service.dart';

class ExploreNearbyScreen extends StatefulWidget {
  const ExploreNearbyScreen({super.key});

  @override
  State<ExploreNearbyScreen> createState() => _ExploreNearbyScreenState();
}

class _ExploreNearbyScreenState extends State<ExploreNearbyScreen> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();
  
  // Default center (will be updated with user's location)
  LatLng _center = const LatLng(37.7749, -122.4194); // Default: San Francisco
  bool _isLoading = true;
  bool _locationFound = false;
  List<Marker> _markers = [];
  String _locationAddress = "Getting address...";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _locationAddress = "Getting your location...";
    });
    
    debugPrint('Requesting location from service...');
    final position = await _locationService.getCurrentLocation(context);
    debugPrint(position != null 
        ? 'Location received: ${position.latitude}, ${position.longitude}'
        : 'Failed to get location');
        
    if (position != null) {
      // Get the address from the LocationService
      final address = _locationService.currentAddress;
      
      // Create new location with latitude and longitude from Geolocator
      final newLocation = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _center = newLocation;
        _locationFound = true;
        _isLoading = false;
        _locationAddress = address.isNotEmpty ? address : "Unknown location";
        
        // Update markers
        _updateMarkers();
      });
      
      // Move map to new location
      try {
        _mapController.move(_center, 14.0);
      } catch (e) {
        debugPrint('Error moving map: $e');
      }
    } else {
      setState(() {
        _isLoading = false;
        _locationAddress = "Unable to get location";
      });
    }
  }

  void _updateMarkers() {
    _markers = [
      // User's current location marker
      Marker(
        width: 80,
        height: 80,
        point: _center,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_pin_circle,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'You',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    ];
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
          // OpenStreetMap with flutter_map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _center,
              zoom: 13.0,
              onMapReady: () {
                if (_locationFound) {
                  _mapController.move(_center, 14.0);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.wanderly_android',
                maxZoom: 19,
              ),
              MarkerLayer(
                markers: _markers,
              ),
            ],
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.6),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.tealAccent,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Getting your location...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
            ),

          // Map controls (right side)
          Positioned(
            right: 20,
            top: 220,
            child: Column(
              children: [
                _circleButton(Icons.my_location, () {
                  if (_locationFound) {
                    _mapController.move(_center, 14.0);
                  } else {
                    _getCurrentLocation();
                  }
                }),
                const SizedBox(height: 16),
                _circleButton(Icons.add, () {
                  // Zoom in
                  final currentZoom = _mapController.zoom;
                  _mapController.move(_center, currentZoom + 1);
                }),
                const SizedBox(height: 16),
                _circleButton(Icons.remove, () {
                  // Zoom out
                  final currentZoom = _mapController.zoom;
                  _mapController.move(_center, currentZoom - 1);
                }),
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
                    child: Container(
                      color: Colors.grey, // Placeholder
                      width: 60,
                      height: 60,
                      child: const Icon(Icons.location_on, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Your Current Location',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _locationFound 
                          ? Text(
                              _locationAddress,
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            )
                          : Text(
                              'Location not available',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.tealAccent,
        onPressed: () {
          _getCurrentLocation();
        },
        child: const Icon(Icons.my_location, color: Colors.black),
      ),
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