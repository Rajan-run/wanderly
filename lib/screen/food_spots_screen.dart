import 'package:flutter/material.dart';

class FoodSpotsScreen extends StatelessWidget {
  const FoodSpotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFF18222D);
    final cardColor = const Color(0xFF232F3E);

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
                  children: [
                    _foodCard(
                      image: 'assets/artisan_table.jpg',
                      name: 'The Artisan Table',
                      distance: '0.5 mi',
                      rating: '4.5',
                      description: 'Cafe offering farm-to-table cuisine.',
                      cardColor: cardColor,
                    ),
                    _foodCard(
                      image: 'assets/savory_bites.jpg',
                      name: 'Savory Bites',
                      distance: '0.8 mi',
                      rating: '4.8',
                      description: 'Popular spot for small plates.',
                      cardColor: cardColor,
                    ),
                    _foodCard(
                      image: 'assets/green_garden.jpg',
                      name: 'Green Garden',
                      distance: '1.2 mi',
                      rating: '4.7',
                      description: 'Vegetarian restaurant fresh salads.',
                      cardColor: cardColor,
                    ),
                    _foodCard(
                      image: 'assets/coastal_grill.jpg',
                      name: 'Coastal Grill',
                      distance: '2.0 mi',
                      rating: '4.5',
                      description: 'Seafood and waterfront views',
                      cardColor: cardColor,
                    ),
                  ],
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

  Widget _foodCard({
    required String image,
    required String name,
    required String distance,
    required String rating,
    required String description,
    required Color cardColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            image,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          name,
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
                  distance,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(width: 10),
                Text(
                  rating,
                  style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.star, color: Colors.orange, size: 15),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
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