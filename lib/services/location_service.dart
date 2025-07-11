import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // Singleton instance
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Current position
  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  // Current address
  String _currentAddress = "";
  String get currentAddress => _currentAddress;

  // Stream for location updates
  Stream<Position>? _positionStream;
  Stream<Position>? get positionStream => _positionStream;

  // Check if location services are enabled
  Future<bool> _handleLocationServiceStatus() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled');
      return false;
    }
    return true;
  }

  // Request location permission
  Future<LocationPermission> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      debugPrint('Requested location permission: $permission');
    }
    
    return permission;
  }

  // Show a permission rationale dialog
  Future<bool> showPermissionRationaleDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF232F3E),
          title: const Text('Location Permission', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Wanderly needs access to your location to show you nearby places. '
            'to enhance your experience',
            style: TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            TextButton(
              child: const Text('Allow', style: TextStyle(color: Colors.tealAccent)),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  // Get address from coordinates
  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        debugPrint('Placemark: $place');
        
        // Build a more detailed address string
        List<String> addressParts = [];
        
        // Start with the most specific location (thoroughfare/street or name)
        if (place.name != null && place.name!.isNotEmpty && place.name != place.street) {
          addressParts.add(place.name!);
        }
        
        // Add street/thoroughfare if available
        if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
          addressParts.add(place.thoroughfare!);
        } else if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }
        
        // Add sublocality or area
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        
        // Add locality/city
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        
        // Create the address string from parts, avoiding duplicates
        String address = '';
        Set<String> uniqueParts = {};
        
        for (String part in addressParts) {
          if (uniqueParts.add(part)) {
            if (address.isNotEmpty) address += ', ';
            address += part;
          }
        }
        
        // If we still don't have enough info, add administrative area
        if (address.isEmpty || addressParts.length < 2) {
          if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) {
            String part = place.subAdministrativeArea!;
            if (uniqueParts.add(part)) {
              if (address.isNotEmpty) address += ', ';
              address += part;
            }
          }
        }
        
        _currentAddress = address.isNotEmpty ? address : "Unknown location";
        return _currentAddress;
      }
      return "Unknown location";
    } catch (e) {
      debugPrint('Error getting address: $e');
      return "Unable to get address";
    }
  }

  // Check and request permission, then get location
  Future<Position?> getCurrentLocation(BuildContext context) async {
    debugPrint('Getting current location...');
    
    // First check if location services are enabled
    bool serviceEnabled = await _handleLocationServiceStatus();
    if (!serviceEnabled) {
      // Show a dialog to ask the user to enable location services
      final enableServices = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            backgroundColor: const Color(0xFF232F3E),
            title: const Text('Location Services Disabled', style: TextStyle(color: Colors.white)),
            content: const Text(
              'Please enable location services to use this feature.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
              ),
              TextButton(
                child: const Text('Open Settings', style: TextStyle(color: Colors.tealAccent)),
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                  Geolocator.openLocationSettings();
                },
              ),
            ],
          );
        },
      );
      
      if (enableServices != true) {
        return null;
      }
      
      // Check again after user interaction
      serviceEnabled = await _handleLocationServiceStatus();
      if (!serviceEnabled) {
        return null;
      }
    }

    // Then check and request permission
    
    final showRationale = await showPermissionRationaleDialog(context);
    if (!showRationale) {
      return null;
    }
    
    final permission = await _requestLocationPermission();
    
    if (permission == LocationPermission.denied || 
        permission == LocationPermission.deniedForever) {
      // Show a dialog to inform the user that they need to grant permission
      await showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            backgroundColor: const Color(0xFF232F3E),
            title: const Text('Permission Required', style: TextStyle(color: Colors.white)),
            content: const Text(
              'Location permission is required to use this feature. '
              'Please grant the permission in the app settings.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
              TextButton(
                child: const Text('Open Settings', style: TextStyle(color: Colors.tealAccent)),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  openAppSettings();
                },
              ),
            ],
          );
        },
      );
      return null;
    }
    
    try {
      // First try to get the last known position as a quick initial value
      Position? lastKnownPosition = await getLastKnownPosition();
      if (lastKnownPosition != null) {
        _currentPosition = lastKnownPosition;
        debugPrint('Last known location: ${lastKnownPosition.latitude}, ${lastKnownPosition.longitude}');
        
        // Get address from last known position
        await getAddressFromCoordinates(lastKnownPosition.latitude, lastKnownPosition.longitude);
      }
      
      // Then get the current position with high accuracy
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      
      _currentPosition = position;
      debugPrint('Current location: ${position.latitude}, ${position.longitude}');
      
      // Get address from current position
      await getAddressFromCoordinates(position.latitude, position.longitude);
      
      return position;
    } catch (e) {
      debugPrint('Error getting location: $e');
      // If getting the current position fails, try to return the last known position
      if (_currentPosition != null) {
        return _currentPosition;
      }
      return null;
    }
  }

  // Get the last known position
  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      debugPrint('Error getting last known location: $e');
      return null;
    }
  }
  
  // Start listening to location updates
  Stream<Position> getPositionStream() {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update if moved 10 meters
    );
    
    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings);
    return _positionStream!;
  }

  // Get coordinates from place name using forward geocoding
  Future<Map<String, double>?> getCoordinatesFromPlaceName(String placeName) async {
    try {
      // Append Jaipur to improve accuracy for local landmarks
      String searchQuery = "$placeName, Jaipur, Rajasthan, India";
      debugPrint('Searching for coordinates of: $searchQuery');
      
      List<Location> locations = await locationFromAddress(searchQuery);
      if (locations.isNotEmpty) {
        debugPrint('Found coordinates: ${locations[0].latitude}, ${locations[0].longitude}');
        return {
          'latitude': locations[0].latitude,
          'longitude': locations[0].longitude,
        };
      }
      
      // If not found with Jaipur, try just the place name
      if (placeName.toLowerCase().contains('jaipur')) {
        locations = await locationFromAddress(placeName);
        if (locations.isNotEmpty) {
          debugPrint('Found coordinates using place name only: ${locations[0].latitude}, ${locations[0].longitude}');
          return {
            'latitude': locations[0].latitude,
            'longitude': locations[0].longitude,
          };
        }
      }
      
      debugPrint('No coordinates found for $placeName');
      return null;
    } catch (e) {
      debugPrint('Error getting coordinates: $e');
      return null;
    }
  }
}
