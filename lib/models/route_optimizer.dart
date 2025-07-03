import 'package:flutter/foundation.dart';
import 'package:wanderly_android/services/route_optimizer_service.dart';

/// Model class to represent a location
class Location {
  final String name;
  final double latitude;
  final double longitude;
  
  const Location({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  /// Convert to format needed for OpenRouteService API (longitude, latitude)
  List<double> toCoordinate() {
    return [longitude, latitude];
  }

  @override
  String toString() => '$name (${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)})';
}

/// Class to optimize routes between multiple locations
class RouteOptimizer {
  final RouteOptimizerService _service;
  
  RouteOptimizer(this._service);

  /// Calculate the optimal route starting from the first location in the list
  /// 
  /// Returns a list of locations in the optimized order, with the starting point remaining first
  Future<List<Location>> optimizeRoute(List<Location> locations) async {
    if (locations.length <= 2) {
      return locations; // No optimization needed
    }

    try {
      // Convert locations to coordinates in the format OpenRouteService expects [longitude, latitude]
      final coordinates = locations.map((loc) => loc.toCoordinate()).toList();
      
      // Get the distance matrix from OpenRouteService
      final matrixResult = await _service.getDistanceMatrix(coordinates);
      
      // Parse the duration matrix from the API response
      final List<List<double>> durations = [];
      final durationsData = matrixResult['durations'] as List<dynamic>;
      
      for (final row in durationsData) {
        durations.add(List<double>.from((row as List<dynamic>).map((d) => d.toDouble())));
      }
      
      // Get optimized route indices using the nearest neighbor algorithm
      final optimizedIndices = _calculateOptimalRoute(durations, 0);
      
      // Map indices back to locations, keeping the first location as the starting point
      final optimizedLocations = optimizedIndices.map((index) => locations[index]).toList();
      
      return optimizedLocations;
    } catch (e) {
      debugPrint('Error optimizing route: $e');
      rethrow;
    }
  }
  
  /// Calculate the optimal route using the nearest neighbor algorithm
  /// 
  /// [distanceMatrix] The matrix of distances/durations between locations
  /// [startIndex] The index of the starting location
  /// 
  /// Returns a list of indices representing the optimal order to visit locations
  List<int> _calculateOptimalRoute(List<List<double>> distanceMatrix, int startIndex) {
    final int n = distanceMatrix.length;
    final List<int> route = [startIndex];
    final List<bool> visited = List.filled(n, false);
    visited[startIndex] = true;
    
    int currentIndex = startIndex;
    
    // Visit each remaining location once, always choosing the closest
    for (int i = 0; i < n - 1; i++) {
      int nextIndex = -1;
      double minDistance = double.infinity;
      
      // Find closest unvisited location from current position
      for (int j = 0; j < n; j++) {
        if (!visited[j] && distanceMatrix[currentIndex][j] < minDistance) {
          minDistance = distanceMatrix[currentIndex][j];
          nextIndex = j;
        }
      }
      
      // If no valid next location is found (shouldn't happen with a proper matrix)
      if (nextIndex == -1) break;
      
      currentIndex = nextIndex;
      visited[currentIndex] = true;
      route.add(currentIndex);
    }
    
    return route;
  }
}
