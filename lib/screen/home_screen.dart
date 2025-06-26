// Example: lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:wanderly_android/screen/Maps.dart';
import 'package:wanderly_android/screen/food_spots_screen.dart';
import 'package:wanderly_android/screen/landmarks_screen.dart';
import 'package:wanderly_android/services/location_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    // Request location permission when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationPermission();
    });
  }
  
  Future<void> _requestLocationPermission() async {
    setState(() {
      _isLoadingLocation = true;
    });
    
    // Import location service at the top of the file
    final locationService = LocationService();
    final position = await locationService.getCurrentLocation(context);
    
    setState(() {
      _isLoadingLocation = false;
    });
    
    if (position != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location accessed successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = Color(0xFF18222D);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF1E2A38),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.tealAccent),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.tealAccent),
                            ),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Icon(Icons.mic, color: Colors.tealAccent),
                        SizedBox(width: 10),
                        Icon(Icons.menu, color: Colors.tealAccent),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),

                  // Nearby Places
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nearby Places',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.orange,
                        child: IconButton(
                          icon: const Icon(Icons.location_on, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ExploreNearbyScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    height: 210,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _placeCard(
                          image: 'assets/sf.jpg',
                          city: 'San Francisco',
                          distance: '0.5 mi',
                          rating: '4.4.8',
                          color: Colors.orange,
                        ),
                        SizedBox(width: 16),
                        _placeCard(
                          image: 'assets/tokyo.jpg',
                          city: 'Tokyo',
                          distance: '1.2 mi',
                          rating: '4.7',
                          color: Colors.pink,
                        ),
                        SizedBox(width: 16),
                        _placeCard(
                          image: 'assets/sydney.jpg',
                          city: 'Sydney',
                          distance: '2.0 mi',
                          rating: '4.6.5',
                          color: Colors.purple,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),

                  // Popular Categories
                  Text(
                    'Popular Categories',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _categoryIcon(Icons.account_balance, 'Landmarks', Colors.cyan, onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LandmarksScreen()),
                        );
                      }),
                      _categoryIcon(Icons.restaurant, 'Food', Colors.orange, onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FoodSpotsScreen()),
                        );
                      }),
                      _categoryIcon(Icons.surfing, 'Activities', Colors.purple),
                      _categoryIcon(Icons.event, 'Events', Colors.indigo),
                      _categoryIcon(Icons.map, 'View Map', Colors.cyan, onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ExploreNearbyScreen()),
                        );
                      }),
                    ],
                  ),
                  SizedBox(height: 30),

                  // Trending Now (Placeholder)
                  Text(
                    'Trending Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Add trending items here...
                ],
              ),
            ),
          ),
          
          // Loading overlay
          if (_isLoadingLocation)
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
        ],
      ),
    );
  }

  Widget _placeCard({
    required String image,
    required String city,
    required String distance,
    required String rating,
    required Color color,
  }) {
    return Container(
      width: 160,
      height: 210, // Fixed height to prevent overflow
      decoration: BoxDecoration(
        color: Color(0xFF232F3E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Use minimum space needed
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            child: Container(
              color: Colors.grey, // Placeholder for actual image
              height: 90, // Reduced height slightly
              width: 160,
              child: Center(
                child: Icon(Icons.landscape, size: 40, color: Colors.white54),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0), // Reduced padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Use minimum space needed
              children: [
                Text(
                  city,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14, // Reduced font size
                  ),
                  overflow: TextOverflow.ellipsis, // Handle text overflow
                ),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 14), // Smaller icon
                    SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        distance,
                        style: TextStyle(color: Colors.white70, fontSize: 10), // Smaller text
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      rating,
                      style: TextStyle(color: Colors.white70, fontSize: 10), // Smaller text
                    ),
                  ],
                ),
                SizedBox(height: 8), // Reduced spacing
                SizedBox( // Wrap button in SizedBox to control size
                  height: 28, // Set specific button height
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      shape: StadiumBorder(),
                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 8), // Smaller padding
                    ),
                    onPressed: () {},
                    child: Text('Explore', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _categoryIcon(IconData icon, String label, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            radius: 28,
            child: Icon(icon, color: color, size: 28),
          ),
          SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}