import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FoodSpotsScreen extends StatefulWidget {
  final List<Map<String, String>>? itinerary;
  final void Function(List<Map<String, String>> updated)? onItineraryChanged;

  const FoodSpotsScreen({
    super.key,
    this.itinerary,
    this.onItineraryChanged,
  });

  @override
  State<FoodSpotsScreen> createState() => _FoodSpotsScreenState();
}

class _FoodSpotsScreenState extends State<FoodSpotsScreen> {
  late List<Map<String, String>> _itinerary;

  final List<Map<String, String>> _foodSpots = [
  {
    'name': 'Rawat Mishthan Bhandar',
    'distance': '1.0 mi',
    'rating': '4.6',
    'description': 'Famous for Pyaaz Kachori and Mirchi Vada.',
    'searchTerm': 'kachori',
  },
  {
    'name': 'Laxmi Mishthan Bhandar (LMB)',
    'distance': '1.2 mi',
    'rating': '4.7',
    'description': 'Iconic spot for Rajasthani sweets and thali.',
    'searchTerm': 'ghewar',
  },
  {
    'name': '1135 AD',
    'distance': '5.5 mi',
    'rating': '4.8',
    'description': 'Royal dining at Amber Fort with heritage ambiance.',
    'searchTerm': 'laal maas',
  },
  {
    'name': 'Masala Chowk',
    'distance': '2.5 mi',
    'rating': '4.5',
    'description': 'Open-air food court with 20+ street food stalls.',
    'searchTerm': 'street food',
  },
  {
    'name': 'Sanjay Omelette',
    'distance': '3.0 mi',
    'rating': '4.4',
    'description': 'Famous for 100+ egg dishes including egg pizza.',
    'searchTerm': 'omelette',
  },
  {
    'name': 'Tapri Central',
    'distance': '2.0 mi',
    'rating': '4.6',
    'description': 'Trendy rooftop café with chai and snacks.',
    'searchTerm': 'chai',
  },
  {
    'name': 'Bar Palladio',
    'distance': '2.8 mi',
    'rating': '4.5',
    'description': 'Elegant Italian restaurant in a heritage setting.',
    'searchTerm': 'italian',
  },
  {
    'name': 'Zolocrust',
    'distance': '3.5 mi',
    'rating': '4.6',
    'description': 'Live kitchen café with fresh organic ingredients.',
    'searchTerm': 'organic',
  },
  {
    'name': 'Anokhi Café',
    'distance': '2.7 mi',
    'rating': '4.4',
    'description': 'Healthy global cuisine with vegan options.',
    'searchTerm': 'vegan',
  },
  {
    'name': 'RJ14',
    'distance': '3.0 mi',
    'rating': '4.5',
    'description': 'Garden restaurant serving North Indian cuisine.',
    'searchTerm': 'north indian',
  },
  {
    'name': 'Jaipur Modern Kitchen',
    'distance': '2.9 mi',
    'rating': '4.4',
    'description': 'Fusion food with a modern twist.',
    'searchTerm': 'fusion',
  },
  {
    'name': 'The Tattoo Café & Lounge',
    'distance': '0.6 mi',
    'rating': '4.3',
    'description': 'Rooftop café with views of Hawa Mahal.',
    'searchTerm': 'coffee',
  },
  {
    'name': 'Café Bae',
    'distance': '3.2 mi',
    'rating': '4.5',
    'description': 'Stylish café with continental and desserts.',
    'searchTerm': 'desserts',
  },
  {
    'name': 'On The House',
    'distance': '3.0 mi',
    'rating': '4.4',
    'description': 'European-style café with breakfast specials.',
    'searchTerm': 'breakfast',
  },
  {
    'name': 'Brown Sugar',
    'distance': '2.5 mi',
    'rating': '4.3',
    'description': 'Bakery and café known for pastries and shakes.',
    'searchTerm': 'bakery',
  },
  {
    'name': 'Stepout Café',
    'distance': '3.1 mi',
    'rating': '4.2',
    'description': 'Cozy café with books and board games.',
    'searchTerm': 'café',
  },
  {
    'name': 'Sky Waltz Café',
    'distance': '4.0 mi',
    'rating': '4.4',
    'description': 'Hot air balloon-themed café with global menu.',
    'searchTerm': 'global',
  },
  {
    'name': 'Forresta Kitchen & Bar',
    'distance': '2.9 mi',
    'rating': '4.3',
    'description': 'Forest-themed restaurant with multi-cuisine menu.',
    'searchTerm': 'multi-cuisine',
  },
  {
    'name': 'Spice Court',
    'distance': '3.3 mi',
    'rating': '4.5',
    'description': 'Authentic Rajasthani and Mughlai dishes.',
    'searchTerm': 'mughlai',
  },
  {
    'name': 'Handi Restaurant',
    'distance': '2.6 mi',
    'rating': '4.4',
    'description': 'Known for its Handi meat and tandoori items.',
    'searchTerm': 'handi meat',
  },
  {
    'name': 'Thali & More',
    'distance': '3.5 mi',
    'rating': '4.4',
    'description': 'Modern twist on traditional Rajasthani thali.',
    'searchTerm': 'thali',
  },
  {
    'name': 'Gulab Ji Chai Wale',
    'distance': '1.8 mi',
    'rating': '4.5',
    'description': 'Legendary tea stall known for bun maska and masala chai.',
    'searchTerm': 'chai',
  },
  {
    'name': 'Jaipur Jungle',
    'distance': '4.2 mi',
    'rating': '4.3',
    'description': 'Theme restaurant with jungle decor and Indian cuisine.',
    'searchTerm': 'theme restaurant',
  },
  {
    'name': 'Nibs Café',
    'distance': '2.6 mi',
    'rating': '4.4',
    'description': 'Chic café known for chocolate desserts and shakes.',
    'searchTerm': 'chocolate',
  },
  {
    'name': 'Oven - The Bakery',
    'distance': '3.0 mi',
    'rating': '4.3',
    'description': 'Freshly baked breads, cakes, and pastries.',
    'searchTerm': 'bakery',
  },
  {
    'name': 'Fat Lulu’s',
    'distance': '3.8 mi',
    'rating': '4.5',
    'description': 'New York-style pizza and pasta joint.',
    'searchTerm': 'pizza',
  },
  {
    'name': 'Café LazyMojo',
    'distance': '3.1 mi',
    'rating': '4.4',
    'description': 'Trendy café with continental and fusion dishes.',
    'searchTerm': 'fusion',
  },
  {
    'name': 'Jaipur Adda',
    'distance': '2.9 mi',
    'rating': '4.5',
    'description': 'Rooftop lounge with quirky décor and global menu.',
    'searchTerm': 'rooftop',
  },
  {
    'name': 'House of People (HOP)',
    'distance': '3.4 mi',
    'rating': '4.3',
    'description': 'Popular bar and restaurant with live music.',
    'searchTerm': 'bar',
  },
  {
    'name': 'The Yellow Door',
    'distance': '2.7 mi',
    'rating': '4.4',
    'description': 'Cozy café with vibrant interiors and comfort food.',
    'searchTerm': 'comfort food',
  },
  {
    'name': 'Taruveda Bistro',
    'distance': '3.2 mi',
    'rating': '4.5',
    'description': 'Artistic bistro with organic and healthy meals.',
    'searchTerm': 'organic',
  },
  {
    'name': 'Café White Sage',
    'distance': '3.0 mi',
    'rating': '4.3',
    'description': 'Minimalist café with vegan and gluten-free options.',
    'searchTerm': 'vegan',
  },
  {
    'name': 'The Night Jar',
    'distance': '3.6 mi',
    'rating': '4.4',
    'description': 'Elegant dining with cocktails and fusion plates.',
    'searchTerm': 'cocktails',
  },
  {
    'name': 'Poppin Café',
    'distance': '2.5 mi',
    'rating': '4.2',
    'description': 'Colorful café with waffles and bubble tea.',
    'searchTerm': 'waffles',
  },
  {
    'name': 'The Rustic Spot Café',
    'distance': '3.3 mi',
    'rating': '4.3',
    'description': 'Rustic-themed café with hearty meals and coffee.',
    'searchTerm': 'coffee',
  },
  {
    'name': 'Café Quaint',
    'distance': '2.8 mi',
    'rating': '4.4',
    'description': 'Peaceful café with books and brunch specials.',
    'searchTerm': 'brunch',
  },
  {
    'name': 'The Eclectica',
    'distance': '3.7 mi',
    'rating': '4.5',
    'description': 'Multi-cuisine restaurant with rooftop seating.',
    'searchTerm': 'multi-cuisine',
  },
  {
    'name': 'Jaipur Baking Company',
    'distance': '3.0 mi',
    'rating': '4.4',
    'description': 'Upscale bakery with gourmet cakes and breads.',
    'searchTerm': 'gourmet',
  },
  {
    'name': 'Little Italy',
    'distance': '3.9 mi',
    'rating': '4.3',
    'description': 'Vegetarian Italian restaurant with wood-fired pizzas.',
    'searchTerm': 'italian',
  },
  {
    'name': 'Tandoori Nights',
    'distance': '4.1 mi',
    'rating': '4.2',
    'description': 'Specializes in tandoori dishes and kebabs.',
    'searchTerm': 'tandoori',
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
    return _itinerary.any((i) => i['name'] == name && i['type'] == 'Food');
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFF18222D);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.orange.shade300,
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
                'Local Food Spots',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: _foodSpots.map((food) {
                    final isAdded = _isInItinerary(food['name']!);
                    return FoodCard(
                      searchTerm: food['searchTerm']!,
                      name: food['name']!,
                      distance: food['distance']!,
                      rating: food['rating']!,
                      description: food['description']!,
                      cardColor: const Color(0xFF232F3E),
                      isAdded: isAdded,
                      onAdd: () => _addToItinerary({
                        'name': food['name']!,
                        'type': 'Food',
                      }),
                      onRemove: () => _removeFromItinerary({
                        'name': food['name']!,
                        'type': 'Food',
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
            backgroundColor: Colors.orange,
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

class FoodCard extends StatefulWidget {
  final String searchTerm;
  final String name;
  final String distance;
  final String rating;
  final String description;
  final Color cardColor;
  final bool isAdded;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const FoodCard({
    super.key,
    required this.searchTerm,
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
  State<FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> {
  String? imageUrl;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchImage();
  }

  Future<void> fetchImage() async {
    const apiKey = '51063287-f162e7a21f1002a62a82f67c3'; // <-- Replace with your Pixabay API key
    final url = Uri.parse(
        'https://pixabay.com/api/?key=$apiKey&q=${Uri.encodeComponent(widget.searchTerm + " food")}&image_type=photo&per_page=3');
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
                Icon(Icons.location_on, color: Colors.orange, size: 16),
                const SizedBox(width: 4),
                Text(
                  widget.distance,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.rating,
                  style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.star, color: Colors.orange, size: 15),
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
                          label: const Text('Added',style: TextStyle(color: Colors.green),),
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
                        backgroundColor: Colors.orange,
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