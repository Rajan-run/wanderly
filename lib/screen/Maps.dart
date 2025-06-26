import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wanderly_android/services/location_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ExploreNearbyScreen extends StatefulWidget {
  const ExploreNearbyScreen({super.key});

  @override
  State<ExploreNearbyScreen> createState() => _ExploreNearbyScreenState();
}

class _ExploreNearbyScreenState extends State<ExploreNearbyScreen> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();
  
  // Default center (will be updated with user's location)
  LatLng _center = const LatLng(28.6139, 77.2090); // Default: Delhi, India
  LatLng? _userLocation; // Store user's actual location separately
  LatLng? _selectedLocation; // Store the currently selected/tapped location
  bool _isLoading = true;
  bool _locationFound = false;
  List<Marker> _markers = [];
  String _locationAddress = "Getting address...";
  bool _isGettingAddressForTappedLocation = false;

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
        _userLocation = newLocation; // Store user's actual location
        _selectedLocation = newLocation; // Initially, selected location is user's location
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

  // Handle map tap to select new location
  Future<void> _onMapTap(LatLng point) async {
    setState(() {
      _selectedLocation = point;
      _center = point; // Update center to tapped location
      _isGettingAddressForTappedLocation = true;
      _locationAddress = "Getting address for selected location...";
      _updateMarkers();
    });

    // Get address for the tapped location
    try {
      final address = await _locationService.getAddressFromCoordinates(
        point.latitude, 
        point.longitude
      );
      
      setState(() {
        _locationAddress = address;
        _isGettingAddressForTappedLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationAddress = "Unable to get address for this location";
        _isGettingAddressForTappedLocation = false;
      });
      debugPrint('Error getting address for tapped location: $e');
    }
  }

  // Go back to user's current location
  void _goToUserLocation() {
    if (_userLocation != null) {
      setState(() {
        _center = _userLocation!;
        _selectedLocation = _userLocation!;
        _locationAddress = _locationService.currentAddress.isNotEmpty 
            ? _locationService.currentAddress 
            : "Your current location";
        _updateMarkers();
      });
      _mapController.move(_userLocation!, 14.0);
    } else {
      _getCurrentLocation();
    }
  }

  // Open Google Maps with directions
  Future<void> _openGoogleMapsDirections() async {
    if (_userLocation == null || _selectedLocation == null) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location information not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final String origin = '${_userLocation!.latitude},${_userLocation!.longitude}';
    final String destination = '${_selectedLocation!.latitude},${_selectedLocation!.longitude}';
    
    // Try multiple URL schemes for Google Maps
    final List<String> urlsToTry = [
      // Google Maps navigation (most direct)
      'google.navigation:q=$destination&mode=d',
      // Google Maps with directions
      'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&travelmode=driving',
      // Alternative Google Maps URL
      'https://maps.google.com/maps?saddr=$origin&daddr=$destination',
      // Generic maps URL
      'geo:$destination?q=$destination',
    ];

    bool launched = false;
    String lastError = '';
    
    for (String url in urlsToTry) {
      try {
        final Uri uri = Uri.parse(url);
        debugPrint('Trying to launch: $url');
        
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri, 
            mode: LaunchMode.externalApplication,
          );
          launched = true;
          debugPrint('Successfully launched: $url');
          break;
        } else {
          debugPrint('Cannot launch URL: $url');
        }
      } catch (e) {
        lastError = e.toString();
        debugPrint('Failed to launch URL: $url, Error: $e');
      }
    }

    if (!launched) {
      // Show error message if no URL could be launched
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open Maps app. Please install Google Maps or any maps application.\n\nLast error: $lastError'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _updateMarkers() {
    _markers.clear();
    
    // Add user's current location marker (if available)
    if (_userLocation != null) {
      _markers.add(
        Marker(
          width: 80,
          height: 80,
          point: _userLocation!,
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
      );
    }
    
    // Add selected location marker (if different from user location)
    if (_selectedLocation != null && 
        _userLocation != null && 
        _selectedLocation != _userLocation) {
      _markers.add(
        Marker(
          width: 80,
          height: 80,
          point: _selectedLocation!,
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
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on,
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
                  'Selected',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  // Get a user-friendly title for the selected location
  String _getLocationTitle() {
    if (_isGettingAddressForTappedLocation) {
      return 'Getting Location...';
    }
    
    if (_locationAddress.isEmpty || _locationAddress == "Unknown location" || _locationAddress == "Unable to get address for this location") {
      return 'Selected Location';
    }
    
    // Extract the main location name from the address
    // For addresses like "Halanayakanahalli, PIN: 560035", we want "Halanayakanahalli"
    final addressParts = _locationAddress.split(',');
    if (addressParts.isNotEmpty) {
      String mainLocation = addressParts[0].trim();
      // Remove "PIN:" part if it exists in the main location
      if (mainLocation.contains('PIN:')) {
        mainLocation = mainLocation.split('PIN:')[0].trim();
      }
      return mainLocation.isNotEmpty ? mainLocation : 'Selected Location';
    }
    
    return _locationAddress;
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
              onTap: (tapPosition, point) {
                _onMapTap(point);
              },
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
                  _goToUserLocation();
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

          // Get Directions button (bottom right)
          if (_selectedLocation != null && 
              _userLocation != null && 
              _selectedLocation != _userLocation)
            Positioned(
              right: 20,
              bottom: 120,
              child: FloatingActionButton.extended(
                onPressed: _openGoogleMapsDirections,
                backgroundColor: Colors.tealAccent,
                foregroundColor: Colors.black,
                icon: const Icon(Icons.directions),
                label: const Text(
                  'Get Directions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedLocation != null && _userLocation != null && _selectedLocation == _userLocation 
                                  ? 'Your Current Location'
                                  : _getLocationTitle(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            if (_isGettingAddressForTappedLocation) ...[
                              const SizedBox(width: 8),
                              const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.tealAccent,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        _locationFound || _selectedLocation != null
                          ? Text(
                              _locationAddress,
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            )
                          : const Text(
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
          _goToUserLocation();
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