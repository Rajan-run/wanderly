// Example: lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:wanderly_android/screen/Maps.dart';
import 'package:wanderly_android/screen/food_spots_screen.dart';
import 'package:wanderly_android/screen/landmarks_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color bgColor = Color(0xFF18222D);
    final Color cardColor = Color(0xFF232F3E);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
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
                  _viewMapButton(),
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
      decoration: BoxDecoration(
        color: Color(0xFF232F3E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.asset(
              image,
              height: 110,
              width: 160,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 16),
                    SizedBox(width: 4),
                    Text(
                      distance,
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    SizedBox(width: 8),
                    Text(
                      rating,
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    shape: StadiumBorder(),
                  ),
                  onPressed: () {},
                  child: Text('Explore'),
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

  Widget _viewMapButton() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Color(0xFF232F3E),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.all(8),
          child: Icon(Icons.map, color: Colors.cyan, size: 32),
        ),
        SizedBox(height: 6),
        Text(
          'View Map',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}