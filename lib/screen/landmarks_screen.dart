import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LandmarksScreen extends StatefulWidget {
  final List<Map<String, String>>? itinerary;
  final void Function(List<Map<String, String>> updated)? onItineraryChanged;

  const LandmarksScreen({
    super.key,
    this.itinerary,
    this.onItineraryChanged,
  });

  @override
  State<LandmarksScreen> createState() => _LandmarksScreenState();
}

class _LandmarksScreenState extends State<LandmarksScreen> {
  late List<Map<String, String>> _itinerary;

  final List<Map<String, String>> _landmarks = [
    {
      'name': 'Hawa Mahal',
      'distance': '0.5 mi',
      'rating': '4.9',
      'description': 'Iconic palace with a unique facade.',
    },
    {
      'name': 'Amber Fort',
      'distance': '1.2 mi',
      'rating': '4.8',
      'description': 'Majestic fort with artistic Hindu style.',
    },
    {
      'name': 'City Palace',
      'distance': '2.0 mi',
      'rating': '4.7',
      'description': 'Royal residence with museums and courtyards.',
    },
    {
      'name': 'Jantar Mantar',
      'distance': '3.5 mi',
      'rating': '4.8',
      'description': 'Historic astronomical observatory.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _itinerary = widget.itinerary != null
        ? List<Map<String, String>>.from(widget.itinerary!)
        : [];
  }

  void _addToItinerary(Map<String, String> item) {
    if (!_itinerary.any((i) => i['name'] == item['name'] && i['type'] == item['type'])) {
      setState(() {
        _itinerary.add(item);
      });
      widget.onItineraryChanged?.call(_itinerary);
    }
  }

  void _removeFromItinerary(Map<String, String> item) {
    setState(() {
      _itinerary.removeWhere((i) => i['name'] == item['name'] && i['type'] == item['type']);
    });
    widget.onItineraryChanged?.call(_itinerary);
  }

  bool _isInItinerary(String name) {
    return _itinerary.any((i) => i['name'] == name && i['type'] == 'Landmark');
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFF18222D);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.cyan.shade300,
        elevation: 0,
        title: const Text(
          'Wonderly',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Famous Landmarks',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: _landmarks.map((landmark) {
                    final isAdded = _isInItinerary(landmark['name']!);
                    return LandmarkCard(
                      name: landmark['name']!,
                      distance: landmark['distance']!,
                      rating: landmark['rating']!,
                      description: landmark['description']!,
                      cardColor: const Color(0xFF232F3E),
                      isAdded: isAdded,
                      onAdd: () => _addToItinerary({
                        'name': landmark['name']!,
                        'type': 'Landmark',
                      }),
                      onRemove: () => _removeFromItinerary({
                        'name': landmark['name']!,
                        'type': 'Landmark',
                      }),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _bottomNavBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _bottomNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF232F3E),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.location_on, color: Colors.cyan),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.grid_view, color: Colors.white70),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            onPressed: () {},
          ),
          FloatingActionButton(
            backgroundColor: Colors.cyan,
            onPressed: () {},
            mini: true,
            elevation: 0,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class LandmarkCard extends StatefulWidget {
  final String name;
  final String distance;
  final String rating;
  final String description;
  final Color cardColor;
  final bool isAdded;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const LandmarkCard({
    super.key,
    required this.name,
    required this.distance,
    required this.rating,
    required this.description,
    required this.cardColor,
    required this.isAdded,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<LandmarkCard> createState() => _LandmarkCardState();
}

class _LandmarkCardState extends State<LandmarkCard> {
  String? imageUrl;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchImage();
  }

  Future<void> fetchImage() async {
    const apiKey = '51063287-f162e7a21f1002a62a82f67c3'; // <-- Replace with your Pixabay API key
    final query = 'Jaipur ${widget.name} monument tourist place';
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
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: widget.cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: loading
              ? Container(
                  width: 56,
                  height: 56,
                  color: Colors.grey[800],
                  child: const Center(child: CircularProgressIndicator()),
                )
              : (imageUrl != null
                  ? Image.network(
                      imageUrl!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 56,
                      height: 56,
                      color: Colors.grey,
                      child: const Icon(Icons.broken_image, color: Colors.white),
                    )),
        ),
        title: Text(
          widget.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.cyan, size: 16),
                const SizedBox(width: 4),
                Text(
                  widget.distance,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.rating,
                  style: const TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.star, color: Colors.cyan, size: 15),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              widget.description,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: widget.isAdded
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                          onPressed: null,
                          icon: const Icon(Icons.check, color: Colors.green),
                          label: const Text('Added',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: widget.onRemove,
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      onPressed: widget.onAdd,
                      child: const Text('Add to Itinerary'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}