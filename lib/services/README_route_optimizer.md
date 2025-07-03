# Route Optimizer for Wanderly

This module provides route optimization capabilities for Wanderly, using OpenRouteService to calculate efficient routes between multiple locations.

## Features

- Sort locations to create the most efficient travel route
- Start from any designated location
- Calculate routes based on actual travel times/distances
- Display optimized routes on an OpenStreetMap interface
- Support for multiple waypoints

## How to Use

1. Launch the route optimizer page from your Wanderly app
2. Add locations you want to visit (either by searching or using your current location)
3. Click "Optimize Route" to calculate the most efficient travel order
4. View the optimized route on the map and follow the numbered sequence

## Technical Implementation

The route optimizer uses:
- OpenRouteService API for distance matrix calculations
- Nearest neighbor algorithm for route optimization
- Flutter Map for visualization

## Getting Started

To run the route optimizer:

```dart
import 'package:flutter/material.dart';
import 'package:wanderly_android/route_optimizer_main.dart';

void main() {
  runApp(const RouteOptimizerApp());
}
```

Or include the `RouteOptimizerPage` in your existing navigation:

```dart
Navigator.of(context).push(
  MaterialPageRoute(builder: (context) => const RouteOptimizerPage()),
);
```

## Algorithm Details

The route optimizer uses a "nearest neighbor" approach:
1. Start at the first location in your list
2. Find the closest unvisited location
3. Move to that location
4. Repeat steps 2-3 until all locations are visited

While this doesn't guarantee the absolute optimal route (which would require trying all permutations), it's efficient and produces good results for a small number of locations (typically under 10).

## Notes on API Usage

The OpenRouteService API has usage limits on the free tier:
- 2,000 requests per day
- 40 requests per minute

For production usage with higher volumes, consider:
1. Upgrading to a paid plan
2. Implementing caching strategies
3. Self-hosting the routing service
