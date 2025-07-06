import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wanderly_android/screen/Maps.dart';
import 'package:wanderly_android/models/route_optimizer.dart';
import 'package:wanderly_android/services/location_service.dart';

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
  final LocationService _locationService = LocationService();

  final List<Map<String, dynamic>> _landmarks = [
    {
      'name': 'Hawa Mahal',
      'distance': '0.5 mi',
      'rating': '4.9',
      'description': 'Iconic palace with a unique facade.',
      'latitude': 26.9239,
      'longitude': 75.8267,
    },
    {
      'name': 'Amber Fort',
      'distance': '1.2 mi',
      'rating': '4.8',
      'description': 'Majestic fort with artistic Hindu style.',
      'latitude': 26.9855,
      'longitude': 75.8513,
    },
    {
      'name': 'City Palace',
      'distance': '2.0 mi',
      'rating': '4.7',
      'description': 'Royal residence with museums and courtyards.',
      'latitude': 26.9258,
      'longitude': 75.8237,
    },
    {
      'name': 'Jantar Mantar',
      'distance': '3.5 mi',
      'rating': '4.8',
      'description': 'Historic astronomical observatory.',
      'latitude': 26.9246,
      'longitude': 75.8242,
    },
    {
      'name': 'Nahargarh Fort',
      'distance': '4.0 mi',
      'rating': '4.6',
      'description': 'Scenic fort with panoramic views of Jaipur.',
    },
    {
      'name': 'Albert Hall Museum',
      'distance': '2.8 mi',
      'rating': '4.5',
      'description': 'Museum showcasing Indo-Saracenic architecture.',
    },
    {
      'name': 'Jal Mahal',
      'distance': '3.0 mi',
      'rating': '4.7',
      'description': 'Palace located in the middle of Man Sagar Lake.',
    },
    {
      'name': 'Sisodia Rani Garden',
      'distance': '5.0 mi',
      'rating': '4.4',
      'description': 'Beautiful garden with fountains and murals.',
    },
    {
      'name': 'Galta Ji Temple',
      'distance': '6.0 mi',
      'rating': '4.6',
      'description': 'Ancient temple complex with sacred water tanks.',
    },
    {
      'name': 'Birla Mandir',
      'distance': '3.2 mi',
      'rating': '4.5',
      'description': 'Modern white marble temple dedicated to Lord Vishnu.',
    },
    {
      'name': 'Raj Mandir Cinema',
      'distance': '2.5 mi',
      'rating': '4.3',
      'description': 'Famous cinema hall known for its grand architecture.',
    },
    {
    'name': 'Jaigarh Fort',
    'distance': '5.5 mi',
    'rating': '4.6',
    'description': 'Fort with panoramic views and the world’s largest cannon on wheels.',
    },
    {
    'name': 'Panna Meena Ka Kund',
    'distance': '6.0 mi',
    'rating': '4.5',
    'description': 'Historic stepwell with symmetrical staircases.',
    },
    {
      'name': 'Chand Baori',
      'distance': '7.0 mi',
      'rating': '4.8',
      'description': 'One of the largest stepwells in the world, located in Abhaneri.',
    },
    {
      'name': 'Samode Haveli',
      'distance': '8.0 mi',
      'rating': '4.7',
      'description': 'Heritage hotel with stunning architecture and gardens.',
    },
    {
      'name': 'Elefantastic',
      'distance': '9.0 mi',
      'rating': '4.9',
      'description': 'Elephant sanctuary offering rides and interactions.',
    },
    {
      'name': 'Chokhi Dhani',
      'distance': '10.0 mi',
      'rating': '4.6',
      'description': 'Cultural village resort showcasing Rajasthani traditions.',
    },
    {
      'name': 'Nahargarh Biological Park',
      'distance': '11.0 mi',
      'rating': '4.5',
      'description': 'Wildlife park with diverse flora and fauna.',
    },
    {
      'name': 'Maharani Ki Chhatriyan',
      'distance': '12.0 mi',
      'rating': '4.4',
      'description': 'Royal cenotaphs with intricate carvings.',
    },
    {
      'name': 'Gaitor Ki Chhatriyan',
      'distance': '13.0 mi',
      'rating': '4.5',
      'description': 'Memorials of the Kachwaha rulers with beautiful architecture.',
    },
    {
      'name': 'Isarlat',
      'distance': '14.0 mi',
      'rating': '4.3',
      'description': 'Historical tower offering panoramic views of the city.',
    },
    {
      'name': 'Moti Dungri Ganesh Temple',
      'distance': '15.0 mi',
      'rating': '4.6',
      'description': 'Famous temple dedicated to Lord Ganesha.',
    },
    {
      'name': 'Jawahar Circle',
      'distance': '16.0 mi',
      'rating': '4.4',
      'description': 'Largest circular park in Asia with musical fountains.',
    },
    {
      'name': 'World Trade Park',
      'distance': '17.0 mi',
      'rating': '4.5',
      'description': 'Modern shopping mall with a unique architectural design.',
    },
    {
      'name': 'Birla Planetarium',
      'distance': '18.0 mi',
      'rating': '4.3',
      'description': 'Planetarium showcasing astronomy and space science.',
    },
    {
      'name': 'Jawahar Kala Kendra',
      'distance': '19.0 mi',
      'rating': '4.6',
      'description': 'Cultural center promoting Rajasthani arts and crafts.',
    },
    {
      'name': 'Sanganer Fort',
      'distance': '20.0 mi',
      'rating': '4.5',
      'description': 'Historic fort known for its intricate carvings and architecture.',
    },
    {
      'name': 'Rambagh Palace',
      'distance': '21.0 mi',
      'rating': '4.8',
      'description': 'Luxury hotel with royal heritage and stunning gardens.',
    },
    {
      'name': 'Sisodia Rani Palace and Garden',
      'distance': '22.0 mi',
      'rating': '4.7',
      'description': 'Beautiful palace with terraced gardens and fountains.',
    },
    {
      'name': 'Kishangarh Fort',
      'distance': '23.0 mi',
      'rating': '4.6',
      'description': 'Historic fort with stunning architecture and panoramic views.',
    },
    {
      'name': 'Bapu Bazaar',
      'distance': '24.0 mi',
      'rating': '4.4',
      'description': 'Famous market for traditional Rajasthani handicrafts and textiles.',
    },
    {
      'name': 'Chandpol Bazaar',
      'distance': '25.0 mi',
      'rating': '4.5',
      'description': 'Historic market known for its vibrant atmosphere and local goods.',
    },
    {
      'name': 'Galta Ji',
      'distance': '26.0 mi',
      'rating': '4.6',
      'description': 'Sacred temple complex with natural springs and monkeys.',
    },
    {
      'name': 'Brahma Temple',
      'distance': '27.0 mi',
      'rating': '4.7',
      'description': 'Unique temple dedicated to Lord Brahma, located in Pushkar.',
    },
    {
      'name': 'Rani Sati Dadi Mandir',
      'distance': '32.0 mi',
      'rating': '4.4',
      'description': 'Temple dedicated to Rani Sati, a revered figure in Rajasthan.',
    },
    {
      'name': 'Chhatri of Maharaja Sawai Jai Singh II',
      'distance': '33.0 mi',
      'rating': '4.5',
      'description': 'Memorial dedicated to the founder of Jaipur.',
    },
    {
      'name': 'Sawai Mansingh Stadium',
      'distance': '34.0 mi',
      'rating': '4.3',
      'description': 'Cricket stadium hosting international matches and events.',
    },
    {
      'name': 'Rajasthan High Court',
      'distance': '35.0 mi',
      'rating': '4.6',
      'description': 'Architecturally significant building housing the state’s judiciary.',
    },
    {
      'name': 'Birla Mandir (Laxmi Narayan Temple)',
      'distance': '36.0 mi',
      'rating': '4.7',
      'description': 'Modern temple dedicated to Lord Vishnu and Goddess Laxmi.',
    },
    {
      'name': 'Jawahar Circle Garden',
      'distance': '37.0 mi',
      'rating': '4.5',
      'description': 'Largest circular park in Asia with musical fountains and gardens.',
    },
    {
      'name': 'Rajasthan State Museum',
      'distance': '38.0 mi',
      'rating': '4.4',
      'description': 'Museum showcasing Rajasthan’s rich cultural heritage.',
    },
    {
      'name': 'Sanganer Jain Temple',
      'distance': '39.0 mi',
      'rating': '4.6',
      'description': 'Beautiful Jain temple known for its intricate carvings.',
    },
    {
      'name': 'Rambagh Golf Club',
      'distance': '41.0 mi',
      'rating': '4.8',
      'description': 'Golf course set in the grounds of the historic Rambagh Palace.',
    },
    {
      'name': 'Sawai Jai Singh II\'s Observatory',
      'distance': '42.0 mi',
      'rating': '4.7',
      'description': 'Astronomical observatory built by the founder of Jaipur.',
    },
    {
      'name': 'Moti Dungri Palace',
      'distance': '43.0 mi',
      'rating': '4.6',
      'description': 'Palace with a blend of Indian and European architectural styles.',
    },
    {
      'name': 'Chand Baori Stepwell',
      'distance': '44.0 mi',
      'rating': '4.5',
      'description': 'Ancient stepwell known for its stunning architecture and symmetry.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _itinerary = widget.itinerary != null
        ? List<Map<String, String>>.from(widget.itinerary!)
        : [];
  }

  Future<void> _addToItinerary(Map<String, dynamic> item) async {
    if (!_itinerary.any((i) => i['name'] == item['name'] && i['type'] == item['type'])) {
      // If latitude and longitude are missing, try to fetch them
      if (item['latitude'] == null || item['longitude'] == null) {
        // Show a loading indicator
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

        // Try to fetch coordinates using the landmark name
        final coordinates = await _locationService.getCoordinatesFromPlaceName(item['name']);
        
        // Close any open snackbars
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        if (coordinates != null) {
          // Update the item with the fetched coordinates
          item['latitude'] = coordinates['latitude'];
          item['longitude'] = coordinates['longitude'];
          
          // Also update the landmark in the _landmarks list for future reference
          for (var i = 0; i < _landmarks.length; i++) {
            if (_landmarks[i]['name'] == item['name']) {
              setState(() {
                _landmarks[i]['latitude'] = coordinates['latitude'];
                _landmarks[i]['longitude'] = coordinates['longitude'];
              });
              break;
            }
          }
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
        // Add the item to the itinerary with all the necessary data
        _itinerary.add({
          'name': item['name'],
          'type': item['type'],
          'latitude': item['latitude'].toString(),
          'longitude': item['longitude'].toString(),
        });
      });
      widget.onItineraryChanged?.call(_itinerary);
      
      // Show a confirmation message
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
  // We don't need these methods anymore since we're not automatically
  // navigating to the map when adding/removing landmarks

  // Navigate to the map with all landmarks in the itinerary
  void _navigateToMapWithItinerary() {
    if (_itinerary.isEmpty) {
      // Show a message if no landmarks are added
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add landmarks to your itinerary first'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Debug print the itinerary contents
    print('Itinerary items before conversion: ${_itinerary.length}');
    for (var item in _itinerary) {
      print('Itinerary item: ${item['name']}, type: ${item['type']}, lat: ${item['latitude']}, lng: ${item['longitude']}');
    }

    // Convert itinerary items to Location objects
    final List<Location> landmarkLocations = _itinerary
        .where((item) => 
            item['type'] == 'Landmark' && 
            item['latitude'] != null && 
            item['longitude'] != null)
        .map((item) {
          try {
            double lat = double.parse(item['latitude']!);
            double lng = double.parse(item['longitude']!);
            print('Converting to Location: ${item['name']}, lat: $lat, lng: $lng');
            return Location(
              name: item['name']!,
              latitude: lat,
              longitude: lng,
            );
          } catch (e) {
            print('Error converting location: $e');
            return null;
          }
        })
        .whereType<Location>() // Filter out nulls
        .toList();

    print('Created ${landmarkLocations.length} Location objects');
    for (var loc in landmarkLocations) {
      print('Location: ${loc.name}, (${loc.latitude}, ${loc.longitude})');
    }

    if (landmarkLocations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No valid landmark locations found'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Navigate to the map screen with all landmarks
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExploreNearbyScreen(
          landmarkLocations: landmarkLocations,
        ),
      ),
    );
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
          'Wanderly',
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
                        'latitude': landmark['latitude'],
                        'longitude': landmark['longitude'],
                      }),
                      onRemove: () => _removeFromItinerary({
                        'name': landmark['name']!,
                        'type': 'Landmark',
                        'latitude': landmark['latitude'],
                        'longitude': landmark['longitude'],
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
            onPressed: () {
              // Navigate to the map with all landmarks currently in the itinerary
              _navigateToMapWithItinerary();
            },
          ),
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white70),
            onPressed: () {
              // Return to home screen but make sure to pass updated itinerary back
              Navigator.pop(context);
              // The onItineraryChanged callback will ensure data is passed back
              widget.onItineraryChanged?.call(_itinerary);
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear_all, color: Colors.redAccent),
            onPressed: () {
              // Show confirmation dialog before clearing
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
                          Navigator.of(context).pop(); // Close dialog
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.cyan),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Clear the itinerary
                          setState(() {
                            _itinerary.clear();
                          });
                          
                          // Notify parent of the change
                          widget.onItineraryChanged?.call(_itinerary);
                          
                          // Close dialog and show confirmation
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