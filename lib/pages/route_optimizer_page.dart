import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wanderly_android/models/route_optimizer.dart';
import 'package:wanderly_android/services/route_optimizer_service.dart';

class RouteOptimizerPage extends StatefulWidget {
  const RouteOptimizerPage({Key? key}) : super(key: key);

  @override
  State<RouteOptimizerPage> createState() => _RouteOptimizerPageState();
}

class _RouteOptimizerPageState extends State<RouteOptimizerPage> {
  final List<Location> _locations = [];
  List<Location>? _optimizedRoute;
  bool _isLoading = false;
  String _errorMessage = '';

  // Create the service with your API key
  // In production, this should be stored securely!
  final _routeService = RouteOptimizerService(
    apiKey: '5b3ce3597851110001cf624864a34fd33bcc4cd88adb9564dd395343',
  );
  late final _routeOptimizer = RouteOptimizer(_routeService);

  // Sample predefined locations in Bangalore for testing
  final _sampleLocations = [
    const Location(name: 'Kasavanahalli', latitude: 12.9086, longitude: 77.6740),
    const Location(name: 'Sarjapur', latitude: 12.8576, longitude: 77.7864),
    const Location(name: 'Bellandur', latitude: 12.9254, longitude: 77.6770),
    const Location(name: 'Marathahalli', latitude: 12.9591, longitude: 77.6998),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF18222D),
      appBar: AppBar(
        title: const Text('Route Optimizer', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E2A38),
        iconTheme: const IconThemeData(color: Colors.tealAccent),
      ),
      body: Column(
        children: [
          // Map area
          Expanded(
            flex: 3,
            child: _buildMap(),
          ),
          
          // Controls and information
          Expanded(
            flex: 2, 
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildControls(),
                  const SizedBox(height: 16),
                  _buildLocationsList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    // Simple map display with markers
    return FlutterMap(
      options: MapOptions(
        center: _locations.isNotEmpty 
          ? LatLng(_locations.first.latitude, _locations.first.longitude)
          : const LatLng(12.9716, 77.5946), // Bangalore default
        zoom: 12.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.wanderly.app',
        ),
        // Add markers for all locations
        MarkerLayer(
          markers: _buildMarkers(),
        ),
        // Add polylines for the optimized route if available
        if (_optimizedRoute != null && _optimizedRoute!.length > 1)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _optimizedRoute!
                    .map((loc) => LatLng(loc.latitude, loc.longitude))
                    .toList(),
                strokeWidth: 4.0,
                color: Colors.blue,
              ),
            ],
          ),
      ],
    );
  }

  List<Marker> _buildMarkers() {
    final List<Location> displayLocations = _optimizedRoute ?? _locations;
    
    return displayLocations.map((location) {
      // Determine marker color and size based on position in route
      final bool isStart = displayLocations.indexOf(location) == 0;
      final bool isEnd = displayLocations.indexOf(location) == displayLocations.length - 1;
      
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
      
      return Marker(
        width: markerSize,
        height: markerSize,
        point: LatLng(location.latitude, location.longitude),
        builder: (context) => GestureDetector(
          onTap: () => _showLocationInfo(location),
          child: Container(
            decoration: BoxDecoration(
              color: markerColor.withOpacity(0.8),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                (displayLocations.indexOf(location) + 1).toString(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
              onPressed: _loadSampleLocations,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: const Text('Load Samples'),
            ),
            ElevatedButton(
              onPressed: _addCurrentLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add Current Location'),
            ),
            ElevatedButton(
              onPressed: _locations.length >= 2 ? _optimizeRoute : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade700,
              ),
              child: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    )
                  )
                : const Text('Optimize Route'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationsList() {
    final List<Location> displayLocations = _optimizedRoute ?? _locations;
    final bool showingOptimized = _optimizedRoute != null;
    
    if (displayLocations.isEmpty) {
      return const Center(
        child: Text(
          'Add locations to optimize your route',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }
    
    // Helper text for drag-drop feature
    Widget helpText = showingOptimized ? 
      Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.teal.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.tealAccent, size: 16),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Route optimized! Reset order to drag & change starting point.',
                style: TextStyle(color: Colors.tealAccent, fontSize: 12),
              ),
            ),
          ],
        ),
      ) : 
      Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.drag_handle, color: Colors.amberAccent, size: 16),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Drag to reorder. First location will be your starting point.',
                style: TextStyle(color: Colors.amberAccent, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    
    return Expanded(
      child: Column(
        children: [
          helpText,
          Expanded(
            child: showingOptimized ? 
              // When showing optimized route - show non-reorderable list
              ListView.builder(
                itemCount: _optimizedRoute!.length,
                itemBuilder: (context, index) {
                  final location = _optimizedRoute![index];
                  Color itemColor = index == 0 ? Colors.green : 
                                   (index == _optimizedRoute!.length - 1 ? Colors.red : Colors.tealAccent);
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2A38),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: itemColor.withOpacity(0.5), width: 1),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: itemColor,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        location.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
              ) :
              // When showing regular locations - allow reordering
              ReorderableListView.builder(
                itemCount: _locations.length,
                itemBuilder: (context, index) {
                  final location = _locations[index];
                  Color itemColor = index == 0 ? Colors.green : Colors.blue;
                  
                  return Container(
                    key: ValueKey(location),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2A38),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: itemColor.withOpacity(0.5), width: 1),
                    ),
                    child: ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.drag_handle, color: Colors.grey, size: 20),
                          const SizedBox(width: 4),
                          CircleAvatar(
                            backgroundColor: itemColor,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      title: Text(
                        location.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                    // Reset optimized route when order changes
                    _optimizedRoute = null;
                  });
                },
              ),
          ),
          // Button to reset optimization
          if (showingOptimized)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _optimizedRoute = null;
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reset Optimization'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _loadSampleLocations() {
    setState(() {
      _locations.clear();
      _locations.addAll(_sampleLocations);
      _optimizedRoute = null;
      _errorMessage = '';
    });
  }

  void _addCurrentLocation() {
    // In a real app, you would use a location plugin to get the current location
    // This is just a placeholder for demonstration
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Location'),
        content: const Text('This would normally use your device GPS. For demo purposes, a sample location would be added.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Add a random location near existing ones
              if (_locations.isNotEmpty) {
                final lastLocation = _locations.last;
                final newLoc = Location(
                  name: 'Location ${_locations.length + 1}',
                  latitude: lastLocation.latitude + (0.01 * (_locations.length % 3 - 1)),
                  longitude: lastLocation.longitude + (0.01 * (_locations.length % 3 - 1)),
                );
                setState(() {
                  _locations.add(newLoc);
                  _optimizedRoute = null;
                });
              } else {
                // Add a default first location in Bangalore
                setState(() {
                  _locations.add(const Location(
                    name: 'Starting Point',
                    latitude: 12.9716, 
                    longitude: 77.5946,
                  ));
                  _optimizedRoute = null;
                });
              }
            },
            child: const Text('Add Sample Location'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _removeLocation(int index) {
    setState(() {
      if (_optimizedRoute != null) {
        // If we have an optimized route, remove from that
        final originalLocation = _optimizedRoute![index];
        _locations.remove(originalLocation);
        _optimizedRoute = null;
      } else {
        // Otherwise just remove from the original list
        _locations.removeAt(index);
      }
    });
  }

  Future<void> _optimizeRoute() async {
    if (_locations.length < 2) {
      setState(() {
        _errorMessage = 'Need at least 2 locations to optimize a route';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final optimizedLocations = await _routeOptimizer.optimizeRoute(_locations);
      
      setState(() {
        _optimizedRoute = optimizedLocations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error optimizing route: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

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
}
