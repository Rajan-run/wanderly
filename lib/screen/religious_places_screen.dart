import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:wanderly_android/services/location_service.dart';
import 'package:wanderly_android/models/route_optimizer.dart';
import 'package:wanderly_android/screen/maps.dart';

class ReligiousPlacesScreen extends StatefulWidget {
  final List<Map<String, String>>? itinerary;
  final void Function(List<Map<String, String>> updated)? onItineraryChanged;

  const ReligiousPlacesScreen({
    super.key,
    this.itinerary,
    this.onItineraryChanged,
  });

  @override
  State<ReligiousPlacesScreen> createState() => _ReligiousPlacesScreenState();
}

class _ReligiousPlacesScreenState extends State<ReligiousPlacesScreen> {
  final LocationService _locationService = LocationService();

  final List<String> _religions = [
    'Hindu',
    'Muslim',
    'Christian',
    'Jain',
    'Sikh',
    'Buddhist',
    'Other',
  ];

  final List<Map<String, dynamic>> _allPlaces = [
    {
      'name': 'Birla Mandir',
      'religion': 'Hindu',
      'description': 'Modern white marble temple dedicated to Lord Vishnu.',
      'distance': '3.2 mi',
      'rating': '4.5',
      'latitude': 26.8922,
      'longitude': 75.8153,
    },
    {
      'name': 'Galta Ji Temple',
      'religion': 'Hindu',
      'description': 'Ancient temple complex with sacred water tanks.',
      'distance': '6.0 mi',
      'rating': '4.6',
      'latitude': 26.9168,
      'longitude': 75.8588,
    },
    {
      'name': 'St. Xavier\'s Church',
      'religion': 'Christian',
      'description': 'Historic church in Jaipur.',
      'distance': '5.0 mi',
      'rating': '4.4',
    },
    {
      'name': 'Jama Masjid',
      'religion': 'Muslim',
      'description': 'Famous mosque in Jaipur.',
      'distance': '7.0 mi',
      'rating': '4.5',
    },
    {
      'name': 'Sanganer Jain Temple',
      'religion': 'Jain',
      'description': 'Beautiful Jain temple known for its intricate carvings.',
      'distance': '39.0 mi',
      'rating': '4.6',
    },
  {
    "name": "Birla Mandir",
    "religion": "Hindu",
    "description": "Modern white marble temple dedicated to Lord Vishnu.",
    "distance": "3.2 mi",
    "rating": "4.5",
  },
  {
    "name": "Galta Ji Temple",
    "religion": "Hindu",
    "description": "Ancient temple complex with sacred water tanks.",
    "distance": "6.0 mi",
    "rating": "4.6",
  },
  {
    "name": "Garh Ganesh Temple",
    "religion": "Hindu",
    "description": "Hilltop temple dedicated to Lord Ganesha in child form.",
    "distance": "4.5 mi",
    "rating": "4.5",
  },
  {
    "name": "Shila Devi Mandir",
    "religion": "Hindu",
    "description": "Historic temple of Goddess Durga inside Amber Fort.",
    "distance": "7.5 mi",
    "rating": "4.6",
  },
  {
    "name": "Akshardham Temple",
    "religion": "Hindu",
    "description": "Modern temple dedicated to Lord Vishnu with beautiful gardens.",
    "distance": "5.2 mi",
    "rating": "4.6",
  },
  {
    "name": "Jagat Shiromani Temple",
    "religion": "Hindu",
    "description": "Temple dedicated to Lord Krishna and Meera Bai.",
    "distance": "7.8 mi",
    "rating": "4.5",
  },
  {
    "name": "Govind Dev Ji Temple",
    "religion": "Hindu",
    "description": "Sacred temple of Lord Krishna in City Palace complex.",
    "distance": "3.0 mi",
    "rating": "4.7",
    "latitude": 26.9260,
    "longitude": 75.8235
  },
  {
    "name": "Moti Dungri Ganesh Temple",
    "religion": "Hindu",
    "description": "Popular Ganesh temple near Birla Mandir.",
    "distance": "3.3 mi",
    "rating": "4.6",
    "latitude": 26.8945,
    "longitude": 75.8130
  },
  {
    "name": "Kale Hanuman Temple",
    "religion": "Hindu",
    "description": "Unique temple with black idol of Lord Hanuman.",
    "distance": "3.8 mi",
    "rating": "4.5",
  },
  {
    "name": "Tarkeshwar Mahadev Temple",
    "religion": "Hindu",
    "description": "Ancient Shiva temple known for peaceful ambiance.",
    "distance": "4.0 mi",
    "rating": "4.4",
  },
  {
    "name": "Khole Ke Hanuman Ji Temple",
    "religion": "Hindu",
    "description": "Temple in a scenic valley dedicated to Lord Hanuman.",
    "distance": "6.5 mi",
    "rating": "4.6",
  },
  {
    "name": "Sun Temple",
    "religion": "Hindu",
    "description": "Temple dedicated to the Sun God with panoramic views.",
    "distance": "6.2 mi",
    "rating": "4.5",
  },
  {
    "name": "Shri Digambar Jain Temple",
    "religion": "Jain",
    "description": "Ancient Jain temple in Sanganer with red stone architecture.",
    "distance": "39.2 mi",
    "rating": "4.6",
  },
  {
    "name": "Sri Sri Radha Govind Temple (ISKCON)",
    "religion": "Hindu",
    "description": "Part of ISKCON movement, dedicated to Lord Krishna.",
    "distance": "5.5 mi",
    "rating": "4.6",
  },
  {
    "name": "Shri Kali Temple",
    "religion": "Hindu",
    "description": "Temple dedicated to Goddess Kali, known for its spiritual energy.",
    "distance": "3.5 mi",
    "rating": "4.5",
  },
  {
    "name": "Hanuman Temple, Chandpole",
    "religion": "Hindu",
    "description": "Old Hanuman temple near Chandpole Gate.",
    "distance": "4.2 mi",
    "rating": "4.4",
  },
    // ...add more places for each religion
  ];

  List<String> _selectedReligions = ['Hindu'];
  late List<Map<String, String>> _itinerary;

  @override
  void initState() {
    super.initState();
    _itinerary = widget.itinerary != null
        ? List<Map<String, String>>.from(widget.itinerary!)
        : [];
  }

  Future<void> _addToItinerary(Map<String, dynamic> item) async {
    if (!_itinerary.any((i) => i['name'] == item['name'] && i['type'] == item['type'])) {
      if (item['latitude'] == null || item['longitude'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 16),
                Text('Finding coordinates for ${item['name']}...'),
              ],
            ),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 10),
          ),
        );

        final coordinates = await _locationService.getCoordinatesFromPlaceName(item['name']);
        if (!mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        if (coordinates != null) {
          item['latitude'] = coordinates['latitude'];
          item['longitude'] = coordinates['longitude'];
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not find location for ${item['name']}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }
      }

      setState(() {
        _itinerary.add({
          'name': item['name'],
          'type': item['type'],
          'latitude': item['latitude'].toString(),
          'longitude': item['longitude'].toString(),
        });
      });
      widget.onItineraryChanged?.call(_itinerary);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item['name']} added to your itinerary'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'VIEW ON MAP',
            textColor: Colors.white,
            onPressed: () => _navigateToMapWithItinerary(),
          ),
        ),
      );
    }
  }

  void _removeFromItinerary(Map<String, dynamic> item) {
    setState(() {
      _itinerary.removeWhere((i) => i['name'] == item['name'] && i['type'] == item['type']);
    });
    widget.onItineraryChanged?.call(_itinerary);
  }

  void _navigateToMapWithItinerary() {
    final List<Location> religiousLocations = _itinerary
        .where((item) =>
            item['type'] == 'Religious' &&
            item['latitude'] != null &&
            item['longitude'] != null)
        .map((item) => Location(
              name: item['name']!,
              latitude: double.parse(item['latitude']!),
              longitude: double.parse(item['longitude']!),
            ))
        .toList();

    if (religiousLocations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No valid religious locations found'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExploreNearbyScreen(
          landmarkLocations: religiousLocations,
        ),
      ),
    );
  }

  bool _isInItinerary(String name) {
    return _itinerary.any((i) => i['name'] == name && i['type'] == 'Religious');
  }

  @override
  Widget build(BuildContext context) {
    final filteredPlaces = _allPlaces
        .where((place) => _selectedReligions.contains(place['religion']))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF18222D),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade300,
        elevation: 0,
        title: const Text(
          'Religious Places',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ReligionDropdown(
              religions: _religions,
              selected: _selectedReligions,
              onChanged: (selected) {
                setState(() {
                  _selectedReligions = selected;
                });
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF18222D),
          borderRadius: BorderRadius.only(
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
                'Select Religious Places',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: ListView(
                    key: ValueKey(filteredPlaces.length),
                    children: filteredPlaces.map((place) {
                      final isAdded = _isInItinerary(place['name']!);
                      return TweenAnimationBuilder<double>(
                        key: ValueKey(place['name']),
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutBack,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, (1 - value) * 30),
                              child: child,
                            ),
                          );
                        },
                        child: ReligiousPlaceCard(
                          name: place['name']!,
                          distance: place['distance']!,
                          rating: place['rating']!,
                          description: place['description']!,
                          religion: place['religion']!,
                          cardColor: const Color(0xFF232F3E),
                          isAdded: isAdded,
                          onAdd: () => _addToItinerary({
                            'name': place['name']!,
                            'type': 'Religious',
                            'latitude': place['latitude'],
                            'longitude': place['longitude'],
                          }),
                          onRemove: () => _removeFromItinerary({
                            'name': place['name']!,
                            'type': 'Religious',
                            'latitude': place['latitude'],
                            'longitude': place['longitude'],
                          }),
                        ),
                      );
                    }).toList(),
                  ),
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
            icon: const Icon(Icons.location_on, color: Colors.deepPurple),
            onPressed: () {
              _navigateToMapWithItinerary();
            },
          ),
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white70),
            onPressed: () {
              Navigator.pop(context);
              widget.onItineraryChanged?.call(_itinerary);
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear_all, color: Colors.redAccent),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: const Color(0xFF232F3E),
                    title: const Text(
                      'Clear Itinerary',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: const Text(
                      'Are you sure you want to clear all items from your itinerary?',
                      style: TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.deepPurple),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _itinerary.clear();
                          });
                          widget.onItineraryChanged?.call(_itinerary);
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Itinerary cleared'),
                              backgroundColor: Colors.redAccent,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Text(
                          'Clear All',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          FloatingActionButton(
            backgroundColor: Colors.deepPurple,
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

// Multi-select dropdown for religions
class ReligionDropdown extends StatelessWidget {
  final List<String> religions;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const ReligionDropdown({
    super.key,
    required this.religions,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.filter_alt, color: Colors.deepPurple),
      tooltip: 'Select Religions',
      itemBuilder: (context) => religions
          .map((religion) => CheckedPopupMenuItem<String>(
                value: religion,
                checked: selected.contains(religion),
                child: Text(religion),
              ))
          .toList(),
      onSelected: (religion) {
        final newSelected = List<String>.from(selected);
        if (newSelected.contains(religion)) {
          newSelected.remove(religion);
        } else {
          newSelected.add(religion);
        }
        if (newSelected.isEmpty) newSelected.add('Hindu');
        onChanged(newSelected);
      },
    );
  }
}

// Card widget with image scraping, shimmer, fade-in, and add/delete logic
class ReligiousPlaceCard extends StatefulWidget {
  final String name;
  final String distance;
  final String rating;
  final String description;
  final String religion;
  final Color cardColor;
  final bool isAdded;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const ReligiousPlaceCard({
    super.key,
    required this.name,
    required this.distance,
    required this.rating,
    required this.description,
    required this.religion,
    required this.cardColor,
    required this.isAdded,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<ReligiousPlaceCard> createState() => _ReligiousPlaceCardState();
}

class _ReligiousPlaceCardState extends State<ReligiousPlaceCard> {
  String? imageUrl;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchImage();
  }

  Future<void> fetchImage() async {
    try {
      const apiKey = '51063287-f162e7a21f1002a62a82f67c3';
      final query = 'Jaipur ${widget.name} ${widget.religion} temple monument tourist place';
      final url = Uri.parse(
          'https://pixabay.com/api/?key=$apiKey&q=${Uri.encodeComponent(query)}&image_type=photo&per_page=3');
      final response = await http.get(url);
      if (!mounted) return; // <-- Add after every await if you use setState after it

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['hits'] != null && data['hits'].isNotEmpty) {
          if (!mounted) return;
          setState(() {
            imageUrl = data['hits'][0]['webformatURL'];
            loading = false;
          });
        } else {
          if (!mounted) return;
          setState(() {
            imageUrl = null;
            loading = false;
          });
        }
      } else {
        if (!mounted) return;
        setState(() {
          imageUrl = null;
          loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
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
              ? Shimmer.fromColors(
                  baseColor: Colors.grey[800]!,
                  highlightColor: Colors.grey[600]!,
                  child: Container(
                    width: 56,
                    height: 56,
                    color: Colors.grey[800],
                  ),
                )
              : (imageUrl != null
                  ? FadeInImage.assetNetwork(
                      placeholder: 'assets/logo.png',
                      image: imageUrl!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      fadeInDuration: const Duration(milliseconds: 400),
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
                Icon(Icons.temple_hindu, color: Colors.deepPurple, size: 16),
                const SizedBox(width: 4),
                Text(
                  widget.distance,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.rating,
                  style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.star, color: Colors.deepPurple, size: 15),
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
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
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
