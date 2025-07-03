import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wanderly_android/screen/Maps.dart';
import 'package:wanderly_android/screen/food_spots_screen.dart';
import 'package:wanderly_android/screen/landmarks_screen.dart';
import 'package:wanderly_android/services/location_service.dart';
import 'package:wanderly_android/pages/route_optimizer_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoadingLocation = false;

  final List<Map<String, String>> _itinerary = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationPermission();
    });
  }

  Future<void> _requestLocationPermission() async {
    setState(() {
      _isLoadingLocation = true;
    });

    final locationService = LocationService();
    final position = await locationService.getCurrentLocation(context);

    setState(() {
      _isLoadingLocation = false;
    });

    if (position != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location accessed successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _removeFromItinerary(Map<String, String> item) {
    setState(() {
      _itinerary.remove(item);
    });
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
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: PlaceCard(
                            city: 'Hawa Mahal',
                            distance: '1.0 mi',
                            rating: '4.8',
                            color: Colors.orange,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: PlaceCard(
                            city: 'Amber Fort',
                            distance: '2.5 mi',
                            rating: '4.7',
                            color: Colors.pink,
                          ),
                        ),
                        PlaceCard(
                          city: 'City Palace',
                          distance: '3.0 mi',
                          rating: '4.6',
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
                      _categoryIcon(Icons.account_balance, 'Landmarks', Colors.cyan, onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LandmarksScreen(
                              itinerary: _itinerary,
                              onItineraryChanged: (updatedList) {
                                setState(() {
                                  _itinerary.clear();
                                  _itinerary.addAll(updatedList);
                                });
                              },
                            ),
                          ),
                        );
                      }),
                      _categoryIcon(Icons.restaurant, 'Food', Colors.orange, onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FoodSpotsScreen(
                              itinerary: _itinerary,
                              onItineraryChanged: (updatedList) {
                                setState(() {
                                  _itinerary.clear();
                                  _itinerary.addAll(updatedList);
                                });
                              },
                            ),
                          ),
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
                      _categoryIcon(Icons.route, 'Optimize Route', Colors.green, onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RouteOptimizerPage()),
                        );
                      }),
                    ],
                  ),
                  SizedBox(height: 30),

                  // Itinerary Section
                  const Text(
                    'Itinerary',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- DRAGGABLE ITINERARY WITH THREAD ---
                  if (_itinerary.isNotEmpty)
                    SizedBox(
                      height: 90.0 * _itinerary.length,
                      child: Stack(
                        children: [
                          // Thread connecting the cards
                          Positioned.fill(
                            child: CustomPaint(
                              painter: ThreadPainter(_itinerary.length),
                            ),
                          ),
                          // Draggable, reorderable cards
                          ReorderableListView(
                            buildDefaultDragHandles: false,
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                if (newIndex > oldIndex) newIndex -= 1;
                                final item = _itinerary.removeAt(oldIndex);
                                _itinerary.insert(newIndex, item);
                              });
                            },
                            children: [
                              for (int i = 0; i < _itinerary.length; i++)
                                KeyedSubtree(
                                  key: ValueKey(_itinerary[i]['name']),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Card(
                                      color: Colors.teal.shade900,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      child: ListTile(
                                        title: Text(
                                          _itinerary[i]['name']!,
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                        subtitle: Text(
                                          _itinerary[i]['type']!,
                                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                                              onPressed: () => _removeFromItinerary(_itinerary[i]),
                                            ),
                                            ReorderableDragStartListener(
                                              index: i,
                                              child: const Icon(Icons.drag_handle, color: Colors.white54),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
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

// --- PlaceCard Widget using Pixabay API ---
class PlaceCard extends StatefulWidget {
  final String city;
  final String distance;
  final String rating;
  final Color color;

  const PlaceCard({
    super.key,
    required this.city,
    required this.distance,
    required this.rating,
    required this.color,
  });

  @override
  State<PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard> {
  String? imageUrl;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchImage();
  }

  Future<void> fetchImage() async {
    const apiKey = '51063287-f162e7a21f1002a62a82f67c3'; // <-- Replace with your Pixabay API key
    final query = 'Jaipur ${widget.city} monument tourist place';
    final url = Uri.parse(
        'https://pixabay.com/api/?key=$apiKey&q=${Uri.encodeComponent(query)}&image_type=photo&per_page=3');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['hits'] != null && data['hits'].isNotEmpty) {
        setState(() {
          imageUrl = data['hits'][0]['webformatURL'];
          loading = false;
        });
      } else {
        setState(() {
          imageUrl = null;
          loading = false;
        });
      }
    } else {
      setState(() {
        imageUrl = null;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 210,
      decoration: BoxDecoration(
        color: Color(0xFF232F3E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            child: loading
                ? Container(
                    color: Colors.grey,
                    height: 90,
                    width: 160,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: widget.color,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : (imageUrl != null
                    ? Image.network(
                        imageUrl!,
                        height: 90,
                        width: 160,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey,
                        height: 90,
                        width: 160,
                        child: Center(
                          child: Icon(Icons.landscape, size: 40, color: Colors.white54),
                        ),
                      )),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.city,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 14),
                    SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        widget.distance,
                        style: TextStyle(color: Colors.white70, fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      widget.rating,
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                SizedBox(
                  height: 28,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.color,
                      shape: StadiumBorder(),
                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
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
}

// --- CustomPainter for the thread connecting itinerary cards ---
class ThreadPainter extends CustomPainter {
  final int count;
  ThreadPainter(this.count);

  @override
  void paint(Canvas canvas, Size size) {
    if (count < 2) return;
    final paint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 2.5;

    final double cardHeight = 90.0;
    final double cardCenterX = size.width / 2;

    for (int i = 0; i < count - 1; i++) {
      final startY = cardHeight * i + cardHeight / 2;
      final endY = cardHeight * (i + 1) + cardHeight / 2;
      canvas.drawLine(
        Offset(cardCenterX, startY),
        Offset(cardCenterX, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ThreadPainter oldDelegate) => oldDelegate.count != count;
}