import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wanderly_android/services/location_service.dart';
import 'package:wanderly_android/models/route_optimizer.dart';
import 'package:wanderly_android/services/route_optimizer_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ExploreNearbyScreen extends StatefulWidget {
  final List<Location>? landmarkLocations;
  
  const ExploreNearbyScreen({super.key, this.landmarkLocations});

  @override
  State<ExploreNearbyScreen> createState() => _ExploreNearbyScreenState();
}

class _ExploreNearbyScreenState extends State<ExploreNearbyScreen> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();

  // Route optimizer setup
  final _routeService = RouteOptimizerService(
    apiKey: '5b3ce3597851110001cf624864a34fd33bcc4cd88adb9564dd395343',
  );
  late final _routeOptimizer = RouteOptimizer(_routeService);

  // Location and route state
  LatLng _center = const LatLng(28.6139, 77.2090); // Default: Delhi, India
  LatLng? _userLocation;
  bool _isLoading = true;
  bool _locationFound = false;
  final List<Location> _locations = [];
  List<Location>? _optimizedRoute;
  String _errorMessage = '';
  bool _isLoadingRoute = false;
  bool _hasLandmarks = false; // Flag to indicate landmarks were passed

  @override
  void initState() {
    super.initState();
    
    // Add any landmark locations passed to the map
    if (widget.landmarkLocations != null && widget.landmarkLocations!.isNotEmpty) {
      // print('ExploreNearbyScreen received ${widget.landmarkLocations!.length} landmarks');
      // for (var loc in widget.landmarkLocations!) {
      //   print('Received landmark: ${loc.name}, (${loc.latitude}, ${loc.longitude})');
      // }
      
      setState(() {
        // Add landmarks to the locations list
        _locations.addAll(widget.landmarkLocations!);
        // print('After adding landmarks, _locations has ${_locations.length} locations');
      });
      
      // Flag to optimize route after getting current location
      _hasLandmarks = true;
    } else {
      // print('ExploreNearbyScreen: No landmarks received');
    }
    
    // Get the current location
    _getCurrentLocation();
  }

  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lng');
      final response = await http.get(url, headers: {
        'User-Agent': 'WanderlyApp/1.0 (your@email.com)'
      });
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['display_name'] != null) {
          // Use the first part of the address as the name
          return data['display_name'].split(',').first.trim();
        }
      }
      return 'Unnamed Location';
    } catch (e) {
      return 'Unnamed Location';
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    final position = await _locationService.getCurrentLocation(context);

    if (position != null) {
      // Fetch address using reverse geocoding
      String address = await getAddressFromCoordinates(position.latitude, position.longitude);
      if (address == 'Unnamed Location') {
        address = 'Current Location';
      }
      final newLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        _center = newLocation;
        _userLocation = newLocation;
        _locationFound = true;
        _isLoading = false;
        
        // Create the current location object
        final currentLoc = Location(
          name: address,
          latitude: position.latitude,
          longitude: position.longitude,
        );
        
        // Before modifying locations, print the current state
        // print('Before modification, _locations has ${_locations.length} items');
        // ignore: unused_local_variable
        for (var loc in _locations) {
          // print('Location before: ${loc.name}, (${loc.latitude}, ${loc.longitude})');
        }
        
        // Only remove locations with the exact name 'Current Location' or exact same coordinates
        // but not landmarks with different names and coordinates
        // ignore: unused_local_variable
        int removed = 0;
        _locations.removeWhere((loc) {
          bool shouldRemove = 
              loc.name == 'Current Location' || 
              (loc.latitude == currentLoc.latitude && loc.longitude == currentLoc.longitude);
          if (shouldRemove) removed++;
          return shouldRemove;
        });
        
        // print('Removed $removed locations that matched current location');
        
        // Insert current location as the first point (point A)
        _locations.insert(0, currentLoc);
        
        // After modifying, print the state again
        // print('After modification, _locations has ${_locations.length} items');
        // ignore: unused_local_variable
        for (var loc in _locations) {
          // print('Location after: ${loc.name}, (${loc.latitude}, ${loc.longitude})');
        }
        
        // Reset optimized route since locations changed
        _optimizedRoute = null;
        
        // If we have landmarks passed from the itinerary, automatically optimize the route
        if (_hasLandmarks && _locations.length >= 2) {
          _optimizeRoute();
        }
      });

      try {
        _mapController.move(_center, 14.0);
      } catch (_) {}
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Add a location when tapping on the map
  Future<void> _onMapTap(LatLng point) async {
    String address = await _locationService.getAddressFromCoordinates(point.latitude, point.longitude);
    if (address == 'Unnamed Location') {
      address = 'Lat: ${point.latitude.toStringAsFixed(4)}, Lng: ${point.longitude.toStringAsFixed(4)}';
    }

    setState(() {
      _locations.add(Location(
        name: address,
        latitude: point.latitude,
        longitude: point.longitude,
      ));
      _optimizedRoute = null;
      _errorMessage = '';
    });
  }

  // Remove a location
  void _removeLocation(int index) {
    setState(() {
      bool removingCurrentLocation = false;
      Location? nextLocation;

      if (_optimizedRoute != null) {
        // For the optimized route, identify the location being removed
        final originalLocation = _optimizedRoute![index];
        
        // Check if this is the current location
        if (_userLocation != null && originalLocation.latitude == _userLocation!.latitude && 
            originalLocation.longitude == _userLocation!.longitude) {
          removingCurrentLocation = true;
          // Store next location for centering map if available
          if (_optimizedRoute!.length > 1) {
            nextLocation = _optimizedRoute![index == 0 ? 1 : 0];
          }
          // Reset the user location reference
          _userLocation = null;
        }
        
        _locations.remove(originalLocation);
        _optimizedRoute = null;
      } else {
        // Check if removing the current location
        if (index == 0 && _userLocation != null && 
            _locations[0].latitude == _userLocation!.latitude && 
            _locations[0].longitude == _userLocation!.longitude) {
          removingCurrentLocation = true;
          // Store next location for centering map if available
          if (_locations.length > 1) {
            nextLocation = _locations[1];
          }
          // Reset the user location reference
          _userLocation = null;
        }
        
        _locations.removeAt(index);
        
        // Ensure user's location is still the first point if present in the list
        if (_userLocation != null && _locations.isNotEmpty) {
          // Find if user's location is in the list but not at position 0
          final userLocationIndex = _locations.indexWhere(
            (loc) => loc.latitude == _userLocation!.latitude && 
                    loc.longitude == _userLocation!.longitude
          );
          
          // If found elsewhere in the list, move it to position 0
          if (userLocationIndex > 0) {
            final userLocation = _locations.removeAt(userLocationIndex);
            _locations.insert(0, userLocation);
          }
        }
      }
      
      // If we removed the current location and have other locations, center the map on the new first location
      if (removingCurrentLocation && nextLocation != null) {
        // Schedule to run after this frame to ensure the state is updated
        final Location locationToCenter = nextLocation; // Create a non-nullable reference
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final newCenter = LatLng(locationToCenter.latitude, locationToCenter.longitude);
          _center = newCenter;
          _mapController.move(newCenter, _mapController.zoom);
        });
      }
    });
  }

  // Optimize the route
  Future<void> _optimizeRoute() async {
    if (_locations.length < 2) {
      setState(() {
        _errorMessage = 'Need at least 2 locations to optimize a route';
      });
      return;
    }

    setState(() {
      _isLoadingRoute = true;
      _errorMessage = '';
    });

    try {
      // Ensure current location is always the starting point for route optimization
      List<Location> routeLocations = List.from(_locations);
      if (_userLocation != null) {
        // Find the index of the user's current location
        final currentLocationIndex = routeLocations.indexWhere(
          (loc) => loc.latitude == _userLocation!.latitude && loc.longitude == _userLocation!.longitude
        );
        
        // If found and not already at index 0, move it to the beginning
        if (currentLocationIndex > 0) {
          final currentLocation = routeLocations.removeAt(currentLocationIndex);
          routeLocations.insert(0, currentLocation);
        }
      }
      
      final optimizedLocations = await _routeOptimizer.optimizeRoute(routeLocations);

      setState(() {
        _optimizedRoute = optimizedLocations;
        _isLoadingRoute = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error optimizing route: ${e.toString()}';
        _isLoadingRoute = false;
      });
    }
  }

  // Show info dialog for a location
  void _showLocationInfo(Location location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(location.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Latitude: ${location.latitude}'),
            Text('Longitude: ${location.longitude}'),
            if (_optimizedRoute != null)
              Text(
                'Stop #${_optimizedRoute!.indexOf(location) + 1} of ${_optimizedRoute!.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Map markers for all locations
  List<Marker> _buildMarkers() {
    final List<Location> displayLocations = _optimizedRoute ?? _locations;
    // print('Building markers for ${displayLocations.length} locations');
    // ignore: unused_local_variable
    for (var loc in displayLocations) {
      // print('Creating marker for: ${loc.name}, (${loc.latitude}, ${loc.longitude})');
    }

    return displayLocations.map((location) {
      final int index = displayLocations.indexOf(location);
      final bool isStart = index == 0;
      final bool isEnd = index == displayLocations.length - 1;

      Color markerColor;
      double markerSize;

      if (isStart) {
        markerColor = Colors.green;
        markerSize = 30.0;
      } else if (isEnd && displayLocations.length > 1) {
        markerColor = Colors.red;
        markerSize = 25.0;
      } else {
        markerColor = Colors.blue;
        markerSize = 20.0;
      }

      // Use letters instead of numbers: A for start (current location), 
      // then B, C, D for subsequent points
      String markerLabel;
      if (isStart) {
        markerLabel = 'A';
      } else {
        // Convert index to corresponding letter (1->B, 2->C, etc.)
        markerLabel = String.fromCharCode('B'.codeUnitAt(0) + index - 1);
      }

      return Marker(
        width: markerSize,
        height: markerSize,
        point: LatLng(location.latitude, location.longitude),
        builder: (context) => GestureDetector(
          onTap: () => _showLocationInfo(location),
          child: Container(
            decoration: BoxDecoration(
              color: markerColor.withAlpha((0.8 * 255).toInt()),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                markerLabel,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  // Polyline for the optimized route
  List<Polyline> _buildPolylines() {
    if (_optimizedRoute != null && _optimizedRoute!.length > 1) {
      return [
        Polyline(
          points: _optimizedRoute!
              .map((loc) => LatLng(loc.latitude, loc.longitude))
              .toList(),
          strokeWidth: 4.0,
          color: Colors.blue,
        ),
      ];
    }
    return [];
  }

  // Open Google Maps with directions for the optimized route
  Future<void> _openGoogleMapsDirections() async {
    if ((_optimizedRoute ?? _locations).length < 2) return;
    final route = _optimizedRoute ?? _locations;
    final origin = '${route.first.latitude},${route.first.longitude}';
    final destination = '${route.last.latitude},${route.last.longitude}';
    final waypoints = route.length > 2
        ? route.sublist(1, route.length - 1).map((loc) => '${loc.latitude},${loc.longitude}').join('|')
        : '';

    final url = waypoints.isEmpty
        ? 'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&travelmode=driving'
        : 'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&waypoints=$waypoints&travelmode=driving';

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open Maps app.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Location> displayLocations = _optimizedRoute ?? _locations;
    final bool showingOptimized = _optimizedRoute != null;

    return Scaffold(
      backgroundColor: const Color(0xFF18222D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: const Text(
          'Explore & Optimize Route',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          // Map area
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: _center,
                    zoom: 13.0,
                    onTap: (tapPosition, point) {
                      _onMapTap(point);
                    },
                    onMapReady: () {
                      // print('Map is ready, locationFound: $_locationFound');
                      // print('Center: $_center');
                      // print('Markers count: ${_buildMarkers().length}');
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
                      markers: _buildMarkers(),
                    ),
                    if (_buildPolylines().isNotEmpty)
                      PolylineLayer(
                        polylines: _buildPolylines(),
                      ),
                  ],
                ),
                if (_isLoading)
                  Container(
                    color: Colors.black.withAlpha((0.6 * 255).toInt()),
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
                        _getCurrentLocation();
                      }),
                      const SizedBox(height: 16),
                      _circleButton(Icons.add, () {
                        final currentZoom = _mapController.zoom;
                        _mapController.move(_center, currentZoom + 1);
                      }),
                      const SizedBox(height: 16),
                      _circleButton(Icons.remove, () {
                        final currentZoom = _mapController.zoom;
                        _mapController.move(_center, currentZoom - 1);
                      }),
                    ],
                  ),
                ),
                // Get Directions button (bottom right)
                if (displayLocations.length >= 2)
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
              ],
            ),
          ),
          // Controls and locations list
          Expanded(
            flex: 2,
            child: Container(
              color: const Color(0xFF232F3E),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Error message if any
                    if (_errorMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.red.shade900,
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _locations.clear();
                              _optimizedRoute = null;
                              _errorMessage = '';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Clear All'),
                        ),
                        ElevatedButton(
                          onPressed: _locations.length >= 2 ? _optimizeRoute : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade700,
                          ),
                          child: _isLoadingRoute
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ))
                              : const Text('Optimize Route'),
                        ),
                        if (showingOptimized)
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _optimizedRoute = null;
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reset'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber.shade700,
                              foregroundColor: Colors.white,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Locations list
                    Expanded(
                      child: showingOptimized
                          ? ListView.builder(
                              itemCount: _optimizedRoute!.length,
                              itemBuilder: (context, index) {
                                final location = _optimizedRoute![index];
                                Color itemColor = index == 0
                                    ? Colors.green
                                    : (index == _optimizedRoute!.length - 1
                                        ? Colors.red
                                        : Colors.tealAccent);
                                        
                                // Convert index to letter: A for start, then B, C, D...
                                String markerLabel = index == 0 
                                    ? 'A' 
                                    : String.fromCharCode('B'.codeUnitAt(0) + index - 1);

                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E2A38),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: itemColor.withAlpha((0.5 * 255).toInt()), width: 1),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: itemColor,
                                      child: Text(
                                        markerLabel,
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    title: Text(
                                      location.name,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _removeLocation(index),
                                    ),
                                  ),
                                );
                              },
                            )
                          : ReorderableListView.builder(
                              itemCount: _locations.length,
                              itemBuilder: (context, index) {
                                final location = _locations[index];
                                Color itemColor =
                                    index == 0 ? Colors.green : Colors.blue;

                                return Container(
                                  key: ValueKey(location),
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E2A38),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: itemColor.withAlpha((0.5 * 255).toInt()), width: 1),
                                  ),
                                  child: ListTile(
                                    leading: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.drag_handle,
                                            color: Colors.grey, size: 20),
                                        const SizedBox(width: 4),                                CircleAvatar(
                                      backgroundColor: itemColor,
                                      child: Text(
                                        index == 0 ? 'A' : String.fromCharCode('B'.codeUnitAt(0) + index - 1),
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                      ],
                                    ),
                                    title: Text(
                                      location.name,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _removeLocation(index),
                                    ),
                                  ),
                                );
                              },
                              onReorder: (oldIndex, newIndex) {
                                setState(() {
                                  if (newIndex > oldIndex) newIndex -= 1;
                                  final item = _locations.removeAt(oldIndex);
                                  _locations.insert(newIndex, item);
                                  _optimizedRoute = null;
                                });
                              },
                            ),
                    ),
                  ],
                ),
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
      color: Colors.black.withAlpha((0.3 * 255).toInt()),
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