// Legacy prototype retained for reference. The supported public API lives under
// lib/src and is exported from package:ky_restaurant/ky_restaurant.dart.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

// Models
class Restaurant {
  final String id;
  final String name;
  final String cuisine;
  final double rating;
  final String imageUrl;
  final String description;
  final List<MenuItem> popularItems;

  Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.imageUrl,
    required this.description,
    required this.popularItems,
  });
}

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final bool isPopular;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isPopular = false,
  });
}

class CartItem {
  final MenuItem item;
  int quantity;

  CartItem({required this.item, this.quantity = 1});
}

class Reservation {
  final DateTime date;
  final TimeOfDay time;
  final int guestCount;
  final String specialRequests;

  Reservation({
    required this.date,
    required this.time,
    required this.guestCount,
    this.specialRequests = '',
  });
}

// State management with Riverpod
final restaurantProvider = Provider<Restaurant>((ref) {
  return Restaurant(
    id: 'r1',
    name: 'Bistro Milano',
    cuisine: 'Italian',
    rating: 4.8,
    imageUrl: 'assets/restaurant.jpg',
    description:
        'An upscale Italian bistro offering handmade pasta, wood-fired pizzas, and an extensive wine list in a modern, elegant setting.',
    popularItems: [
      MenuItem(
        id: 'm1',
        name: 'Truffle Pasta',
        description: 'Handmade fettuccine with black truffle cream sauce',
        price: 24.99,
        imageUrl: 'assets/pasta.jpg',
        isPopular: true,
      ),
      MenuItem(
        id: 'm2',
        name: 'Margherita Pizza',
        description: 'Classic pizza with fresh mozzarella and basil',
        price: 18.99,
        imageUrl: 'assets/pizza.jpg',
        isPopular: true,
      ),
      MenuItem(
        id: 'm3',
        name: 'Tiramisu',
        description: 'Classic Italian dessert with espresso and mascarpone',
        price: 10.99,
        imageUrl: 'assets/tiramisu.jpg',
        isPopular: true,
      ),
    ],
  );
});

final menuItemsProvider = Provider<List<MenuItem>>((ref) {
  final restaurant = ref.watch(restaurantProvider);
  // In a real app, you would fetch this from an API
  return [
    ...restaurant.popularItems,
    MenuItem(
      id: 'm4',
      name: 'Caprese Salad',
      description: 'Fresh tomatoes, mozzarella, and basil with balsamic glaze',
      price: 12.99,
      imageUrl: 'assets/caprese.jpg',
    ),
    MenuItem(
      id: 'm5',
      name: 'Risotto ai Funghi',
      description: 'Creamy arborio rice with wild mushrooms and parmesan',
      price: 22.99,
      imageUrl: 'assets/risotto.jpg',
    ),
    MenuItem(
      id: 'm6',
      name: 'Osso Buco',
      description: 'Slow-cooked veal shanks with gremolata',
      price: 32.99,
      imageUrl: 'assets/ossobuco.jpg',
    ),
  ];
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(MenuItem item) {
    final existingIndex = state.indexWhere(
      (cartItem) => cartItem.item.id == item.id,
    );

    if (existingIndex >= 0) {
      state = [
        ...state.sublist(0, existingIndex),
        CartItem(item: item, quantity: state[existingIndex].quantity + 1),
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      state = [...state, CartItem(item: item)];
    }
  }

  void removeItem(String itemId) {
    final existingIndex = state.indexWhere(
      (cartItem) => cartItem.item.id == itemId,
    );

    if (existingIndex >= 0) {
      if (state[existingIndex].quantity > 1) {
        state = [
          ...state.sublist(0, existingIndex),
          CartItem(
            item: state[existingIndex].item,
            quantity: state[existingIndex].quantity - 1,
          ),
          ...state.sublist(existingIndex + 1),
        ];
      } else {
        state = [
          ...state.sublist(0, existingIndex),
          ...state.sublist(existingIndex + 1),
        ];
      }
    }
  }

  void clearCart() {
    state = [];
  }

  double get totalAmount {
    return state.fold(
      0,
      (sum, item) => sum + (item.item.price * item.quantity),
    );
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class ReservationNotifier extends StateNotifier<Reservation?> {
  ReservationNotifier() : super(null);

  void setReservation(Reservation reservation) {
    state = reservation;
  }

  void clearReservation() {
    state = null;
  }
}

final reservationProvider =
    StateNotifierProvider<ReservationNotifier, Reservation?>((ref) {
      return ReservationNotifier();
    });

// Current screen state
final currentScreenProvider = StateProvider<String>((ref) => 'home');

// Main Screen
class RestaurantApp extends ConsumerWidget {
  const RestaurantApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentScreen = ref.watch(currentScreenProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1E3A8A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
          secondary: const Color(0xFFFF6B6B),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
      ),
      home: Scaffold(
        backgroundColor: Colors.grey[50],
        body: _buildCurrentScreen(currentScreen, ref),
        bottomNavigationBar: _buildBottomNavigationBar(ref),
      ),
    );
  }

  Widget _buildCurrentScreen(String screen, WidgetRef ref) {
    switch (screen) {
      case 'home':
        return const HomeScreen();
      case 'menu':
        return const MenuScreen();
      case 'reservation':
        return const ReservationScreen();
      case 'cart':
        return const CartScreen();
      default:
        return const HomeScreen();
    }
  }

  Widget _buildBottomNavigationBar(WidgetRef ref) {
    final currentScreen = ref.watch(currentScreenProvider);
    final cartItems = ref.watch(cartProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(
              ref,
              'home',
              Icons.home_rounded,
              'Home',
              currentScreen == 'home',
            ),
            _buildNavItem(
              ref,
              'menu',
              Icons.restaurant_menu_rounded,
              'Menu',
              currentScreen == 'menu',
            ),
            _buildNavItem(
              ref,
              'reservation',
              Icons.calendar_today_rounded,
              'Reserve',
              currentScreen == 'reservation',
            ),
            Stack(
              children: [
                _buildNavItem(
                  ref,
                  'cart',
                  Icons.shopping_bag_rounded,
                  'Cart',
                  currentScreen == 'cart',
                ),
                if (cartItems.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        cartItems
                            .fold(0, (sum, item) => sum + item.quantity)
                            .toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    WidgetRef ref,
    String screen,
    IconData icon,
    String label,
    bool isActive,
  ) {
    return InkWell(
      onTap: () => ref.read(currentScreenProvider.notifier).state = screen,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF1E3A8A) : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFF1E3A8A) : Colors.grey,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Home Screen
class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurant = ref.watch(restaurantProvider);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 240,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    restaurant.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.restaurant,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.restaurant,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  restaurant.cuisine,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  restaurant.rating.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            title: Opacity(opacity: 0, child: Text(restaurant.name)),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.favorite_border, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  restaurant.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                _buildActionButtons(context, ref),
                const SizedBox(height: 24),
                Text(
                  'Popular Dishes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = restaurant.popularItems[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildPopularItemCard(context, ref, item),
              );
            }, childCount: restaurant.popularItems.length),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              ref.read(currentScreenProvider.notifier).state = 'menu';
            },
            icon: const Icon(Icons.restaurant_menu),
            label: const Text('View Menu'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              ref.read(currentScreenProvider.notifier).state = 'reservation';
            },
            icon: const Icon(Icons.calendar_today),
            label: const Text('Reserve Table'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPopularItemCard(
    BuildContext context,
    WidgetRef ref,
    MenuItem item,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => _buildItemDetailSheet(context, ref, item),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Image.asset(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.restaurant,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFF6B6B,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '\$${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFFFF6B6B),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (item.isPopular)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.whatshot,
                                  color: Colors.amber,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Popular',
                                  style: TextStyle(
                                    color: Colors.amber,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(cartProvider.notifier).addItem(item);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${item.name} added to cart'),
                                backgroundColor: Theme.of(context).primaryColor,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            minimumSize: const Size(0, 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Add',
                            style: TextStyle(fontSize: 12),
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
    );
  }

  Widget _buildItemDetailSheet(
    BuildContext context,
    WidgetRef ref,
    MenuItem item,
  ) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: SizedBox(
                      height: 200,
                      child: Image.asset(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.restaurant,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 18,
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => Navigator.pop(context),
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFFF6B6B,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '\$${item.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Color(0xFFFF6B6B),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (item.isPopular)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.whatshot,
                                color: Colors.amber,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Popular Dish',
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Ingredients',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildIngredientsSection(),
                      const SizedBox(height: 24),
                      const Text(
                        'Dietary Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDietaryInformationSection(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.2),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(cartProvider.notifier).addItem(item);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item.name} added to cart'),
                        backgroundColor: Theme.of(context).primaryColor,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Add to Cart',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIngredientsSection() {
    // This would be dynamic in a real app
    final ingredients = [
      'Fresh Ingredients',
      'Premium Quality',
      'Freshly Prepared',
      'Locally Sourced',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ingredients.map((ingredient) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            ingredient,
            style: TextStyle(color: Colors.grey[800], fontSize: 14),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDietaryInformationSection() {
    // This would be dynamic in a real app
    final dietaryInfo = {
      'Vegetarian': true,
      'Vegan': false,
      'Gluten-Free': false,
      'Contains Nuts': true,
      'Dairy-Free': false,
    };

    return Column(
      children: dietaryInfo.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Icon(
                entry.value ? Icons.check_circle : Icons.cancel,
                color: entry.value ? Colors.green : Colors.red[300],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                entry.key,
                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// Menu Screen
class MenuScreen extends ConsumerWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItems = ref.watch(menuItemsProvider);
    final tabs = ['All', 'Starters', 'Main Course', 'Desserts', 'Drinks'];
    final selectedTabProvider = StateProvider((ref) => 'All');
    final selectedTab = ref.watch(selectedTabProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Menu'), elevation: 0),
      body: Column(
        children: [
          Container(
            height: 50,
            margin: const EdgeInsets.only(top: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                final tab = tabs[index];
                final isSelected = selectedTab == tab;

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ElevatedButton(
                    onPressed: () =>
                        ref.read(selectedTabProvider.notifier).state = tab,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey[100],
                      foregroundColor: isSelected
                          ? Colors.white
                          : Colors.grey[800],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(tab),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search menu items...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return _buildMenuItemCard(context, ref, item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemCard(
    BuildContext context,
    WidgetRef ref,
    MenuItem item,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.asset(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.restaurant,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${item.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(cartProvider.notifier).addItem(item);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${item.name} added to cart'),
                                backgroundColor: Theme.of(context).primaryColor,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Add to Cart'),
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
    );
  }
}

// Reservation Screen
class ReservationScreen extends ConsumerWidget {
  const ReservationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /*  final selectedDate = useState<DateTime>(DateTime.now().add(const Duration(days: 1)));
    final selectedTime = useState<TimeOfDay>(const TimeOfDay(hour: 19, minute: 0));
    final guestCount = useState<int>(2);
    final specialRequests = useState<String>(''); */
    final selectedDateProvider = StateProvider(
      (ref) => DateTime.now().add(const Duration(days: 1)),
    );
    final selectedTimeProvider = StateProvider(
      (ref) => const TimeOfDay(hour: 19, minute: 0),
    );
    final guestCountProvider = StateProvider((ref) => 2);
    final specialRequestsProvider = StateProvider((ref) => '');
    return Scaffold(
      appBar: AppBar(title: const Text('Reserve a Table'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Select Date'),
            const SizedBox(height: 8),
            _buildDatePicker(context, ref.watch(selectedDateProvider.notifier)),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Select Time'),
            const SizedBox(height: 8),
            _buildTimePicker(context, ref.watch(selectedTimeProvider.notifier)),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Number of Guests'),
            const SizedBox(height: 8),
            _buildGuestCounter(context, ref.watch(guestCountProvider.notifier)),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Special Requests'),
            const SizedBox(height: 8),
            TextField(
              onChanged: (value) =>
                  ref.read(specialRequestsProvider.notifier).state = value,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Any special requests or preferences...',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Save reservation
                final reservation = Reservation(
                  date: ref.read(selectedDateProvider),
                  time: ref.read(selectedTimeProvider),
                  guestCount: ref.read(guestCountProvider),
                  specialRequests: ref.read(specialRequestsProvider),
                );

                ref
                    .read(reservationProvider.notifier)
                    .setReservation(reservation);

                // Show success dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Reservation Confirmed'),
                    content: Text(
                      'Your table for ${ref.read(guestCountProvider)} has been reserved on ${DateFormat('EEEE, MMMM d, y').format(ref.read(selectedDateProvider))} at ${ref.read(selectedTimeProvider).format(context)}.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ref.read(currentScreenProvider.notifier).state =
                              'home';
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 0),
              ),
              child: const Text(
                'Confirm Reservation',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildDatePicker(
    BuildContext context,
    StateController<DateTime> selectedDate,
  ) {
    final dates = List.generate(
      14,
      (index) => DateTime.now().add(Duration(days: index)),
    );

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = DateUtils.isSameDay(date, selectedDate.state);
          final isToday = DateUtils.isSameDay(date, DateTime.now());

          return GestureDetector(
            onTap: () => selectedDate.state = date,
            child: Container(
              width: 65,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isToday && !isSelected
                          ? Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.1)
                          : null,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        DateFormat('d').format(date),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : isToday
                              ? Theme.of(context).primaryColor
                              : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimePicker(
    BuildContext context,
    StateController<TimeOfDay> selectedTime,
  ) {
    final times = [
      const TimeOfDay(hour: 11, minute: 0),
      const TimeOfDay(hour: 12, minute: 0),
      const TimeOfDay(hour: 13, minute: 0),
      const TimeOfDay(hour: 18, minute: 0),
      const TimeOfDay(hour: 19, minute: 0),
      const TimeOfDay(hour: 20, minute: 0),
      const TimeOfDay(hour: 21, minute: 0),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: times.map((time) {
        final isSelected =
            time.hour == selectedTime.state.hour &&
            time.minute == selectedTime.state.minute;

        return ElevatedButton(
          onPressed: () => selectedTime.state = time,
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey[100],
            foregroundColor: isSelected ? Colors.white : Colors.black,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: Text(time.format(context)),
        );
      }).toList(),
    );
  }

  Widget _buildGuestCounter(
    BuildContext context,
    StateController<int> guestCount,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.people, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            'Guests',
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              if (guestCount.state > 1) {
                guestCount.state--;
              }
            },
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.remove,
                color: Theme.of(context).primaryColor,
                size: 16,
              ),
            ),
          ),
          Text(
            guestCount.state.toString(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () {
              if (guestCount.state < 10) {
                guestCount.state++;
              }
            },
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                color: Theme.of(context).primaryColor,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Cart Screen
class CartScreen extends ConsumerWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.watch(cartProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        elevation: 0,
        actions: [
          if (cartItems.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear Cart'),
                    content: const Text(
                      'Are you sure you want to remove all items from your cart?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          cartNotifier.clearCart();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text('Clear', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart(context, ref)
          : _buildCartItemsList(context, ref, cartItems),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : _buildCartSummary(context, ref, cartNotifier.totalAmount),
    );
  }

  Widget _buildEmptyCart(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items from the menu to get started',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(currentScreenProvider.notifier).state = 'menu';
            },
            icon: const Icon(Icons.restaurant_menu),
            label: const Text('Browse Menu'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemsList(
    BuildContext context,
    WidgetRef ref,
    List<CartItem> cartItems,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cartItems.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final cartItem = cartItems[index];
        return _buildCartItemCard(context, ref, cartItem);
      },
    );
  }

  Widget _buildCartItemCard(
    BuildContext context,
    WidgetRef ref,
    CartItem cartItem,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 70,
            height: 70,
            child: Image.asset(
              cartItem.item.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                child: const Icon(
                  Icons.restaurant,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cartItem.item.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${cartItem.item.price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildQuantityButton(context, Icons.remove, () {
                    ref
                        .read(cartProvider.notifier)
                        .removeItem(cartItem.item.id);
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      cartItem.quantity.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildQuantityButton(context, Icons.add, () {
                    ref.read(cartProvider.notifier).addItem(cartItem.item);
                  }),
                ],
              ),
            ],
          ),
        ),
        Text(
          '\$${(cartItem.item.price * cartItem.quantity).toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildQuantityButton(
    BuildContext context,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: Theme.of(context).primaryColor),
      ),
    );
  }

  Widget _buildCartSummary(
    BuildContext context,
    WidgetRef ref,
    double totalAmount,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(fontSize: 14)),
              Text(
                '\$${totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tax (8%)', style: TextStyle(fontSize: 14)),
              Text(
                '\$${(totalAmount * 0.08).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${(totalAmount * 1.08).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Order Placed'),
                  content: const Text(
                    'Your order has been successfully placed and will be ready for pickup or delivery soon.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        ref.read(cartProvider.notifier).clearCart();
                        ref.read(currentScreenProvider.notifier).state = 'home';
                        Navigator.pop(context);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 0),
            ),
            child: const Text(
              'Place Order',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(ProviderScope(child: RestaurantApp()));
}
